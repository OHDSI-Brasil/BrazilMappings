---
layout: page
title: Governança do Projeto
subtitle: Como o projeto está organizado
description: Detalhamento da governança do projeto de mapeamento do SIGTAP para OMOP
permalink: /governanca/consenso/
menubar: menu_governanca
show_sidebar: false
---

## Método de Consenso

Os termos são distribuídos para usuários mapear nas seguintes ocasiões:
- O termo ainda não mapeado por pelo menos 3 pessoas E
- O termo ainda não atingiu consenso em entre os participantes

Consideramos consenso quando uma maioria simples, após mapeamento por pelo menos 3 pessoas, indicar o mesmo concept_id com destino para determinado termo.

## Abrindo uma Issue
Contudo, sabemos que a maioria pode em algumas situações não compor o melhor mapeamento.
Por esse motivo, caso um termo tenha chegado a consenso, porém o participante do projeto considerar que o mapeamento proposto não é o melhor para determinado termo, poderá ser aberta uma Issue no próprio DoltHub, sinalizando oportunidade de melhoria no mapeamento desse termo.

[Link para abrir issue](https://www.dolthub.com/repositories/ohdsi-brasil/sigtap_omop/issues?refName=main)

Ao abrir issue, o usuário deve descrever qual o termo que acredita que deveria ter modificação do conceito destino e qual o conceito destino proposto.
As issues abertas serão levadas para reuniões periódicas do grupo de mapeamento para votação se devemos ou não alterar o mapeamento previamente proposto por consenso pelo grupo.
Como regra padrão, o grupo deverá propor mudanças caso o novo conceito proposto se aproxime mais de uma equivalência EQUAL ou EQUIVALENT do que o conceito previamente definido como alvo.
