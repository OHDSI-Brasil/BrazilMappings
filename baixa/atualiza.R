# atualiza.R ------------------------------------------------------------------------------------------------------
#' ---
#' Projeto: SIGTAP OMOP. Mapeamento colaborativo de códigos da SIGTAP usando Dolt.
#' Script: atualiza.R. Verifica se há atualizações para o script Zelador.
#' Por Fabrício Kury, fab em kury.dev.
#' Início: 2022-09-12 14:31-4.
#' 

# Controle --------------------------------------------------------------------------------------------------------
faz_executa <- TRUE

bibliotecas_global <- c('tools')

arq_versão <- './r/versão.txt'
arq_versão_remoto <- 'https://github.com/OHDSI-Brasil/SIGTAP2OMOP/raw/master/baixa/vers%C3%A3o.txt'

arq_zelador <- './r/zelador.R'
arq_zelador_remoto <- 'https://github.com/OHDSI-Brasil/SIGTAP2OMOP/raw/master/baixa/zelador.R'


# Funções ---------------------------------------------------------------------------------------------------------
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

carrega_bibliotecas <- function(bibliotecas = bibliotecas_global, verbose = FALSE) {
  if(verbose)
    console('Carregando bibliotecas.')
  for(biblioteca in bibliotecas)
    suppressWarnings(suppressPackageStartupMessages(library(biblioteca, character.only = TRUE)))
}


# Execução --------------------------------------------------------------------------------------------------------
if(faz_executa) {
  console('Verificando atualizações.')
  
  if(length(instala_bibliotecas()) != 0)
    stop('Erro ao instalar bibliotecas.')
  carrega_bibliotecas()
  
  baixar_nova_versão <- FALSE
  if(!file.exists(arq_zelador))
    baixar_nova_versão <- TRUE
  else
    versão_atual <- md5sum(arq_zelador)
  
  download.file(arq_versão_remoto, arq_versão, quiet = TRUE)
  versão_remota <- readLines(arq_versão, warn = FALSE)

  if(baixar_nova_versão || versão_atual != versão_remota) {
    console('Baixando nova versão. [', versão_remota, ']')
    download.file(arq_zelador_remoto, arq_zelador, quiet = TRUE)
  } else {
    # console('Versão atual já é a mais recente. [', versão_atual, ']')
  }
  
  quit(save = 'no')
}

