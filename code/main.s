.include "gpio.s"
.include "uart.s"
.include "lcd.s"

.global _start
_start:
    MapeamentoPIO

    @Inicio configuração de pino do LCD
    GPIOPinOut PG7 @DB7
    GPIOPinOut PG6 @DB6
    GPIOPinOut PG9 @DB5
    GPIOPinOut PG8 @DB4
    GPIOPinOut PA18 @Enable
    GPIOPinOut PA2 @RS
    @Fim configuração de pino do LCD

    inicializaLCD
    @Inicio configuração de pinos
    UARTPinConfig PA13
    UARTPinConfig PA14
    GPIOPinIn PA7 @Botão 1 (Voltar)
    GPIOPinIn PA10 @Botão 2 (Selecionar)
    GPIOPinIn PA20 @Botão 3 (Avançar)
    @Fim configuração de pinos

    MapeamentoUART
    UARTConfig
    
    
    
    tela_sensor1:
        BL limpaDisplay
        LDR R6, =sensor_l1
        MOV R7, #19
        BL escreveLinha
        BL segundaLinha
        LDR R6, =sensor_l2_1
        MOV R7, #4
        BL escreveLinha
        botaotela_sensor1:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
      
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria1
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor2
            B botaotela_sensor1

    tela_sensor2:
        BL limpaDisplay
        LDR R6, =sensor_l1
        MOV R7, #19
        BL escreveLinha
        BL segundaLinha
        LDR R6, =sensor_l2_2
        MOV R7, #4
        BL escreveLinha
        botaotela_sensor2:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
         
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor_inexistente
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor3
            B botaotela_sensor2

    tela_sensor3:
        BL limpaDisplay
        LDR R6, =sensor_l1
        MOV R7, #19
        BL escreveLinha
        BL segundaLinha
        LDR R6, =sensor_l2_3
        MOV R7, #4
        BL escreveLinha
        botaotela_sensor3:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
         
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor_inexistente
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor4
            B botaotela_sensor3

    tela_sensor4:
        BL limpaDisplay
        LDR R6, =sensor_l1
        MOV R7, #19
        BL escreveLinha
        BL segundaLinha
        LDR R6, =sensor_l2_4
        MOV R7, #4
        BL escreveLinha
        botaotela_sensor4:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
       
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor_inexistente
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor1
            B botaotela_sensor4

    tela_categoria1:
        BL limpaDisplay
        LDR R6, =categoria_l1
        MOV R7, #14
        BL escreveLinha
        BL segundaLinha
        LDR R6, =categoria_l2_1
        MOV R7, #11
        BL escreveLinha
        botaotela_categoria1:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor1
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modotemp1
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria2
            B botaotela_categoria1

    tela_categoria2:
        BL limpaDisplay
        LDR R6, =categoria_l1
        MOV R7, #14
        BL escreveLinha
        BL segundaLinha
        LDR R6, =categoria_l2_2
        MOV R7, #7
        BL escreveLinha
        botaotela_categoria2:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor1
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modoumid1
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria3
            B botaotela_categoria2

    tela_categoria3:
        BL limpaDisplay
        LDR R6, =categoria_l1
        MOV R7, #14
        BL escreveLinha
        BL segundaLinha
        LDR R6, =categoria_l2_3
        MOV R7, #6
        BL escreveLinha
        botaotela_categoria3:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor1
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_result_status
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria1
            B botaotela_categoria3

    tela_modotemp1:
        BL limpaDisplay
        LDR R6, =modo_l1
        MOV R7, #4
        BL escreveLinha
        BL segundaLinha
        LDR R6, =modo_l2_1
        MOV R7, #6
        BL escreveLinha
        botaotela_modotemp1:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria1
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_result_temp_normal
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modotemp2
            B botaotela_modotemp1

    tela_modotemp2:
        BL limpaDisplay
        LDR R6, =modo_l1
        MOV R7, #4
        BL escreveLinha
        BL segundaLinha
        LDR R6, =modo_l2_2
        MOV R7, #8
        BL escreveLinha
        botaotela_modotemp2:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria1
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_result_temp_continuo
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modotemp1
            B botaotela_modotemp2

    tela_modoumid1:
        BL limpaDisplay
        LDR R6, =modo_l1
        MOV R7, #4
        BL escreveLinha
        BL segundaLinha
        LDR R6, =modo_l2_1
        MOV R7, #6
        BL escreveLinha
        botaotela_modoumid1:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria2
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_result_umid_normal
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modoumid2
            B botaotela_modoumid1

    tela_modoumid2:
        BL limpaDisplay
        LDR R6, =modo_l1
        MOV R7, #4
        BL escreveLinha
        BL segundaLinha
        LDR R6, =modo_l2_2
        MOV R7, #8
        BL escreveLinha
        botaotela_modoumid2:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria2
            LDR R0, =PA10
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_result_umid_continuo
            LDR R0, =PA20
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modoumid1
            B botaotela_modoumid2

    tela_result_temp_normal:
        BL limpaDisplay
        LDR R6, =result_l1_1
        MOV R7, #16
        BL escreveLinha
        BL segundaLinha
        LDR R0, =temperatura
        LDR R3, =endrSensor
        BL Enviar
        espera tempoZero tempo5ms
        BL Receber
        LDR R5, =erro
        CMP R0, R5
        BEQ tela_temp_normal_erro
        BL escreveDez
        LDR R5, =graus
        BL enviaDado
        botaotela_result_temp_normal:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modotemp1
            B botaotela_result_temp_normal
        tela_temp_normal_erro:
            LDR R6, =result_l2_2
            MOV R7, #4
            BL escreveLinha
            B botaotela_result_temp_normal

    tela_result_temp_continuo:
        LDR R0, =temperaturaContinuo
        LDR R3, =endrSensor
        BL Enviar
        loop_temp_cont:
        BL limpaDisplay
        LDR R6, =result_l1_2
        MOV R7, #18
        BL escreveLinha
        BL segundaLinha
        BL Receber
        MOV R11, #0
        LDR R5, =erro
        CMP R0, R5
        BEQ tela_temp_continuo_erro
        BL escreveDez
        LDR R5, =graus
        BL enviaDado
        botaotela_result_temp_continuo:
            ADD R11, #1
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ saindo_temp_continuo
            CMP R11, #500
            BEQ loop_temp_cont
            B botaotela_result_temp_continuo
        tela_temp_continuo_erro:
            LDR R6, =result_l2_2
            MOV R7, #4
            BL escreveLinha
            B botaotela_result_temp_continuo
        saindo_temp_continuo:
            LDR R0, =fimTempContinuo
            LDR R3, =endrSensor
            BL Enviar
            espera tempoZero tempo5ms
            BL Receber
            LDR R5, =confirm_fim_temp
            CMP R1, R5
            BEQ tela_modotemp2
            BNE tela_temp_continuo_erro
            B tela_result_temp_continuo

    tela_result_umid_normal:
        BL limpaDisplay
        LDR R6, =result_l1_3
        MOV R7, #16
        BL escreveLinha
        BL segundaLinha
        LDR R0, =umidade
        LDR R3, =endrSensor
        BL Enviar
        espera tempoZero tempo5ms
        BL Receber
        LDR R5, =erro
        CMP R0, R5
        BEQ tela_umid_normal_erro
        BL escreveDez
        LDR R5, =porcent
        BL enviaDado
        botaotela_result_umid_normal:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modoumid1
            B botaotela_result_umid_normal
            tela_umid_normal_erro:
            LDR R6, =result_l2_2
            MOV R7, #4
            BL escreveLinha
            B botaotela_result_umid_normal

    tela_result_umid_continuo:
        LDR R0, =umidadeContinuo
        LDR R3, =endrSensor
        BL Enviar
        loop_umid_cont:
        BL limpaDisplay
        LDR R6, =result_l1_4
        MOV R7, #18
        BL escreveLinha
        BL segundaLinha
        BL Receber
        MOV R11, #0
        LDR R5, =erro
        CMP R0, R5
        BEQ tela_umid_continuo_erro
        BL escreveDez
        LDR R5, =porcent
        BL enviaDado
        botaotela_result_umid_continuo:
            ADD R11, #1
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_modoumid2
            CMP R11, #500
            BEQ loop_umid_cont
            B botaotela_result_umid_continuo
        tela_umid_continuo_erro:
            LDR R6, =result_l2_2
            MOV R7, #4
            BL escreveLinha
            B botaotela_result_umid_continuo
        saindo_umid_continuo:
            LDR R0, =fimUmidContinuo
            LDR R3, =endrSensor
            BL Enviar
            espera tempoZero tempo5ms
            BL Receber
            LDR R5, =confirm_fim_umid
            CMP R1, R5
            BEQ tela_modoumid2
            BNE tela_umid_continuo_erro
            B tela_result_umid_continuo

    tela_result_status:
        BL limpaDisplay
        LDR R6, =result_l1_5
        MOV R7, #6
        BL escreveLinha
        BL segundaLinha
        LDR R0, =status
        LDR R3, =endrSensor
        BL Enviar
        espera tempoZero tempo5ms
        BL Receber
        LDR R5, =erro
        CMP R0, R5
        BEQ tela_status_erro
        LDR R5, =funcionando
        CMP R0, R5
        BEQ tela_status_ok
        tela_status_erro:
            LDR R6, =result_l2_2
            MOV R7, #4
            BL escreveLinha
            B botaotela_result_status
        tela_status_ok:
            LDR R6, =result_l2_1
            MOV R7, #2
            BL escreveLinha
            B botaotela_result_status
        botaotela_result_status:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_categoria3
            B botaotela_result_status

    tela_sensor_inexistente:
        BL limpaDisplay
        LDR R6, =result_l2_2
        MOV R7, #4
        BL escreveLinha
        BL segundaLinha
        LDR R6, =result_l3_1
        MOV R7, #14
        BL escreveLinha
        botaotela_sensor_inexistente:
            LDR R0, =PA7
            BL GPIOPinEstado
            CMP R1, #0 @botão apertado
            BEQ tela_sensor1
            B botaotela_sensor_inexistente

    

