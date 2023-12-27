.macro MapearEConfigCLK
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
    LDR R5, =gpioaddr @ endereco é o mesmo do GPIO praticamente (0x01C20000)
    LDR R5, [R5]
    MOV R7, #192 @sys_mmap2
    SVC 0
    MOV R9, R0

    @Habilitação PLL_PERIPH0
    LDR R0, [R9, #0x28]
    MOV R1, #1
    LSL R1, #0x1F
    ORR R0, R1
    STR R0, [R9, #0x28]

    @Selecionando PLL_PERIPH0 para APB2
    LDR R0, [R9, #0x58]
    MOV R1, #0b11
    LSL R1, #0x18
    BIC R0, R1
    MOV R1, #0b10
    LSL R1, #0x18
    ORR R0, R1
    STR R0, [R9, #0x58]

    @Direcionando clock para a UART3
    LDR R0, [R9, #0x6C]
    MOV R1, #1
    LSL R1, #0x13
    ORR R0, R1
    STR R0, [R9, #0x6C]

    @Ligando o reset da UART3
    LDR R0, [R9, #0x2D8]
    MOV R1, #1
    LSL R1, #0x13
    BIC R0, R1
    STR R0, [R9, #0x2D8]

    @Desligando o reset da UART3
    LDR R0, [R9, #0x2D8]
    MOV R1, #1
    LSL R1, #0x13
    ORR R0, R1
    STR R0, [R9, #0x2D8]
.endm

.macro MapeamentoUART
    @Configura clock e desabilita reset da UART3
    MapearEConfigCLK

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
    LDR R5, =uartaddr @ endereco UART3 / 4096
    LDR R5, [R5]
    MOV R7, #192 @sys_mmap2
    SVC 0
    MOV R9, R0
    ADD R9, #0xC00 @ endereco base
.endm

.macro UARTPinConfig pino
    LDR R0, =\pino       @ carrega o endereco de memoria de ~pin~
	LDR R1, [R0, #0] 	@ offset do registrador de funcao do pino
	LDR R2, [R0, #4]	@ offset do pino no registrador de funcao (LSB)
    LDR R5, [R8, R1]     @ conteudo do registrador de dados do pino
    MOV R0, #0b111       @ mascara para limpar 3 bits
    LSL R0, R2           @ desloca @111 para posicao do pino no registrador
    BIC R5, R0           @ limpa os 3 bits da posição
    MOV R0, #0b011       @ move 011 para R0 (configura como UART3 [RX ou TX])
    LSL R0, R2           @ desloca o bit para a posicao de pino no registrador de funcao
    ORR R5, R0           @ adiciona o valor 1 na posicao anteriomente deslocada
    STR R5, [R8, R1]     @ armazena o novo valor do registrador de funcao na memoria
.endm

@ Baud Rate, Paridade, Bloqueio?, QtBit
.macro UARTConfig
    LDR R1, [R9, #0xC]

    @ configura pra não ter bit de paridade
    MOV R2, #1
    LSL R2, #3
    BIC R1, R2

    @ configura pra enviar/receber 8 bits
    MOV R2, #0b11
    BIC R1, R2
    MOV R2, #0b11
    ORR R1, R2

    @ configura o baud rate (0xFDE -> divisor = 4062,5 -------> 9600 = 624MHz / (16*D))
    MOV R2, #1
    LSL R2, #7
    BIC R1, R2
    ORR R1, R2
    STR R1, [R9, #0xC]
    @ colocando o valor do baud rate no DLL
    LDR R1, [R9, #0]
    MOV R2, #0b11111111
    BIC R1, R2
    MOV R2, #0xFDE
    ORR R1, R2
    STR R1, [R9, #0]

    @ Volta pra RBR/THR
    LDR R1, [R9, #0xC] 
    MOV R2, #1
    LSL R2, #7
    BIC R1, R2
    STR R1, [R9, #0xC]

    @ TIRANDO TODOS OS BLOQUEIOS
    LDR R1, [R9, #0x4] 

    MOV R2, #0b11111111
    BIC R1, R2

    STR R1, [R9, #0x4]

    @ habilitando os fifos (1)
    LDR R1, [R9, #0x8] 
    MOV R2, #1
    BIC R1, R2
    ORR R1, R2
    STR R1, [R9, #0x8]
.endm

@Função para enviar modo (comando) e endereço pela UART
@R0 = Dado a ser enviado
@R3 = Endereço a ser enviado
Enviar:
    LDR R1, [R9, #0x0] 
    MOV R2, #0b11111111
    BIC R1, R2
    ORR R1, R0
    STR R1, [R9, #0x0]

    LDR R1, [R9, #0x0] 
    MOV R2, #0b11111111
    BIC R1, R2
    ORR R1, R3
    STR R1, [R9, #0x0]

    BX LR

@Função para receber/ler um dado da UART
@R0 = Retorno do dado recebido
@R1 = Retorno do comando recebido
Receber:
    @Byte 1 = Dado
    LDR R0, [R9, #0x7C] @Inicio vendo FIFO
    LSR R0, #3
    MOV R1, #1
    AND R0, R1
    CMP R0, #0
    BEQ Receber @Se tá vazio, repete /// Final vendo FIFO
    LDR R0, [R9, #0x0] @Dado recebido

    @Byte 2 = Comando
    Recebe2:
    LDR R1, [R9, #0x7C] @Inicio vendo FIFO
    LSR R1, #3
    MOV R2, #1
    AND R1, R2
    CMP R1, #0
    BEQ Recebe2 @Final vendo FIFO
    LDR R1, [R9, #0x0] @Comando recebido

    BX LR
