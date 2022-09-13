# zelador.R -------------------------------------------------------------------------------------------------------
#' ---
#' Projeto: SIGTAP OMOP. Mapeamento colaborativo de códigos da SIGTAP usando Dolt.
#' Script: zelador.R. Coordena o uso do DoltHub.
#' Por Fabrício Kury, fab em kury.dev.
#' Início: 2022-08-11 20:47-4.
#' 

# Controle --------------------------------------------------------------------------------------------------------
faz_executa <- TRUE

bibliotecas_global <- c('tidyverse', 'dbplyr', 'processx', 'ps', 'DBI', 'RMariaDB')
dolt_dir <- suppressWarnings(normalizePath('./dolt'))
dolt_exe <- paste0(dolt_dir, '/dolt.exe')
arq_config <- './config.txt'
dir_linhas <- './linhas'
dir_linhas_sobe <- paste0(dir_linhas, '/upload')
quórum_mínimo <- 3
limite_distribuição <- 5
usuário_admin <- 'sigtap_omop_admin'

# Colunas a atualizar quando o participante sobe linhas.
colunas_a_subir <- c("mappingStatus", "equivalence", "statusSetOn", "conceptId", "conceptName", "domainId",
  "mappingType", "comment", "createdBy", "createdOn", "assignedReviewer")


# Funções ---------------------------------------------------------------------------------------------------------
ensureDir <- function(...) {
  d <- paste0(...)
  if(!dir.exists(d))
    dir.create(d, recursive = TRUE)
  return(d)
}

escolhe_stdin <- function() {
  if(interactive())
    stdin()
  else {
    if(!exists('entrada', envir = .GlobalEnv)) {
      .GlobalEnv$entrada <- file('stdin')
    }
  }
}

fecha_stdin <- function() {
  if(!interactive()) {
    if(exists('entrada', envir = .GlobalEnv)) {
      close(.GlobalEnv$entrada)
      remove('entrada', envir = .GlobalEnv)
    }
  }
}

dolt <- function(..., script = dolt_exe, verbose = FALSE) {
  dolt_proc <- process$new(script, args = c(...), stdout = "|", stderr = '|', wd = dolt_dir)
  res <- dolt_proc$read_all_output()
  if(verbose) {
    err <- dolt_proc$read_all_error()
    if(nchar(err[1]) > 0)
      console('Erro: ', err)
  }
  res
}

consolex <- function(...) {
  cat(paste0(...))
}

console <- function(..., tempo = FALSE) {
  # The 'manouver' below is *just* to remove leading zeroes in the hour number.
  t <- Sys.time()
  if(tempo) {
    tempo_str <- paste0(format(t, '%m/%d '), as.integer(format(t, '%H')), format(t, ':%M'), ' ')
    consolex(tempo_str, ..., '\n')
  }
  else
    consolex(..., '\n')
}