EXIT:
    MOV R0, #0
    MOV R7, #1
    SVC 0

.data
    fileName: .asciz "/dev/mem"
    uartaddr: .word 0x1C28 @ endereco base do UART3 dividido por 4096 (ou 0x1000) [0x1c28c00 / 0x1000 = 0x1c28]
    gpioaddr: .word 0x1C20 
    pagelen: .word 0x1000
    tempoZero: .word 0
    tempoUm: .word 1
    tempoDois: .word 2
    tempo1ms: .word 1000000
    tempo5ms: .word 5000000
    tempo60us: .word 600000
    tempo150us: .word 150000

    @Inicio códigos de protocolo
    endrSensor: .word 0x0F
    status: .word 0x00
    temperatura: .word 0x01
    umidade: .word 0x02
    temperaturaContinuo: .word 0x03
    umidadeContinuo: .word 0x04
    fimTempContinuo: .word 0x05
    fimUmidContinuo: .word 0x06
    erro: .word 0x1F
    funcionando: .word 0x07
    confirm_fim_temp: .word 0x0A
    confirm_fim_umid: .word 0x0B
    @Fim códigos de protocolo

    @Inicio telas
    @Só pode ter até 16 caracteres por linha
    sensor_l1: .asciz "     Escolha Sensor"
    sensor_l2_1: .asciz "0x0F"
    sensor_l2_2: .asciz "0x01"
    sensor_l2_3: .asciz "0x02"
    sensor_l2_4: .asciz "0x03"

    categoria_l1: .asciz "     Categoria"
    categoria_l2_1: .asciz "Temperatura"
    categoria_l2_2: .asciz "Umidade"
    categoria_l2_3: .asciz "Status"

    modo_l1: .asciz "Modo"
    modo_l2_1: .asciz "Normal"
    modo_l2_2: .asciz "Continuo"

    result_l1_1: .asciz "     Temp Normal"
    result_l1_2: .asciz "     Temp Continuo"
    result_l1_3: .asciz "     Umid Normal"
    result_l1_4: .asciz "     Umid Continuo"
    result_l1_5: .asciz "Status"
    result_l2_1: .asciz "Ok"
    result_l2_2: .asciz "Erro"
    result_l3_1: .asciz "Sens inex"
    result_l3_2: .asciz "Req inex"

    porcent: .asciz "%"
    graus: .asciz "C"
    @Fim telas

    @Botão 1 (Voltar)
    PA7: 
        .word 0x00
        .word 0x1C
        .word 0x7
        .word 0x10

    @Botão 2 (Selecionar)
    PA10: 
        .word 0x04
        .word 0x08
        .word 0xA
        .word 0x10

    @Botão 3 (Avançar)
    PA20: 
        .word 0x08
        .word 0x10
        .word 0x14
        .word 0x10

    @UART3 TX
    PA13: 
        .word 0x04
        .word 0x14
        .word 0xD
        .word 0x10

    @UART3 RX
    PA14: 
        .word 0x04
        .word 0x18
        .word 0x0E
        .word 0x10

    @LCD DB4
    PG8:
        .word 0xDC
        .word 0x00
        .word 0x08
        .word 0xE8

    @LCD DB5
    PG9:
        .word 0xDC
        .word 0x04
        .word 0x09
        .word 0xE8

    @LCD DB6
    PG6:
        .word 0xD8
        .word 0x18
        .word 0x06
        .word 0xE8

    @LCD DB7
    PG7:
        .word 0xD8
        .word 0x1C
        .word 0x07
        .word 0xE8

    @LCD Enable
    PA18:
        .word 0x08
        .word 0x08
        .word 0x12
        .word 0x10

    @LCD RS
    PA2:
        .word 0x00
        .word 0x08
        .word 0x02
        .word 0x10


