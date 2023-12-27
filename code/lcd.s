.macro espera seg nanoseg
    .ltorg
    LDR R0, =\seg
    LDR R1, =\nanoseg
    MOV R7, #162
    SVC 0
.endm




@Função para confirmar envio de algo à LCD
enable:
    PUSH {LR}
    @Lembrando: R0 e R3 são parâmetros para "GPIOPinNivel"
    LDR R0, =PA18
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA18
    espera tempoZero tempo1ms
    LDR R0, =PA18
    MOV R3, #1
    BL GPIOPinNivel
    @GPIOPinAlto PA18
    espera tempoZero tempo1ms
    LDR R0, =PA18
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA18
    POP {PC}




.macro inicializaLCD
    @ Inicializa LCD
    GPIOPinBaixo PA2

    GPIOPinBaixo PG7
    GPIOPinBaixo PG6
    GPIOPinAlto PG9
    GPIOPinAlto PG8
    BL enable
    espera tempoZero tempo5ms

    GPIOPinBaixo PA2

    GPIOPinBaixo PG7
    GPIOPinBaixo PG6
    GPIOPinAlto PG9
    GPIOPinAlto PG8
    BL enable
    espera tempoZero tempo150us

    GPIOPinBaixo PA2

    GPIOPinBaixo PG7
    GPIOPinBaixo PG6
    GPIOPinAlto PG9
    GPIOPinAlto PG8
    BL enable
    espera tempoZero tempo150us

    @Início das configurações
    GPIOPinBaixo PA2 @Inicio configura pra 4 bit (Envia 0010 uma única vez)

    GPIOPinBaixo PG7
    GPIOPinBaixo PG6
    GPIOPinAlto PG9
    GPIOPinBaixo PG8 @Fim configura pra 4 bit
    BL enable
    espera tempoZero tempo150us

    configFuncao @ Configura número de linhas e fonte
    espera tempoZero tempo60us
    MOV R5, #0X08
    BL enviaDado @ Primeira chamada de "Display on/off control" (desliga tudo)
    ligaDisplay @ Liga display
    espera tempoZero tempo60us
    BL limpaDisplay
    espera tempoZero tempo60us
    modoEntrada @ Configura modo de entrada
    @Fim geral da inicialização do LCD

    BL retornaOrigem
    espera tempoZero tempo60us

.endm


@ "Function set"
@ DL = Data Length (4 bit = 0)
@ N = Number of display lines (2 linhas = 1)
@ F = Character font (5x8 dots = 0, 5x10 dots = 1)
@ 0 0 1 DL N F - -
@ 0 0 1 0
.macro configFuncao
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2

    @ 0 0 1 0
    @ GPIOPinBaixo PG7
    @ GPIOPinBaixo PG6
    @ GPIOPinAlto PG9 @ Representa Function Set
    @ GPIOPinBaixo PG8 @ DL = 0 (4 bits)
    @ enable

    @ @ 1 0 1 0
    @ GPIOPinAlto PG7 @ Define N = 1
    @ @ F = 0
    @ enable

    MOV R5, #0X28
    BL enviaDado

.endm

@ "Display on/off control"
@ 0 0 0 0 1 D C B
@ 0 0 0 0 1 1 1 0 -> 0x0E
.macro ligaDisplay
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2

    @ GPIOPinBaixo PG7
    @ GPIOPinBaixo PG6
    @ GPIOPinBaixo PG9
    @ GPIOPinBaixo PG8
    @ enable

    @ GPIOPinAlto PG7 @DB3 = 1, indica "Display on/off control"
    @ GPIOPinAlto PG6 @D = 1, liga display
    @ GPIOPinAlto PG9 @C = 1, liga cursor
    @ @B = 0, não pisca cursor
    @ enable

    @enviaDado 0x0E

    @ 0 0 0 0 1 1 0 0 -> 0x0C

    MOV R5, #0X0E
    BL enviaDado
.endm

@Limpa todo o display e define posição inicial (Endereço DRAM = 0)
limpaDisplay:
    PUSH {LR}
    GPIOPinBaixo PA2
    @ GPIOPinBaixo PG7
    @ GPIOPinBaixo PG6
    @ GPIOPinBaixo PG9
    @ GPIOPinBaixo PG8
    MOV R5, #0x01
    BL enviaDado @ 0x01 = 0000 0001
    BL enable
    
    POP {PC}


@Retorna cursor para posição inicial (Endereço DRAM = 0)
retornaOrigem:
    PUSH {LR}
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2z
    MOV R5, #0x02
    BL enviaDado
    .ltorg
    POP {PC}

