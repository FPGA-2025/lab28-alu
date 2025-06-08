# ALU

Este laboratório pertence a uma sequência de laboratórios cumulativos que têm como objetivo final a construção de um pequeno processador.

## O processador

Antes de iniciar o desenvolvimento de um processador, creio ser necessário definir, de forma resumida, o que é um processador. De maneira geral, um processador é um grande circuito lógico composto por vários módulos, capaz de seguir um conjunto de instruções e realizar operações lógicas e aritméticas. Basicamente, ele é capaz de executar um pequeno conjunto de comandos, como, por exemplo, somar A + B e salvar o resultado em C.

Ao longo desta sequência de laboratórios, estaremos desenvolvendo um processador multiciclo e sem pipeline (o motivo ficará mais claro conforme avançamos), baseado no padrão RISC-V. Nosso objetivo será executá-lo em simulações e, posteriormente, em uma FPGA.

## O RISC-V

![RISC-V Logo](imgs/riscv.png)

Como mencionado anteriormente, iremos implementar um processador baseado no padrão RISC-V. Provavelmente, você deve estar se perguntando: o que é RISC-V?

Antes de explicar o que é o RISC-V, precisamos introduzir dois conceitos cruciais: arquitetura e instruções. Processadores de propósito geral, como os encontrados em computadores pessoais e microcontroladores, operam com base em instruções. Em resumo, você fornece uma instrução ao processador, e, com base nela, ele executa uma tarefa — seja somar dois números ou realizar alguma outra operação lógica.

Agora que entendemos como os computadores lidam com instruções, podemos definir de forma mais clara o que é arquitetura. Basicamente, uma arquitetura determina a organização interna dos componentes de um processador, incluindo o número de registradores, o modo como os dados são manipulados, o acesso à memória e aos periféricos, entre outras características. Além disso, ela especifica o conjunto de instruções que o processador pode executar. Esse conjunto é frequentemente chamado de ISA (Instruction Set Architecture). Assim, todos os processadores que compartilham uma mesma arquitetura devem ser capazes de executar as mesmas instruções. Essa uniformidade é extremamente útil quando diferentes desenvolvedores criam processadores que precisam ser compatíveis com o mesmo sistema operacional ou software.

Dessa forma, o RISC-V se destaca como mais um conjunto de instruções, mas difere dos demais em dois aspectos fundamentais. Primeiro, é um padrão completamente aberto, permitindo seu uso para fins comerciais sem a necessidade de licenciamento. Segundo, é uma arquitetura RISC — ou seja, Reduced Instruction Set Computer —, que significa um conjunto de instruções reduzido.

As arquiteturas RISC partem do princípio de que um conjunto de instruções menor e mais simples pode oferecer o mesmo desempenho que um conjunto maior e mais complexo. Isso se deve, principalmente, ao fato de que instruções complexas exigem mais ciclos de clock para serem executadas e demandam um hardware mais robusto.

## A ALU

A ALU (do inglês *Arithmetic and Logic Unit*, ou em português, Unidade Lógica e Aritmética – ULA) é a parte do processador responsável por realizar operações aritméticas e lógicas, como AND, OR, XOR, soma e subtração. Seu funcionamento é muito parecido com o de uma calculadora, com a principal diferença sendo a forma como a ALU recebe suas entradas e fornece suas saídas dentro de um sistema digital.

### Como funciona a ALU

A ALU que será implementada possui **3 entradas** e **2 saídas**:

**Entradas:**

* `ALU_OP_i`: código da operação a ser executada (4 bits)
* `ALU_RS1_i`: primeiro operando (32 bits)
* `ALU_RS2_i`: segundo operando (32 bits)

**Saídas:**

* `ALU_RD_o`: resultado da operação (32 bits)
* `ALU_ZR_o`: sinal que indica se o resultado é zero (1 bit)

#### Convenção de nomes

Todos os sinais seguem uma convenção de nomeação que ajuda a identificar sua função e direção:

* O prefixo `ALU_` indica que o sinal pertence ao módulo da ALU.
* O sufixo `_i` indica que o sinal é uma **entrada** (*input*).
* O sufixo `_o` indica que o sinal é uma **saída** (*output*).