instala_bibliotecas <- function(bibliotecas = bibliotecas_global) {
  # Calcula bibliotecas faltantes.
  ip <- installed.packages() |> as.data.frame()
  bibliotecas_faltantes <- bibliotecas[!(bibliotecas %in% ip$Package)]
  
  # Instala bibliotecas faltantes.
  for(biblioteca in bibliotecas_faltantes) {
    console('Instalando ', biblioteca, '. Esta operação só ocorre uma vez.')
    install.packages(biblioteca, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  
  # Calcula bibliotecas faltantes de novo.
  ip <- installed.packages() |> as.data.frame()
  bibliotecas_faltantes <- bibliotecas[!(bibliotecas %in% ip$Package)]
  
  # Retorna quais ainda faltam, isto é, quais não puderam ser instaladas.
  return(bibliotecas_faltantes)
}

carrega_bibliotecas <- function(bibliotecas = bibliotecas_global) {
  console('Carregando bibliotecas.')
  for(biblioteca in bibliotecas)
    suppressWarnings(suppressPackageStartupMessages(library(biblioteca, character.only = TRUE)))
}

fecha_dolt_sql <- function() {
  if(exists('proc_sql', envir = .GlobalEnv)) {
    if(exists('dbd', envir = .GlobalEnv)) {
      # Desconectar antes de fechar o Dolt.
      dbDisconnect(dbd)
      remove('dbd', envir = .GlobalEnv)
    }
    
    prsql <- get('proc_sql', envir = .GlobalEnv)
    prsql$kill()
    remove('proc_sql', envir = .GlobalEnv)
  }
}

abre_dolt_sql <- function(verbose = FALSE) {
  processos <- ps()
  máscara <- processos$name == 'dolt.exe'
  if(any(máscara)) {
    if(verbose) {
      message('Dolt.exe já aberto em:')
      print(processos[máscara,])
    }
  } else {
    # if(verbose)
      console('Executando o Dolt.')
    assign('proc_sql', envir = .GlobalEnv,
      process$new(dolt_exe, c('sql-server'), wd = dolt_dir, supervise = TRUE))
    
    # Esperar para conectar via SQL. Não sei se isto é necessário.
    Sys.sleep(1)
  }
}

lê_config <- function(endr) {
  config_txt <- readLines(endr, warn = FALSE)
  
  config <- str_match(config_txt, '(\\S+) = (\\S+)') |>
    `colnames<-`(c('string', 'variável', 'valor')) |>
    as_tibble()
  
  assign('config', config, envir = .GlobalEnv)
  pwalk(config, ~assign(..2, ..3, envir = .GlobalEnv))
}

obtém_creds <- function(sobrsc = FALSE) {
  if(sobrsc || is.null(.GlobalEnv$creds)) {
    .GlobalEnv$creds <- suppressWarnings(dolt('creds', 'check') |>
      strsplit('\n') |>
      unlist())
    if(verifica_creds(creds)) {
      # Obtém o nome de usuário.
      .GlobalEnv$username <- str_match(creds[6], ' User: (.+)')[,2]
    }
  }
  .GlobalEnv$creds
}

verifica_creds <- function(increds = character(0)) {
  if(length(increds) == 0)
    increds <- obtém_creds()
  return('Success.' %in% increds)
}

username_do_creds <- function() {
  if(is.null(.GlobalEnv$username)) {
    console('Obtendo nome de usuário.')
    creds <- obtém_creds()
    .GlobalEnv$username <- str_match(creds[6], ' User: (.+)')[,2]
  }
  .GlobalEnv$username
}

conecta_mariadb <- function() {
  if(!exists('dbd', envir = .GlobalEnv)) {
    console('Conectando via SQL.')
    library(RMariaDB)
    library(DBI)
    .GlobalEnv$dbd <- dbConnect(RMariaDB::MariaDB(), host = "localhost", user = "root")
  }
  dbd
}

gera_id_reserva <- function() {
  idr <- as.character(round(runif(1, 1, 10000000)))
  if(nchar(idr) > 5)
    idr <- substr(idr, 1, 5)
  idr
}

pede_comando <- function(comandos, mensagem, permite_zero = TRUE) {
  comando <- NA
  while(is.na(comando)) {
    console(mensagem)
    for(i in seq_along(comandos))
      console(i, ') ', comandos[i])
    if(permite_zero)
      console('0) Cancelar')
    
    # Tentar ler um número do comando. Se falhar, pedir comando de novo.
    tryCatch({
      comando <- readLines(escolhe_stdin(), 1)
      fecha_stdin()
      comando <- substr(comando, 1, 1) # Pega apenas 1 caractere.
      comando <- as.integer(comando)
      if(is.null(comando)) # TODO: Isto é necessário?
        comando <- NA
    }, error = \(e) {
      comando <- NA
    })
    
    # Verifica se o número corresponde a algum comando.
    if(!(comando %in% seq_along(comandos) || (permite_zero && comando == 0)))
      comando <- NA
  }
  comando
}

pergunta_sim_não <- function(...) {
  while(TRUE) {
    console(...)
    resposta <- readLines(escolhe_stdin(), 1) |>
      tolower()
    fecha_stdin()
    if(resposta == 'n') # "não"
      return(FALSE)
    if(resposta == 's') # "sim
      return(TRUE)
    # Se nem 's' nem 'n', repetir a pergunta.
  }
}

pede_enter <- function() {
  readLines(escolhe_stdin(), 1)
  fecha_stdin()
}

add_commit_push <- function(commit_message, pede_pull_request = FALSE) {
  tryCatch({
    console('Executando dolt add.')
    dbExecute(dbd, "call dolt_add('.');")
    
    console('Executando dolt commit.')
    dbExecute(dbd, paste0("call dolt_commit('-m', '", commit_message, "');"))
    
    console('Executando dolt push.')
    dbExecute(dbd, "call dolt_push('--set-upstream', 'origin', 'main');")
  }, error = \(e) {
    console('Erro ao executar dolt push.')
    return()
  })
  
  ## Gerar o pull request.
  if(pede_pull_request) {
    # Abre o navegador na página de criar pull request.
    url_pull_request <- 'https://www.dolthub.com/repositories/ohdsi-brasil/sigtap_omop/pulls/new?refName=main'
    
    console('Aperte Enter para abrir o navegador na página para fazer o pull request:\n', url_pull_request, '\n\n',
      'Por favor lembre-se que este pull request é obrigatório.')
    
    pede_enter()
    
    console('Abrindo o navegador. Por favor preencha os campos e confirme o pull request.')
    
    browseURL(url_pr)
    
    Sys.sleep(4) # Apenas para minimizar a chance de que novo texto aparecerá na tela antes que o navegador abra.
  }
}

apaga_vista <- function(nome_vista) {
  dbExecute(dbd, paste0('drop view ', nome_vista, ';'))
  add_commit_push(paste0('Apaga vista ', nome_vista, '.'))
}


# Faz login no DoltHub --------------------------------------------------------------------------------------------
inicia_dolthub <- function() {
  if(verifica_creds(obtém_creds()))
    if(pergunta_sim_não('Login já detectado para ', username, '. Deseja continuar? s/n') == FALSE)
        return()
  
  console('Aperte Enter para abrir o navegador na página do DoltHub.\nSe você não fez login no site, será preciso ',
    'fazê-lo. Após o login (caso precise fazer), o site redirecionará para a página de criar credenciais. Por favor ', 
    'preencha qualquer coisa no campo "Description" (não faz diferença) e confirme a criação da credencial.',
    '\nApós realizar isto, retorne para o script Zelador, que identificará a credencial criada.\n\n',
    'Aperte Enter para abrir o navegador na página do DoltHub.\n')
  pede_enter()
  dolt('login')
  
  creds <- obtém_creds(sobrsc = TRUE)
  if(!verifica_creds(creds)) {
    console('Erro ao fazer login.')
  } else {
    # Obtém o nome de usuário.
    .GlobalEnv$username <- str_match(creds[6], ' User: (.+)')[,2]
    if(!(nchar(username) > 2))
      stop('Falha ao obter nome de usuário.')
    
    console('Login realizado com sucesso para usuário ', username, '.')
  }
}


# Faz o fork ------------------------------------------------------------------------------------------------------
fazer_fork <- function() {
  if(!verifica_creds())
    stop('Erro ao fazer login.')

  # Abrir a página para fazer o fork.
  url_repo <- 'https://www.dolthub.com/repositories/ohdsi-brasil/sigtap_omop'
  console('Aperte Enter para abrir o navegador na página de fazer o fork do repositório ohdsi-brasil/sigtap_omop. ',
    'Se preferir, copie e cole o endereço abaixo:\n',
    url_repo)
  pede_enter()
  browseURL(url_repo)
}


# Baixa linhas ----------------------------------------------------------------------------------------------------
baixa_linhas <- function() {
# Prepara ---------------------------------------------------------------------------------------------------------
  id_reserva <- paste0(nome_tabela, '_', gera_id_reserva())
  
  # Executa o Dolt em processo separado.
  abre_dolt_sql()

  # Conecta ao Dolt via SQL.
  conecta_mariadb()

# Acessa a database sigtap_omop; clona se preciso. ----------------------------------------------------------------
  # Confere quais databases (repositórios do DoltHub) já existem.
  bases <- dbGetQuery(dbd, 'show databases;') |> pull(Database)
  
  # O Sigtap Omop já existe localmente?
  if(!proj_repo %in% bases) {  # proj_repo vem do lê_config()
    # Clonar repositório.
    repo_address <- paste0(username, '/sigtap_omop')
    console('Clonando repositório ', repo_address, '.')
    dbGetQuery(dbd, paste0("call dolt_clone('", repo_address, "');"))
    
    # Tentar novamente encontrar o Sigtap Omop na lista de repositórios locais. Se falhar, abortar.
    bases <- dbGetQuery(dbd, 'show databases;') |> pull(Database)
    if(!proj_repo %in% bases) {
      console('Falha ao clonar repositório.')
      return()
    }
  }
  
  # Troca para o sigtap_omop.
  dbExecute(dbd, paste0('use ', proj_repo, ';'))
  
  # Executa dolt fetch.
  console('Atualizando a tabela local (dolt fetch).')
  dbExecute(dbd, paste0('call dolt_fetch();'))
  
  tabela_dolt <- tbl(dbd, paste0(nome_tabela, '_dolt')) # tabela lazy
  
# Verifica/pega linhas que este usuário já pegou antes ------------------------------------------------------------
  # Quais códigos este usuário já pegou antes?
  linhas_do_usuário <- tabela_dolt |>
    filter(statusSetBy == username) |>
    select(sourceCode, mappingStatus)
  
  # Quais códigos este usuário já pegou antes, e ainda não mapeou?
  linhas_aguardando <- linhas_do_usuário |>
    filter(mappingStatus == 'UNCHECKED')
  
  n_linhas_aguardando <- linhas_aguardando |>
    tally() |> pull(n) |> as.integer()
  
  if(n_linhas_aguardando > 0)
    console('Encontradas ', n_linhas_aguardando, ' linhas previamente reservadas e ainda não mapeadas.')
  
  # Pegar os códigos prévios. Esses serão os primeiros a serem escolhidos.
  termos_selecionados <- linhas_aguardando |>
    select(sourceCode) |>
    collect() |>
    pull(sourceCode)
  
# Pergunta ao usuário quantas linhas ele(a) quer. -----------------------------------------------------------------
  pegar_n_linhas <- -1
  while(pegar_n_linhas < 10 || pegar_n_linhas > 50) {
    if(n_linhas_aguardando > 0) {
      console('Quantas linhas gostaria de baixar da ', nome_tabela, ', incluindo as ', n_linhas_aguardando,
        ' anteriores? (10 - 50, 0 para cancelar)')
    } else {
      console('Quantas linhas gostaria de baixar da ', nome_tabela, '? (10 - 50, 0 para cancelar)')
    }
    pegar_n_linhas <- readLines(escolhe_stdin(), 1)
    fecha_stdin()
    tryCatch({
      pegar_n_linhas <- suppressWarnings(as.integer(pegar_n_linhas))
      if(is.na(pegar_n_linhas) || is.null(pegar_n_linhas))
        pegar_n_linhas <- -1
    }, error = \(e) {
      pegar_n_linhas <- -1
    })
    
    if(pegar_n_linhas == 0)
      return()
  }
  
  console('Obtendo ', pegar_n_linhas, ' linhas da ', nome_tabela, ' para usuário ', username, '.')

# Pegar (reservar) novos termos, se preciso. ----------------------------------------------------------------------
  if(pegar_n_linhas > n_linhas_aguardando) {
    # Deseja-se mais linhas do que as prévias ainda não mapeadas. Ou seja, será preciso reservar novas linhas.
    n_linhas_faltantes <- pegar_n_linhas - n_linhas_aguardando

    # Seleção A: termos que ainda não atingiram limite de distribuição.
    sel_a <- tabela_dolt |>
      group_by(sourceCode) |>
      summarise(participantes = n_distinct(statusSetBy)) |>
      filter(participantes < limite_distribuição + 1)
    
    # Remover os códigos que este usuário já mapeou ou reservou.
    sel_a <- sel_a |>
      left_join(by = 'sourceCode',
        linhas_do_usuário |>
          select(sourceCode) |>
          mutate(prévio = TRUE)) |>
      filter(is.na(prévio)) |>
      select(-prévio)
    
    # Contar quantos termos.
    n_termos_disponíveis <- sel_a |>
      tally() |>
      pull(n)
    
    if(n_termos_disponíveis == 0)
      console('Não há termos não-mapeados disponíveis.')
    else {
      if(n_linhas_faltantes > n_termos_disponíveis) {
        console('Há apenas ', n_termos_disponíveis, ' termos disponíveis. Este será o limite.')
        n_linhas_faltantes <- n_termos_disponíveis
      }
      console('Fará a reserva de ', n_linhas_faltantes, ' novas linhas. Continuar? s/n')
      if(pergunta_sim_não() == FALSE) {
        console('Abortando reserva de linhas.')
        console('Se você deseja obter somente as linhas previamente reservadas e ainda não mapeadas, por favor ',
          'solicite número de linhas igual ao número de linhas previamente reservadas.')
        return()
      }
      
      termos_disponíveis <- sel_a |>
        select(sourceCode) |>
        collect() |>
        pull(sourceCode)
      
      # Pega amostra aleatória.
      # Estratégia de amostragem: pega um ponto aleatório na lista, e consome N itens a partir dele.
      fim_da_lista <- length(termos_disponíveis) - n_linhas_faltantes
      ponto_na_lista <- sample.int(fim_da_lista, 1) # Ponto aleatório.
      novos_termos <- termos_disponíveis[ponto_na_lista:(ponto_na_lista+n_linhas_faltantes-1)]
      termos_selecionados <- c(termos_selecionados, novos_termos)
      
      console('Fazendo a reserva de novas linhas.\nID da reserva: ', id_reserva)
      
      console('Inserindo novas linhas.')
      
      # Baixa as linhas "em branco", isto é, com statusSetBy == usuário_admin.
      novas_linhas <- tabela_dolt |>
        filter(sourceCode %in% novos_termos
          && statusSetBy == usuário_admin) |>
        collect()
      
      # Altera o statusSetBy e reseta o mappingStatus
      novas_linhas <- novas_linhas |>
        mutate(
          statusSetBy = username,
          mappingStatus = 'UNCHECKED')
      
      # Executa o SQL
      sql_txt <- sqlAppendTable(dbd, paste0(nome_tabela, '_dolt'), novas_linhas, row.names = FALSE) |> as.character()
      dbExecute(dbd, sql_txt)
      
      # Executa os comandos do Dolt.
      commit_message <- paste0('Reserva de ', n_linhas_faltantes, ' linhas para ', username,
        ' (Zelador ', id_reserva, ').')
      
      add_commit_push(commit_message, pede_pull_request = TRUE)
    }
  }

# Escreve arquivo CSV ---------------------------------------------------------------------------------------------
  sai_linhas <- tabela_dolt |>
    filter(sourceCode %in% termos_selecionados
      && statusSetBy == usuário_admin) |>
    collect() |>
    mutate(
      statusSetBy = username,
      mappingStatus = 'UNCHECKED')
  
  console('Produzindo arquivo CSV.')
  ensureDir(dir_linhas)
  # Aproveitar o ensejo para criar o diretório dir_linhas_sobe.
  ensureDir(dir_linhas_sobe)
  nome_csv <- paste0(dir_linhas, '/', id_reserva, '.csv')
  write_csv(sai_linhas, nome_csv, na = '')
  console('Arquivo escrito com sucesso:\n', normalizePath(nome_csv))
  console('Esse arquivo está pronto para ser aberto no Usagi.')
}


# Refaz push ------------------------------------------------------------------------------------------------------
refazer_push <- function() {
# Prepara ---------------------------------------------------------------------------------------------------------
  # Executa o Dolt em processo separado.
  abre_dolt_sql()
  
  # Conecta ao Dolt via SQL.
  conecta_mariadb()

  # Troca para o sigtap_omop.
  dbExecute(dbd, paste0('use ', proj_repo, ';'))
  
# Faz o push ------------------------------------------------------------------------------------------------------
  console('Executando dolt push.')
  dbExecute(dbd, "call dolt_push('--set-upstream', 'origin', 'main');")
  
  # Gera o pull request da reserva.
  ## Gerar o pull request.
  url_pr <- 'https://www.dolthub.com/repositories/ohdsi-brasil/sigtap_omop/pulls/new?refName=main'
  
  console('Aperte Enter para abrir o navegador na página para fazer o pull request:\n', url_pr, '\n\n',
    'Por favor lembre-se que este pull request é obrigatório.')
  pede_enter()
  
  console('Abrindo o navegador. Por favor preencha os campos e confirme o pull request.')
  browseURL(url_pr)
}


# Sobe linhas -----------------------------------------------------------------------------------------------------
sobe_linhas <- function() {
# Pergunta qual arquivo -------------------------------------------------------------------------------------------
  arqs <- list.files(dir_linhas_sobe, pattern = '\\.csv$')
  
  if(length(arqs) == 0) {
    console('Nenhum arquivo encontrado na pasta ', normalizePath(dir_linhas_sobe),
      '. Por favor mova o arquivo mapeado para esta pasta e tente novamente.')
    return()
  }
  
  comando <- pede_comando(arqs, 'Por favor selecione qual arquivo gostaria de subir.')
  if(comando == 0)
    return()
  arq_selecionado <- arqs[comando]
  
  console('Lendo ', arq_selecionado, '.')
  linhas_sobe <- read_csv(paste0(dir_linhas_sobe, '/', arq_selecionado), show_col_types = FALSE)

# Prepara ---------------------------------------------------------------------------------------------------------
  # Executa o Dolt em processo separado.
  abre_dolt_sql()
  
  # Conecta ao Dolt via SQL.
  conecta_mariadb()
  
  # Troca para o sigtap_omop.
  dbExecute(dbd, paste0('use ', proj_repo, ';'))
  
# Executa SQL UPDATE ----------------------------------------------------------------------------------------------
  console('Executando comandos SQL UPDATE.')

  sql_início <- paste0('update ', nome_tabela, '_dolt set')
  
  for(i in 1:nrow(linhas_sobe)) {
    sourceCode <- linhas_sobe$sourceCode[i]
    
    sql_meio <- lapply(colunas_a_subir, \(coluna) {
      valor_sql <- as.character(sqlData(dbd, linhas_sobe[[i, coluna]]))
      if(valor_sql == 'NA')
        valor_sql = "''"
      paste0(coluna, ' = ', valor_sql)
    }) |>
      paste(collapse = ',\n')
    
    sql_fim <- paste0('where sourceCode = \'', sourceCode, '\' and statusSetBy = \'', username, '\';')
    
    # Executa o comando SQL.
    sql_txt <- paste(sql_início, sql_meio, sql_fim, sep = '\n')
    dbExecute(dbd, sql_txt)
  }
  

# Atualiza o Dolt e gera o pull request ---------------------------------------------------------------------------
  add_commit_push(paste0('Zelador sobe ', arq_selecionado, ' de ', username, '.'), pede_pull_request = TRUE)
}


# Consenso --------------------------------------------------------------------------------------------------------
cria_vista_consenso <- function() {
  votos_por_termo <- tabela_dolt |>
    filter(statusSetBy != usuário_admin) |>
    group_by(sourceCode) |>
    summarise(.groups = 'keep',
      votos_termo = n_distinct(statusSetBy))
  
  votos_por_termo_conceito <- tabela_dolt |>
    filter(statusSetBy != usuário_admin) |>
    group_by(sourceCode, conceptId) |>
    summarise(.groups = 'keep',
      votos_conceito = n_distinct(statusSetBy))
  
  votação <- inner_join(votos_por_termo, votos_por_termo_conceito, by = 'sourceCode')
  
  nomes_termos <- tabela_dolt |>
    filter(statusSetBy == usuário_admin) |>
    select(sourceCode, sourceName)
  
  nomes_conceitos <- tabela_dolt |>
    select(conceptId, conceptName) |>
    distinct()
  
  resultado <- votação |>
    mutate(
      quórum = votos_termo >= quórum_mínimo,
      consenso = quórum & (votos_conceito > votos_termo/2)) |>
    inner_join(nomes_termos, by = 'sourceCode') |>
    inner_join(nomes_conceitos, by = 'conceptId') |>
    select(sourceCode, sourceName, votos_termo, conceptId, conceptName, votos_conceito, quórum, consenso) |>
    arrange(desc(quórum), sourceCode, conceptId)
  
  sql_txt <- sql_render(resultado) |> as.character()
  nome_vista <- paste0(nome_tabela, '_consenso')
  sql_txt <- paste0('create view ', nome_vista, ' as\n', sql_txt, ';')
  dbExecute(dbd, sql_txt)
  
  add_commit_push(paste0('Cria vista ', nome_vista, '.'))
}


# Execução --------------------------------------------------------------------------------------------------------
if(faz_executa) {
# Prepara ---------------------------------------------------------------------------------------------------------
  console('Sigtap Omop - Script Zelador\nPor Fabrício Kury - fab@kury.dev\nAgosto de 2.022\n')
  if(!file.exists(dolt_exe))
    stop(paste0('Não foi possível encontrar o Dolt. Favor verificar a instalação.\n',
      'Arquivo não encontrado:\n', dolt_exe))

# Bibliotecas -----------------------------------------------------------------------------------------------------
  if(length(instala_bibliotecas()) != 0)
    stop('Erro ao instalar bibliotecas.')
  
  # Carrega pacotes.
  carrega_bibliotecas()

# Config ----------------------------------------------------------------------------------------------------------
  if(!file.exists(arq_config))
    stop(paste0('Não foi possível encontrar o arquivo config.txt. Favor verificar a instalação.\n',
      'Arquivo não encontrado:\n', arq_config))
  lê_config(arq_config)
  
# Ciclo principal -------------------------------------------------------------------------------------------------
  while(TRUE) {
    tem_credenciais <- verifica_creds()
    
    comandos <- c('Fazer login ao DoltHub')
    
    if(tem_credenciais) {
      if(!exists('user_name')) {
        user_name <- dolt('config', '--get', 'user.name')
        user_name <- substr(user_name, 1, nchar(user_name)-1) # Elimina o \n que aparece no final.
        console('Login no DoltHub detectado para ', user_name, '.\n')
      }
      comandos <- c(comandos,
        'Fazer fork',
        'Baixar linhas para mapear',
        'Rafazer dolt push',
        'Subir linhas mapeadas')
    }
    
    comando <- pede_comando(comandos, 'Escolha a operação desejada:')
    if(comando == 0)
      return()
    comando <- comandos[comando]
    
    if(comando == 'Fazer login ao DoltHub')
      inicia_dolthub()
    
    if(comando == 'Fazer fork')
      fazer_fork()
    
    if(comando == 'Baixar linhas para mapear')
      baixa_linhas()
    
    if(comando == 'Rafazer dolt push')
      refazer_push()
    
    if(comando == 'Subir linhas mapeadas')
      sobe_linhas()
  }
  
  console('Saindo do script Zelador.')
}