@ "Entry mode"
@ 0 0 0 0 0 1 I/D S
@ Incrementa 1 a cada entrada (I/D = 1)
@ 0 0 0 0 0 1 1 0 -> 0x06
.macro modoEntrada
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2

    @ GPIOPinBaixo PG7
    @ GPIOPinBaixo PG6
    @ GPIOPinBaixo PG9
    @ GPIOPinBaixo PG8
    @ enable

    @ GPIOPinAlto PG6 @DB2 = 1, indica "Entry mode"
    @ GPIOPinAlto PG9 @I/D = 1, incrementa 1 a cada entrada
    @ @S = 0, não "shifta"
    @ enable

    MOV R5, #0x06
    BL enviaDado
.endm

@DB7 = 1, indica "Set DRAM address"
primeiraLinha:
    PUSH {LR}
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2
    MOV R5, #0x80
    BL enviaDado @ 0x80 = 1000 0000
    POP {PC}

@DB7 = 1, indica "Set DRAM address"
segundaLinha:
    PUSH {LR}
    LDR R0, =PA2
    MOV R3, #0
    BL GPIOPinNivel
    @GPIOPinBaixo PA2
    MOV R5, #0xC0
    BL enviaDado @ 0xC0 = 1100 0000
    POP {PC}

@Função para escrever um número no LCD
@R5 = número a ser escrito
escreveNum:
    PUSH {LR}

    PUSH {R5} @Guarda R5 porque é usado em algumas macros a seguir

    @ Torna alto sinal de RS
    GPIOPinAlto PA2

    @ Envia os 4 primeiros bits como 0011, de acordo com datasheet pág 18 (tabela 4)
    GPIOPinBaixo PG7
    GPIOPinBaixo PG6
    GPIOPinAlto PG9
    GPIOPinAlto PG8
    BL enable

    @ Envia os 4 últimos bits do número (binário comum de 0 a 9)
    POP {R5} @Recupera R5

    MOV R0, R5
    MOV R1, #3
    BL EstadoDoBit
    LDR R0, =PG7
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #2
    BL EstadoDoBit
    LDR R0, =PG6
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #1
    BL EstadoDoBit
    LDR R0, =PG9
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #0
    BL EstadoDoBit
    LDR R0, =PG8
    BL GPIOPinNivel

    BL enable

    POP {PC}


@Função para escrever um número de 0 a 99
@R0 = número a ser escrito (possível dezena)
escreveDez:
    PUSH {LR}

    MOV R5, #10
    SDIV R6, R0, R5
    MUL R1, R6, R5
    SUB R7, R0, R1
    PUSH {R7} @Guarda R7 pois vai ser modificado quando chamar espera de sistema

    MOV R5, R6
    BL escreveNum

    POP {R7} @Recupera R7
    MOV R5, R7
    BL escreveNum

    POP {PC}


@Função para enviar um dado para o LCD
@(Serve tanto para escrever quanto configurar)
@(Depende apenas de ativar antes PA2/RS)
@R5 = dado a ser enviado
enviaDado:
    PUSH {LR}
    MOV R0, R5
    MOV R1, #7
    BL EstadoDoBit
    LDR R0, =PG7
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #6
    BL EstadoDoBit
    LDR R0, =PG6
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #5
    BL EstadoDoBit
    LDR R0, =PG9
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #4
    BL EstadoDoBit
    LDR R0, =PG8
    BL GPIOPinNivel
    
    BL enable
    
    MOV R0, R5
    MOV R1, #3
    BL EstadoDoBit
    LDR R0, =PG7
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #2
    BL EstadoDoBit
    LDR R0, =PG6
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #1
    BL EstadoDoBit
    LDR R0, =PG9
    BL GPIOPinNivel

    MOV R0, R5
    MOV R1, #0
    BL EstadoDoBit
    LDR R0, =PG8
    BL GPIOPinNivel

    BL enable
    
    POP {PC}

@Função para escrever uma linha sobre o LCD
@R6 = linha a ser escrita
@R7 = tamanho da linha
escreveLinha:
    PUSH {LR}


    LDR R0, =PA2
    MOV R3, #1
    BL GPIOPinNivel

    MOV R10, #0
    loop:
    LDR R5, [R6, R10]
    PUSH {R7}
    BL enviaDado
    POP {R7}
    ADD R10, #1
    CMP R10, R7
    BLT loop

    POP {PC}
