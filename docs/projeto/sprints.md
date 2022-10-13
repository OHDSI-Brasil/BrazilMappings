---
layout: page
title: O Projeto
subtitle: SIGTAP-2-OMOP
description: Detalhes do projeto de mapeamento da "Tabela de Procedimentos, Medicamentos e OPM dos SUS - (SIGTAP)" para OMOP CDM
permalink: /projeto/sprints/
menubar: menu_projeto
show_sidebar: false
---

## Sprint 01
- Período: 08/Jun/2022 - 28/Jun/2022
- Objetivos:
    - Engajar a comunidade a participar do projeto de mapeamento
- Resultados:
    - 117 participantes inscritos
    - 80 participantes entraram no grupo de WhatsApp
- Análise:
    - Consideramos que tivemos um sucesso no número de inscritos, demonstrando o interesse da comunidade em projetos abertos.
    - Temos como desafio manter o engajamento da comunidade nas etapas seguintes do projeto e envolvimento na organização do projeto.
- [Download da Apresentação da Reunião][1]

[1]:https://ohdsi-brasil.github.io/SIGTAP2OMOP/projeto/sprint01.pdf

<iframe width="560" height="315" src="https://www.youtube.com/embed/tbQ6TDkoFqA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Sprint 02
- Período: 04/Jul/2022 - 15/Jul/2022
- Objetivos:
    - Familiarizar os participantes com a ferramenta Usagi
    - Mapear 356 itens do Grupo "06 - Medicamentos" da "Tabela de Procedimentos, Medicamentos e OPM dos SUS - (SIGTAP)" para o domínio Drug do OMOP-CDM
- Resultados:
    - 120 participantes receberam termos para mapear. Tivemos retorno de 21 participantes
    - Desse total, 18 enviaram arquivo em formato correto ("File" → "Save"). 3 participantes enviaram arquivo em formato que não pode ser aproveitado ("Export for review").
    - Todos participantes receberam 10 termos iguais para podermos fazer uma análise inicial de entendimento do processo.
    - Tivemos 2 termos que foram mapeados por pelo menos 3 participantes.
    - Maioria dos participantes (76,2%) considerou o mapeamento um processo de dificuldade média.
    - Muitos participantes indicaram falhas grosseiras no processo de tradução que havíamos implementado (utilização da função GoogleTranslate do GoogleSheets)
- Análise:
    - Necessidade de alinhar o processo de envio do .csv (todos enviarem no formato "File" → "Save")
    - Necessidade de aprimorar o processo de tradução de termos
    - Necessidade de alinhamento conceitual dos processos de equivalência
- [Download da Apresentação da Reunião][2]

[2]:https://ohdsi-brasil.github.io/SIGTAP2OMOP/projeto/sprint02.pdf

<iframe width="560" height="315" src="https://www.youtube.com/embed/fzcWT4LWGoA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Sprint 03
- Período: 27/Jul/2022 - 24/Ago/2022
- Objetivos:
    - Finalizar o mapeamento do domínio "Drugs"
- Resultados:
    - 42 participantes receberam termos para mapear. Tivemos retorno de 23 participantes
    - 2 arquivos vieram em formato incorreto
    - Conseguimos mapear todos os 356 termos por pelo menos 3 participantes
    - Participantes consideraram o mapeamento nessa rodada mais fácil, sendo compatível com o processo da curva de aprendizado.
- Análise:
    - Necessidade de tornar a governança mais descentralizada, escalável e transparente. Ajustaremos nosso processo de upload, download, versionamento e agreement para ferramenta do script Zelador utilizando Dolthub e script em .R
- [Download da Apresentação da Reunião][3]

[3]:https://ohdsi-brasil.github.io/SIGTAP2OMOP/projeto/sprint03.pdf

<iframe width="560" height="315" src="https://www.youtube.com/embed/dNaodyaZ18M" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Sprint 04
- Período: 05/Set - 
- Objetivos:
    - Familiarizar os participantes com o script Zelador e ferramenta Dolthub
    - Mapear os 282 termos cirúrgicos que correspondem por 95% do repasse do SUS. São termos pertencentes ao Grupo "04 - Procedimentos Cirúrgicos" da "Tabela de Procedimentos, Medicamentos e OPM dos SUS (SIGTAP)" e serão mapeados para domínio "Procedure" dos vocabulários padronizados do OMOP CDM
- Resultados:
    - 181 linhas mapeadas no período
    - 8 participantes mapearam linhas
    - 2 participantes reservaram linhas mas não mapearam
- Análise:
    - Redução na participação do grupo devido a incorporação de um novo processo
    - Orientação em relação as dúvidas relativas ao script Zelador
    - Atualmente utilizamos como default para mapeamento o termo com maior similaridade no Usagi. Passaremos a utilizar o termo mapeado em 2018 (caso existente) pois entendemos que boa parte dos termos de 2018 já apresentam bom mapeamento e que o processo atual já permite que seja feito essa mudança sendo possível atribuir o consenso ao grupo e não como decisões individuais.

<iframe width="560" height="315" src="https://www.youtube.com/embed/T53MfwpP5Mg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
<iframe width="560" height="315" src="https://www.youtube.com/embed/rFi0wYoiSW8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
