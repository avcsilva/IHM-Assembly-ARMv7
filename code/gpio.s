.macro MapeamentoPIO
    @sys_open
    LDR R0, =fileName @ R0 = nome do arquivo
    MOV R1, #2 @ O_RDWR (permissao de leitura e escrita pra arquivo)
    MOV R7, #5 @ sys_open
    SVC 0
    MOV R4, R0 @ salva o descritor do arquivo.

    @sys_mmap2
    MOV R0, #0 @ NULL (SO escolhe o endereco)
    LDR R1, =pagelen
    LDR R1, [R1] @ tamanho da pagina de memoria
    MOV R2, #3 @ protecao leitura ou escrita
    MOV R3, #1 @ memoria compartilhada
    LDR R5, =gpioaddr @ endereco GPIO / 4096
    LDR R5, [R5]
    MOV R7, #192 @sys_mmap2
    SVC 0
    MOV R8, R0
    ADD R8, #0x800 @ endereco base
.endm

.macro GPIOPinIn pino
    LDR R0, =\pino       @ carrega o endereco de memoria do pino
	LDR R1, [R0, #0]	@ offset do registrador de funcao do pino
	LDR R2, [R0, #4]	@ offset do pino no registrador de funcao (LSB)
    LDR R5, [R8, R1]     @ carrega da memoria o registrador pelo endereço base
    MOV R0, #0b111       @ mascara para limpar 3 bits
    LSL R0, R2           @ desloca @111 para posicao do pino no registrador de funcao
    BIC R5, R0           @ limpa os 3 bits da posicao
    STR R5, [R8, R1]    @ armazena o novo valor do registrador de funcao na memoria
.endm

.macro GPIOPinOut pino
    LDR R0, =\pino       @ carrega o endereco de memoria do pino
	LDR R1, [R0, #0] 	@ offset do registrador de funcao do pino
	LDR R2, [R0, #4]	@ offset do pino no registrador de funcao (LSB)
    LDR R5, [R8, R1]     @ carrega da memoria o registrador pelo endereço base
    MOV R0, #0b111       @ mascara para limpar 3 bits
    LSL R0, R2           @ desloca @111 para posicao do pino no registrador
    BIC R5, R0           @ limpa os 3 bits da posição
    MOV R0, #1           @ move 1 para R0
    LSL R0, R2           @ desloca o bit para a posicao de pino no registrador de funcao
    ORR R5, R0           @ adiciona o valor 1 na posicao anteriomente deslocada (0 || 1 = 1)
    STR R5, [R8, R1]     @ armazena o novo valor do registrador de funcao na memoria
.endm

.macro GPIOPinAlto pino
	LDR R0, =\pino @ carrega o endereco de pino
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
    LDR R5, [R8, R1] @ carrega da memoria o registrador pelo endereço base
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2 @ desloca o bit para a posicao do pino no registrador de dados
    ORR R3, R5, R4 @ insere 1 na posicao anteriomente deslocada (0 || 1 = 1)
    STR R3, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
.endm

.macro GPIOPinBaixo pino
    LDR R0, =\pino
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R5, [R8, R1] @ carrega da memoria o registrador pelo endereço base
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2@ desloca para R4 R4 R2 vezes
    BIC R3, R5, R4 @ insere 1 na posicao anteriomente deslocada
    STR R3, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
.endm

@Função para ler o estado de um pino
@R0 = Label do pino
@R1 = retorno da função
GPIOPinEstado:
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
    LDR R3, [R8, R1] @ carrega da memoria o registrador pelo endereço base
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2 @ desloca o que tem em R4 para R4, R2 vezes
    AND R3, R4 @ leitura do bit
    LSR R1, R3, R2 @ deslocamento do bit para o LSB

    BX LR

@ Função para definir nível alto ou baixo de um pino
@ R0 = Label do pino
@ R3 = Valor desejado pro pino
GPIOPinNivel:
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
    LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R4, [R8, R1] @ endereco base + registrador de dados
    CMP R3, #1 @ compara R3 com 1
    BEQ PinAlto @ se R3 == 1, vai para PinAlto, para dar nível logico alto
    BLT PinBaixo @ se R3 < 1, vai para PinBaixo, para dar nível logico baixo

    PinAlto:
    LSL R3, R2 @ desloca R3 (valor 1) para a posicao do pino no registrador de dados
    ORR R4, R3 @ insere 1 na posicao anteriomente deslocada (0 || 1 = 1)
    STR R4, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
    BX LR @ retorna para a função que chamou

    PinBaixo:
    MOV R3, #1 @ move 1 para R3
    LSL R3, R2 @ desloca R3 (valor 1) para a posicao do pino no registrador de dados
    BIC R4, R3 @ limpa a posicao anteriomente deslocada, tornando-a 0
    STR R4, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
    BX LR @ retorna para a função que chamou

@ Macro para ler o estado de um bit em um registrador
@ R0 = registrador na qual se deseja ler
@ R1 = posicao do bit no registrador
@ R3 = retorno da função
EstadoDoBit:
    LSR R0, R1 @ desloca R0 para a direita até que o bit desejado seja o LSB
    MOV R2, #1 @ move 1 para R2
    AND R3, R0, R2 @ leitura do bit (faz operação AND entre R2 e R0) -> salvo em R3 (retorno da macro está em R3)
    BX LR


