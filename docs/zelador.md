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
	<a class="button is-success is-large is-fullwidth is-rounded" href="https://www.dropbox.com/s/xsi74obwjl52gpz/zelador_0913.zip?dl=1" role="button">Download!</a>
</p>


1. [Baixe o pacote UDZ.zip][1]: esse pacote contém os scripts necessários para realizar o upload e download de novas linhas para mapeamento.
2. Descompactar na pasta desejada (o descompactador nativo do Windows é muito lento para realizar essa operação (poderá demorar quase uma hora); programas como o [7-Zip][2] conseguem realizar essa operação em segundos).

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/7-zip.png" alt="Processo de descompactação" class="center" style="height: 243px; width:956px;"/>

3. A pasta descompactada será o o diretório base. Ela contém:   
    a) dolt/: Dolt e arquivos associados a ele.
    
    b) r/: atualiza.R
    
    c) R-Portable/: versão portátil do R e arquivos associados
    
    d) config.txt: arquivo nativo de configuração de tabela e base
    
    e) zelador.bat: Script para executar em Windows.  

<img src="https://ohdsi-brasil.github.io/SIGTAP2OMOP/img/arquivos.png" alt="Pasta descompactada" class="center" style="height: 155px; width:624px;"/>

[1]:https://www.dropbox.com/s/xsi74obwjl52gpz/zelador_0913.zip?dl=1
[2]:https://www.7-zip.org/download.html
