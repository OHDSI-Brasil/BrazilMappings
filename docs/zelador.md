---
layout: page
title: Script Zelador
subtitle: Gerando escalabilidade para o mapeamento
description: Informações sobre a configuração e uso do script zelador para mapeamento do SIGTAP para OMOP
permalink: /zelador/
menubar: menu_zelador
show_sidebar: false
---

## Instalação

<p style="text-align:center">
	<a class="btn btn-primary" href="#" role="button">Download!</a>
</p>


1. [Baixe o pacote UDZ.zip][1]: esse pacote contém os scripts necessários para realizar o upload e download de novas linhas para mapeamento.
2. Descompactar na pasta desejada (o descompactador nativo do Windows é muito lento para realizar essa operação (poderá demorar quase uma hora); programas como o [7-Zip][2] conseguem realizar essa operação em segundos).
3. A pasta descompactada será o o diretório base. Ela contém:   
	a. dolt/: Dolt e arquivos associados a ele.  
	b. r/: atualiza.R
  c. R-Portable/: versão portátil do R e arquivos associados
  d. config.txt: arquivo nativo de configuração de tabela e base
	e. zelador.bat: Script para executar em Windows.  

[1]:https://www.dropbox.com/s/xsi74obwjl52gpz/zelador_0913.zip?dl=0
[2]:https://www.7-zip.org/download.html
