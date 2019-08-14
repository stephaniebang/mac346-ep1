
# MAC0346/2019 - Primeiro Exercício-Programa

![GeneralCrit](https://thumbs.gfycat.com/WillingSnoopyBedbug-size_restricted.gif)

Vocês irão implementar um pequeno simulador de combate de *Fire Emblem*
(*Intelligent Systems*, 1990-2019). Mais especificamente, esse enunciado é
baseado nas fórmulas de combate de *Fire Emblem: Path of Radiance*, lançado
para *Game Cube* em 2005. Não, não é o do gif, mas nada supera as animações
dos *Fire Emblems* de *Game Boy Advance*. É só que as fórmulas do *Path of
Radiance* servem melhor o escopo desse EP.

**Este EP é em dupla**.

**Prazo: domingo, 25/8, até as 23h55**

1. [Formato de entrega](#1-formato-de-entrega)
   1. [Código fonte](#11-código-fonte)
   2. [Relatório](#12-relatório)
2. [Especificação do simulador](#2-especificação-do-simulador)
   1. [Estado das unidades](#21-estado-das-unidades)
      + [Formato da entrada](#formato-da-entrada)
   2. [Combate](#22-combate)
      1. [Triângulo de vantagem](#221-triângulo-de-vantagem)
      2. [Ataque duplo](#222-ataque-duplo)
      3. [Chance de acerto](#223-chance-de-acerto)
      4. [Chance de acerto crítico](#224-chance-de-acerto-crítico)
      5. [Dano](#225-dano)
3. [Avaliação](#3-avaliação)

## 1. Formato de entrega

Vocês deverão entregar um arquivo comprimido (zip ou tar.gz) contendo

1. O código fonte em **Lua 5.1** da sua implementação do simulador
   ([Seção 1.1](#11-código-fonte))
2. Um relatório com explicações da sua implementação
   ([Seção 1.2](#12-relatório))

### 1.1 Código fonte

Seu código fonte DEVERÁ CONTER UM MÓDULO LUA CHAMADO **EXATAMENTE**
`simulator.lua`. Esse módulo, por sua vez, deverá fornecer uma função com a
seguinte assinatura:

```lua
result = SIMULATOR.run(scenario_input)
```

Onde:

+ `SIMULATOR` é o módulo obtido ao executar `require "simulator"` na pasta do
  seu código fonte
+ `run` é o NOME EXATO que a função de entrada para sua simulação precisa ter
+ `scenario_input` é uma tabela Lua com os dados de entrada da simulação
  ([detalhes mais adiante](#formato-da-entrada))
+ `result` é uma tabela Lua com os dados do resultado da simulação

Um exemplo de como deve ficar a pasta e o módulo do simulador é a pasta
`sample-simulator` neste repositório. Recomendo usar ele como ponto de partida
para sua implementação.

#### Verificador

Este repositório contém um verificador da simulação junto com alguns cenários
de exemplo. É ele quem fornecerá a tabela `scenario_input` à simulação de vocês,
então vocês não precisam se preocupar com processar entrada em texto. Para usar
o verificador é só usar a linha de comando:

```bash
$ lua fe-check.lua <pasta-do-simulador> <cenário-de-entrada>
```

No caso, sua implementação do simulador deverá estar em `<pasta-do-simulador>`,
enquanto que `<cenário-de-entrada>` pode ser qualquer cenário na pasta
`sample-scenarios` deste reposírio ou outros que vocês fizerem pra testar o
código de vocês.

Esse verificador é exatamente o que será usado para corrigir o EP a menos de
outros cenários de teste que incluirei na correção. **O melhor jeito de saber se
não há problemas no formato de entrega do seu EP é ele funcionar corretamente
no verificador**.

### 1.2 Relatório

Junto com seu código fonte, vocês deverão entregar um relatório em TXT ou PDF
contendo:

1. Nome e número USP da dupla
2. Breve descrição (uma frase) do que cada módulo da sua implementação faz
3. Quais [tarefas](#3-avaliação) vocês completaram
4. Quaisquer outras observações que vocês achem pertinentes para a correção

**O relatório serve, dentre outras coisas, para facilitar a correção e ajudar
vocês a justificarem suas escolhas de implementação**. Por isso, divulgaremos
primeiro a nota dos EPs que estiverem com relatório completo e adequado.

## 2. Especificações do simulador

![Gameplay](https://thumbs.gfycat.com/DapperTimelyKissingbug-size_restricted.gif)

Em *Fire Emblem*, o jogador controla um dos lados em batalhas táticas por turno.
Durante seu turno, o jogador escolhe unidades para mover e atacar unidades
inimigas. **Vocês vão implementar apenas a lógica por traz desses ataques**,
recebendo como entrada:

1. O estado das unidades
2. A sequencia de ataques realizados entre unidades

E deverão devolver como resultado:

+ O estado final das unidades após os ataques

[As fórmulas usadas aqui são simplificações das fórmulas descritas
aqui](serenesforest.net/path-of-radiance/miscellaneous/calculations). Os números
envolvidos são todos inteiros, então quando houver alguma divisão sempre
arredonde para baixo.

Além disso, não é necessário implementar todas as mecânicas descritas aqui, como
explicaremos na [seção sobre a avaliação do EP](#3-avaliação).

### 2.1 Estado das unidades

Unidades em *Fire Emblem*, como na maioria dos RPGs, possuem uma série de
atributos que descrevem suas diversas capacidades:

| Atributo | Abreviação | Explicação |
| --- |:---:| --- |
| Nome | --- | auto-explicativo |
| **Hit Points**  | `HP`  | quanto a unidade pode se machucar antes de morrer |
| **Strength**    | `str` | influencia dano com armas físicas |
| **Magic**       | `mag` | influencia dano com armas mágicas |
| **Skill**       | `skl` | influencia a chance de acertar o oponente |
| **Speed**       | `spd` | influencia a chance de esquiva e de atacar de novo |
| **Luck**        | `lck` | influencia várias estatísticas |
| **Defense**     | `def` | reduz o dano recebido por ataques físicos |
| **Resistence**  | `res` | reduz o dano recebido por ataques mágicos |
| **Trait**       | ---   | determina um vulnerabilidade a certas armas |

Além disso, as unidades sempre atacam usando armas, que possuem seus próprios
atributos:

| Atributo | Abreviação | Explicação |
| --- | --- | --- |
| **Nome**      | ---   | auto-explicativo |
| **Might**     | `mt`  | dano base da arma |
| **Hit**       | ---   | chance base de acertar o oponente |
| **Critical**  | `crt` | chance base de causar acerto crítico |
| **Weight**    | `wt`  | peso da arma, que dificulta ataques múltiplos |
| **Kind**      | ---   | tipo da arma; algumas têm vantagens sobre outras |
| **Effective** | `eff` | característica contra a qual a arma é mais eficaz |

Nesse simulador, o único atributo que mudará durante a simulação é o HP das
unidades e, portanto, é o único que será verificado ao final pelo verificador
automático desse repositório.

#### Formato da entrada

Os estados iniciais das unidade de um cenário de simulação compõem a entrada
do seu programa. Esses dados são fornecidos em uma tabela Lua, que o programa
verificador passa como parâmetro à função `SIMULTOR.run()`. Para saber como os
dados estão organizados nessa tabela, veja os cenários de exemplo na pasta
`sample-scenarios` deste repositório.

Cada arquivo de cenário fornece uma tabela com dois campos: `input` e `output`.
O campo `input` tem o estado das unidades, a estatísticas das armas usadas no
cenário, e a sequência de combates realizados. A campo `output` descreve como
deve estar o estado (no caso, o `hp`) de cada unidade após todos os combates
terem sido realizados.

**ATENÇÃO**. Como *Fire Emblem* usa números pseudo-aleatórios em seus cálculos
de combate, cada cenário tem um campo `seed` que determina a semente usada no
gerador de números automáticos do Lua (`math.randomseed`, veja a [referência
do Lua](http://www.lua.org/manual/5.1/manual.html#5.6)). A semente do gerador
deve ser configurada uma única vez antes que qualquer cálculo de combate seja
feito. Além disso, tome cuidado para não "usar" números aleatórios a mais.
**Falhas em lidar com a geração de números aleatório *irá* afetar o resultado da
sua simulação!**

O *script* `rng-test.lua` pode ser usado para ver a lista gerada pelo RNG do
Lua dada uma certa semente:

```bash
$ lua rng-test.lua <number-of-samples> <seed>
```

### 2.2 Combate

Quando uma unidade combate outra, várias estatísticas são usadas para determinar
o que acontece. A sequencia básica é:

1. Unidade atacante ataca unidade defensora
2. Unidade defensora contra-ataca unidade atacante

Cada ataque:

+ Pode ou não atingir seu alvo
+ Se atingir, pode causar dano crítico

Dependendo da relação entre as velocidades das unidades, pode ser que uma
ataque uma segunda vez. Obviamente, uma unidade morta (zero HP) nunca ataca.

#### 2.2.1 Triângulo de vantagem

Cada tipo de arma (**kind**) tem vantagem contra outra tipo de arma, e
desvantagem contra um terceiro tipo de arma. Quando a arma da unidade atacante
tem vantagem sobre a arma da unidade defensora, a unidade atacante ganha alguns
benefícios. Se ela tiver desvantagem, tem prejuízos. A vantagem ou desvantagem
da arma determina o valor do **triangle bonus** da unidade atacante, que é
usado em outras fórmulas de combate:

| Tipo da arma (**kind**) | sword | axe | lance | wind | thunder | fire |
|:-----------------------:|:-----:|:---:|:-----:|:----:|:-------:|:----:|
| sword                   | 0     | +1  | -1    | 0    | 0       | 0    |
| axe                     | -1    | 0   | +1    | 0    | 0       | 0    |
| lance                   | +1    | -1  | 0     | 0    | 0       | 0    |
| wind                    | 0     | 0   | 0     | 0    | +1      | -1   |
| thunder                 | 0     | 0   | 0     | -1   | 0       | +1   |
| fire                    | 0     | 0   | 0     | +1   | -1      | 0    |

#### 2.2.2 Ataque duplo

O que determina se uma unidade ataca (ou contra-ataca) uma vez adicional é sua
**attack speed**:

| Fator | Fórmula |
| --- | --- |
| `attack speed` | `spd - max(0, wt - str)` |

Se a diferença entre a *attack speed* de duas unidades é 4 ou mais, a que tiver
a maior delas fará um ataque adicional.

#### 2.2.3 Chance de acerto

Dadas uma unidade atacante e uma unidade defensore, a chance de um ataque
acertar (**hit chance**) depende da **accuracy** (`acc`) e do **avoid** (`avo`)
delas, respectivamente.

| Fator | Fórmula | Obervações |
| --- | --- | --- |
| `acc`         | `hit + skl * 2 + lck + triangle bonus * 10` | `hit` da arma |
| `avo`         | `(attack speed * 2) + lck` | atributos do defensor |
| `hit chance`  | `max(0, min(100, acc - avo))` | |

Isso é mais ou menos a "porcentagem" de chance (de 0 a 100) de uma unidade
acertar outra. No entanto, por questões de balanceamento, o jogo não sorteia um
número aleatório uniformemente distribuído entre 0 e 100. Ao invés disso,
*Fire Emblem* sorteia **dois** números aleatórios uniformemente distribuídos
entre 0 e 100 **e usa a média deles**. Se o resultado for menor ou igual ao
**hit chance**, o golpe acerta. **E sim, vocês também devem reproduzir esse
comportamento na implementação de vocês**.

#### 2.2.4 Chance de acerto crítico

Se um ataque acerta, ele tem uma chance de ser um acerto crítico (**critical
chance**). Isso depende da **critical rate** da unidade que ataca e do **dodge**
da unidade que recebe o ataque.

| Fator | Fórmula | Observação |
| ---   | ---     | ---        |
| `critical rate`   | `crt + (skl / 2)` | `crt` vem da arma |
| `dodge`           | `lck`             | atributos da unidade defensora |
| `critical chance` | `max(0, min(100, critical rate - dodge))` | |

A `critical chance`, sim, é uma porcentagem de chance de ocorrer um acerto
crítico. *Fire Emblem* usa apenas um número aleatório uniformemente distribuído
para determinar se houve acerto crítico ou não. Note, no entanto, que **se o
golpe nem acertou, então o jogo NÃO USA NENHUM número aletório**. Isto é, nenhum
número adicional do *random number generator* é consumido se não há porque
calcular um acerto crítico.

#### 2.2.5 Dano

Por fim, se um ataque acertou e foi ou não crítico, precisamos calcular o dano
(**damage**) que efetivamente foi causado na unidade que recebeu o ataque. Isso
basicamente envolve calcular o dano da unidade atacante (**physical power** ou
**magical power**) e subtrair a defesa da unidade defensora (`def` ou `res`).

| Fator | Fórmula  |
| ---   | ---      |
| `physical power`  | `str + (mt + weapon triangle) * eff bonus` |
| `magical power`   | `mag + (mt + weapon triangle) * eff bonus` | 
| `physical damage` | `(physical power - target def) * critical bonus` |
| `magical damage`  | `(magical power - target res) * critical bonus` |

Onde

+ `eff bonus` vale 2 se o `eff` da arma for igual ao `trait` da unidade
  defensora (a arma é particularmente eficaz contra aquele tipo de unidade) ou
  vale 1 caso contrário
+ `critical bonus` vale 3 se o ataque foi um acerto crítico, ou 1 caso contrário
+ o tipo de dano aplicado (`physical damage` ou `magical damage`) depende do
  tipo (`kind`) de arma usada pela unidade atacante:

| Arma | swords, axes, and lances | wind, thunder, and fire |
| ---  | --- | --- |
| Tipo de dano | physical | magical |

## 3. Avaliação

A avaliação será composta da soma de pontos obtidos por realizar diferentes
**tarefas** na sua implementação. A pontuação máxima é 100, mas note que há
tarefas o suficiente para somar mais do que isso. Por exemplo, um trabalho muito
bem escrito que tenha implementado só o combate básico (ver abaixo) pode tirar
90!

NO SEU RELATÓRIO, LEMBRE DE INDICAR QUAIS TAREFAS VOCÊS CUMPRIRAM. Sugiro usar
os códigos!

| Código | Tarefa | Valor máximo |
| --- | --- | --- |
| T01 | Atender o formato de entrega                              | 10 |
| T02 | Executar sem erros                                        | 10 |
| T03 | Relatório completo e adequado                             | 20 |
| T04 | Combate básico (1)                                        | 30 |
| T05 | Acertos críticos                                          | 15 |
| T06 | Triângulo de vantagem                                     | 15 |
| T07 | Armas eficazes                                            | 15 |
| T08 | Mecânicas adicionais (2)                                  | 25 |
| T09 | Passar no [luacheck](https://github.com/mpeterv/luacheck) |  5 |
| T10 | Organizar em módulos (3)                                  |  5 |
| T11 | Organizar em funções (4)                                  |  5 |
| T12 | Nomes claros de variáveis, funções e módulos              |  5 |

(1) Combate básico inclui [ataque duplo](#222-ataque-duplo), [chance de
acerto](#223-chance-de-acerto) e [dano](#225-dano). Para corrigir, usaremos
cenários sem acertos críticos (controlando a semente) e sem armas com vantagens
e desvantagens entre si ou eficazes contra unidade de qualquer tipo.

(2) Qualquer mecânica [descrita
aqui](https://serenesforest.net/path-of-radiance/miscellaneous/calculations/)
que não tenhamos incluído no enunciado. Será exigido cenários de exemplo para
testar essa implementação adicioanl, caso contrário desconsideraremos os pontos
da tarefa.

(3) Pontuação máxima se nenhum módulo tiver mais de 100 linhas (e nenhuma delas
mais de 100 caracteres).

(4) Pontuação máxima se nenhuma função tiver mais de 15 linhas (e nenhuma delas
mais de 100 caracteres).