Essa padronização facilita a leitura do código e a identificação do fluxo de dados, o que é uma boa prática no desenvolvimento de hardware.

### Operações da ALU

A ALU deve ser capaz de realizar todas as operações listadas abaixo, cada uma identificada por seu respectivo *opcode* de 4 bits:

| Operação              | Descrição                                     | Opcode    |
| --------------------- | --------------------------------------------- | --------- |
| `AND`                 | Operação lógica E entre os operandos          | `4'b0000` |
| `OR`                  | Operação lógica OU                            | `4'b0001` |
| `XOR`                 | Operação lógica OU exclusivo                  | `4'b1000` |
| `NOR`                 | Operação lógica NOR (negação do OR)           | `4'b1001` |
| `SUM`                 | Soma entre os operandos                       | `4'b0010` |
| `SUB`                 | Subtração entre os operandos                  | `4'b1010` |
| `EQUAL`               | Retorna 1 se os operandos são iguais, senão 0 | `4'b0011` |
| `GREATER_EQUAL`       | Retorna 1 se RS1 ≥ RS2 (com sinal), senão 0   | `4'b1100` |
| `GREATER_EQUAL_U`     | Retorna 1 se RS1 ≥ RS2 (sem sinal), senão 0   | `4'b1101` |
| `SLT` (Set Less Than) | Retorna 1 se RS1 < RS2 (com sinal), senão 0   | `4'b1110` |
| `SLT_U`               | Retorna 1 se RS1 < RS2 (sem sinal), senão 0   | `4'b1111` |
| `SHIFT_LEFT`          | Deslocamento lógico à esquerda                | `4'b0100` |
| `SHIFT_RIGHT`         | Deslocamento lógico à direita                 | `4'b0101` |
| `SHIFT_RIGHT_A`       | Deslocamento aritmético à direita (com sinal) | `4'b0111` |

> **Nota:** A ALU é um circuito **combinacional**, ou seja, sua saída depende **somente das entradas no momento atual**, sem uso de memória ou registros internos.

#### Sugestão de uso: `localparam` para facilitar o código

Para simplificar a escrita e a legibilidade do código Verilog, você pode definir os opcodes como constantes usando `localparam`, como no exemplo abaixo:

```verilog
// Definição dos opcodes da ALU
localparam AND             = 4'b0000;
localparam OR              = 4'b0001;
localparam XOR             = 4'b1000;
localparam NOR             = 4'b1001;
localparam SUM             = 4'b0010;
localparam SUB             = 4'b1010;
localparam EQUAL           = 4'b0011;
localparam GREATER_EQUAL   = 4'b1100;
localparam GREATER_EQUAL_U = 4'b1101;
localparam SLT             = 4'b1110;
localparam SLT_U           = 4'b1111;
localparam SHIFT_LEFT      = 4'b0100;
localparam SHIFT_RIGHT     = 4'b0101;
localparam SHIFT_RIGHT_A   = 4'b0111;
```

> **Dica:** Usar `localparam` ajuda a manter o código mais limpo e fácil de atualizar, especialmente em blocos `case`.

## Atividade

Implemente o módulo `ALU` em **Verilog**. Use o seguinte template como ponto de partida:

```verilog
module Alu (
    input  wire [3:0]  ALU_OP_i,
    input  wire [31:0] ALU_RS1_i,
    input  wire [31:0] ALU_RS2_i,
    output  reg [31:0] ALU_RD_o,
    output wire ALU_ZR_o
);
    // Insira seu código aqui
endmodule
```


## Execução da atividade

Siga o modelo de módulo já fornecido e utilize o testbench e scripts de execução para sua verificação. Em seguida, implemente o circuito de acordo com as especificações e, se necessário, crie outros testes para verificá-lo.

Uma vez que estiver satisfeito com o seu código, execute o script de testes com `./run-all.sh`. Ele mostrará na tela `ERRO` em caso de falha ou `OK` em caso de sucesso.

## Entrega

Realize um *commit* no repositório do **GitHub Classroom**. O sistema de correção automática irá validar sua implementação e atribuir uma nota com base nos testes.

> **Dica:**  
Não altere os arquivos de correção! Para entender como os testes funcionam, consulte o script `run.sh` disponível no repositório.
