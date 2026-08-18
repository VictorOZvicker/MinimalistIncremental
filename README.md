# **Incremental Game — Godot**

Um pequeno jogo incremental (idle/clicker) desenvolvido em Godot 4.6 como projeto de estudo.
***
# Sobre o projeto

Sou estudante de Ciência da Computação e comecei este projeto com o objetivo de aprender mais sobre modelagem de sistemas, lógica de programação e organização de código na prática.

A ideia é construir um jogo incremental minimalista, inspirado em jogos como AdVenture Capitalist, Revolution Idle e Clicker Heroes, mas usando o projeto principalmente como uma forma de experimentar e aprender.

O jogo gira em torno de geradores de cores, que produzem dinheiro automaticamente. Conforme a progressão avança, o jogador pode comprar geradores, desbloquear upgrades, organizar itens em inventários e realizar prestígios para obter bônus permanentes.
***
## Tecnologias
- Godot 4.6
- GDScript
- Dados de jogo em JSON

Uma das coisas que estou tentando praticar é manter uma separação clara entre lógica do jogo e interface. Os dados de geradores, upgrades e itens são definidos em JSON, enquanto classes como Player e ProductionCalculator cuidam do estado e dos cálculos.
***
### Principais ideias
- Geradores com produção passiva por ciclo
- Upgrades baseados em categorias e cores
- Sistema de prestígio em múltiplas camadas
- Inventário individual para cada gerador
- Suporte para números extremamente grandes
- Conteúdo definido através de arquivos JSON

O projeto ainda está em desenvolvimento, então algumas mecânicas e sistemas podem mudar bastante durante o processo.

Estado atual

Este é, acima de tudo, um projeto de aprendizado. Algumas partes já funcionam, enquanto outras ainda estão sendo planejadas ou implementadas, como o sistema de save/load, a segunda camada de prestígio e parte do sistema de upgrades.

> Feito para aprender, experimentar e, quem sabe, virar um jogo de verdade no caminho. :)
