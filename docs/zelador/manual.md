---
layout: page
title: Script Zelador
subtitle: Manual de Instruções
description: Informações sobre a configuração e uso do script zelador para mapeamento do SIGTAP para OMOP
permalink: /zelador/manual/
menubar: menu_zelador
show_sidebar: false
---

## Manual de Instruções

### Acessando o Zelador
Após descompactar os arquivos do pacote UDZ, você terá acesso ao arquivo 'zelador.bat' que executará o Script em .R

O Script verificará se foi lançada alguma versão mais atualizada. Se sim, será feita atualização para a versão mais recente.

Sua tela inicial de acesso:

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_tela_inicial.png" alt="Tela inicial do zelador" class="center" style="width:977px;"/>

### Fazendo Login no DoltHub
Digite a opção 1 e aperte ENTER para iniciar o processo de login no DoltHub

O script te direcionará para página do DoltHub. Faça o login em sua conta

Em seguida, você será solicitado para criar uma credencial. Defina um nome qualquer para sua credencial e clique em "Create"

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_credencial.png" alt="Credencial" class="center" style="width:1166px;"/>

Essa etapa **não** é necessária de realizar todas vezes que executar o script zelador.

Se sua credencial permanece válida, você poderá ignorar essa etapa nos próximos acessos.

### Realizando o Fork
Digite a opção 2 e aperte ENTER para iniciar o processo de realização do Fork, caso não tenha ainda sido feito.

O script te direcionará para página do DoltHub. Clique em Fork

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_fork.png" alt="Fork" class="center" style="width:1172px;"/>

Realize o Fork do SIGTAP2OMOP para você conseguir fazer as etapas de baixar e enviar linhas mapeadas.

Essa etapa **não** é necessária de realizar todas vezes que executar o script zelador.

Se você realizou o fork previamente, você poderá ignorar essa etapa nos próximos acessos.

### Baixando linhas para mapear
Digite a opção 3 e aperte ENTER para iniciar o processo de baixar linhas

O script te perguntará quantas linhas deseja mapear, podendo selecionar entre 2-50 linhas.

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_baixar.png" alt="" class="center" style="width:782px;"/>

Se você tiver baixado linhas previamente, mas elas ainda não foram enviadas, o Script selecionará as mesmas linhas para mapeamento.

Após selecionar o número de linha que deseja mapear, o script solicitará que você faça o Pull Request na página do DoltHub. Clique ENTER e abrirá a página do DoltHub

- Selecione 'main' no "Base branch" e 'main' no "From branch"
- Defina um título explicando o que você está fazendo
- Clique em "Create Pull Request"

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_pull.png" alt="" class="center" style="width:870px;"/>

Após clicar em "Create Pull Request", você cairá nessa tela.

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_pull_feito.png" alt="" class="center" style="width:1183px;"/>

Não se preocupe com a mensagem "Not authorize to merge". O processo ocorreu adequadamente. Somente os usuários admin fazem o merge, em uma rotina de verificação diária.

Ao retornar para tela do 'zelador.bat', você verificará uma mensagem informando que o arquivo com o número de linhas solicitados foi criado no diretório "\linhas\nome_do_arquivo". O nome do arquivo seguirá o padrão tb_procedimento_MM_DD_hh_mm.csv

- MM: mês
- DD: dia
- hh: hora
- mm: minuto

Dessa forma, você conseguirá localizar mais facilmente seus arquivos gerados em diferentes ocasiões.

### Mapeando os termos

Anteriormente orientávamos os participantes a importar os códigos para o Usagi.

A partir de agora, para seguir o mapeamento, seguiremos o caminho de "File" → "Open"

Realize o mapeamento conforme previamente orientado, seguindo as regras de domínios e classes preferenciais apresentadas na aba "Governança" dessa página.

Após finalizar o mapeamento, salve o arquivo por meio do caminho "File" → "Save" para podermos, posterirmente, seguir com a etapa de envio de linhas.

### Subindo linhas mapeadas

Após realizar o mapeamento no Usagi, mova seu arquivo .csv para a pasta "/linhas/upload/"

No Script Zelador, digite a opção 5 e aperte ENTER para iniciar o processo de subir linhas

O script apresentará os arquivos presentes na pasta upload e perguntará qual arquivo que deseja subir.

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_subir.png" alt="" class="center" style="width:536px;"/>

Selecione o arquivo de interesse pelo número e aperte ENTER

Caso o script apresente mensagem de "Erro ao executar o dolt push", digite a opção 4 e aperte ENTER

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_push.png" alt="" class="center" style="width:774px;"/>

Após executar o dolt push, o Script Zelador solicitará que você faça um Pull Request dos termos mapeados.

O Pull Request deve ser feito da mesma forma apresentada na etapa de baixar linhas.

Em alguma situações, caso você tenha feito o mapeamento muito rapidamente, o seu Pull Request anterior pode ainda não ter sido aprovado para merge e surgirá uma mensagem de erro:

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/zelador_pull_erro.png" alt="" class="center" style="width:877px;"/>

Não se preocupe, o commit de seu mapeamento foi registrado. Assim que o Pull Request anterior for aprovado, as modificações solicitadas posteriormente também serão atualizadas.
