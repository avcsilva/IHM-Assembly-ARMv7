# Monitoramento de temperatura e Umidade

## Problema II - TEC499 - MI Sistemas Digitais

Professor: Anfranserai Morais Dias

Grupo: Antonio Vitor Costa da Silva, Luis Felipe Pereira de Carvalho e Wesley Ramos dos Santos

## Seções

1. [Introdução](#introdução)
2. [Hardware Utilizado](#hardware-utilizado)
3. [Software Utilizado](#software-utilizado)
4. [Metodologia](#metodologia)
5. [Testes realizados](#testes-realizados)
6. [Problemas](#problemas)
7. [Documentação Utilizada](#documentação-utilizada)
8. [Execução do Projeto](#execução-do-projeto)

## Introdução

Este documento descreve em detalhes o desenvolvimento de um sistema de monitoramento de temperatura e humidade que se utiliza como linguagem o Assembly da arquitetura ARM V7 e implementado em um mini pc da familia Orange PI.

O projeto consiste em um sistema de monitoramento de temperatura e humidade ambiente através de um sensor DHT11, as opções definidas do menu através dos botões e os valores mensurados são apresentados no display LCD 16x2.
Por meio dos botões é possível:

* Navegar entre as opções do menu;
* Verificar o estado de funcionamento do sensor;
* Solicitar a temperatura atual;
* Solicitar a umidade atual;
* Iniciar e parar o sensoriamento contínuo de temperatura;
* Iniciar e parar o sensoriamento contínuo de humidade;

## Hardware Utilizado

O projeto em questão faz uso de hardware específico para seu desenvolvimento, sendo empregada uma placa Orange PI PC Plus, essa vista na figura 1. Esta placa possui notáveis 40 pinos GPIO e é equipada com um processador H3 Quad-core Cortex-A7, com a arquitetura ARM V7 presente no processador.

### Orange Pi PC Plus - Especificações
<div align=center>

![1703101861440](image/README/1703101861440.png)
</br>
</br>
Figura 1 - Placa Orange Pi PC Plus utilizada no projeto
</br>
</br>

</div>

| CPU                    |                                          H3 Quad-core Cortex-A7 H.265/HEVC 4K |
| :--------------------- | ----------------------------------------------------------------------------: |
| GPU                    |                                                        Mali400MP2 GPU @600MHz |
| Memória (SDRAM)       |                                                    1GB DDR3 (shared with GPU) |
| Armazenamento interno  |                                       Cartão MicroSD (32 GB); 8GB eMMC Flash |
| Rede embarcada         |                                                          10/100 Ethernet RJ45 |
| Fonte de alimentação | Entrada DC,`<br>`entradas USB e OTG não servem como fonte de alimentação |
| Portas USB             |                                       3 Portas USB 2.0, uma porta OTG USB 2.0 |
| GPIO                   |                                                                      40 pinos |

### Pinagens

Através da interface GPIO da Orange Pi (figura 2) foi possivel realizar a conexão com o display LCD, os botões usados para navegação e ativação de desativação das medidas do sensor e a placa ESP (microcontroladora) que se conecta ao sensor DHT11:

<div align=center>

![1703101804892](image/README/1703101804892.png)
</br>
</br>
Figura 2 - Interface GPIO da Orange Pi PC Plus
</br>
</br>

</div>

## Software utilizado

Para o desenvolvimento e execução dos códigos, o Visual Studio Code foi utilizado como ferramenta de escrita.

Visual Studio Code (VS Code): é um editor de código-fonte gratuito e de código aberto desenvolvido pela Microsoft. É multiplataforma, altamente extensível, oferece integração com Git, suporte a várias linguagens de programação, ferramentas de depuração integradas e um terminal incorporado.

## Metodologia

### Fluxograma do funcionamento do Sistema

O fluxograma abaixo (figura 3) apresenta a maneira como os componentes do sistema são inicializados:

<div align=center>

![1703696242087](image/README/1703696242087.png)
</br>
</br>
Figura 3 - Fluxograma de funcionamento geral do sistema
</br>
</br>

</div>

O processo de execução do sistema funciona da seguinte forma:

* Inicialmente é realizado o mapeamento de memória das IOUT (pinos de entrada/saída) da Orange Pi de modo que os demais componentes (display, ESP e sensor) sejam corretamente conectados à placa de desenvolvimento e possam ser utilizados;
* Em seguida os pinos são configurados para que atendam ao modo desejado, como sendo de entrada, de saída ou servente à UART da placa;
* É realizado o processo de inicialização do display LCD;
* Após é realizado o mapeamento e a configuração da UART, para que se possa realizar a transmissão e recepção de dados entre a Orange Pi e a placa ESP;
* Por fim, ocorre o processo de apresentação das telas do menu, com as quais sob o uso dos botões são selecionadas e realizadas as ações de seleção de informações, e se encerram quando o usuário tenta retornar à antes da seleção de sensor;

A seguir, são expandidos os processos de mapeamento da memória e inicialização do display e da UART.

### Mapeamento da Memória e configuração dos pinos da GPIO

O mapeamento e configuração dos pinos da interface GPIO da Orange Pi PC Plus para uso em nosso projeto foi realizado da seguinte forma:

1. **Abertura de Arquivo de Dispositivo:**
   * Utiliza `sys_open` para abrir o arquivo associado à memória física (tipicamente `/dev/mem`).
   * Configura permissões para leitura e escrita.
   * Salva o descritor do arquivo para uso posterior.
2. **Mapeamento de Memória com `mmap2`:**
   * Emprega `mmap2` para mapear a memória física dos registros GPIO para o espaço de endereços do processo.
   * Define tamanho da página, proteções de acesso e tipo de mapeamento.
   * O endereço base da GPIO é ajustado e armazenado para acesso posterior.
3. **Configuração de Pinos GPIO:**
   * `GPIOPinIn`: Configura um pino específico como entrada.
   * `GPIOPinOut`: Configura um pino específico como saída.
4. **Manipulação de Estados dos Pinos:**
   * `GPIOPinAlto`: Define um pino como alto (nível lógico alto).
   * `GPIOPinBaixo`: Define um pino como baixo (nível lógico baixo).
   * `GPIOPinEstado`: Lê o estado atual de um pino (alto ou baixo).
5. **Acesso Direto aos Registros:**
   * Realiza operações de leitura e escrita diretamente nos registros da GPIO mapeados.
   * Utiliza o endereço base armazenado para localizar os registros específicos de cada pino.

Para a questão de configuração de direcionamento de pino e leitura/escrita de dado, é importante salientar que todos os offsets para suas localizações e configurações foram registrados em código e foram extraídos do datasheet oficial da Orange Pi PC Plus.

### Fluxograma de funcionamento do Display LCD

<div align=center>

![1703696281516](image/README/1703696281516.png)
</br>
</br>
Figura 4 - Fluxograma de inicialização do display LCD
</br>
</br>

</div>

O processo de execução da inicialização do display funciona no seguinte modo:

Inicialização com Alimentação:

* Processo de inicialização sob tempos especificos (tal qual é solicitado pelo datasheet do display LCD).
* Display inicializado internamente e sem exibição.

Configuração de Função (Primeira Parte):

* Define operação de 4 bits.
* Prepara configuração completa de 4 bits.

Configuração de Função (Segunda Parte):

* Configura a quantidade de linhas a serem utilizadas e a fonte da escrita, sendo no caso, respecticamente, 2 linhas e 5x8 pontos.

Controle de Exibição On/Off:

* Ativa display e cursor.
* Display mostra apenas espaços **(Limpeza da exibição do display)**.

Configuração do Modo de Entrada:

* Modo de incremento, cursor move para direita após escrita.
* Cursor move à direita, display estático.

Escrita de Dados para CGRAM/DDRAM:

* Escrita de dados no display.

### Mapeamento da memória e configuração da UART

As figuras 5 e 6 abaixo se referem a, no fluxograma de funcionamento geral, respectivamente, às etapas de mapeamento e de configuração da UART.

<div align=center>

![1703696105414](image/README/1703696105414.png)
</br>
</br>
Figura 5 - Fluxograma do processo para mapeamento e pré configuração da UART
</br>
</br>

</div>

<div align=center>

![1703696005456](image/README/1703696005456.png)
</br>
</br>
Figura 6 - Fluxograma de configuração da UART
</br>
</br>

</div>

Abaixo, há a explicação dos processo de mapeamento e configuração da UART.

1. **Abertura de Arquivo `/dev/mem`:**

* Acesso ao dispositivo de memória para mapeamento.
* Permissão de leitura e escrita.

2. **Mapeamento com `mmap2`:**

   * Mapeamento da memória física para o espaço de endereçamento virtual do processo.
   * Endereços de GPIO e UART são mapeados para controle.
3. **Habilitação e Configuração do PLL:**

   * Ativação e ajuste do PLL_PERIPH0 para fornecer o clock correto para a UART.
4. **Seleção do Clock para UART3:**

   * Direcionamento específico do clock para UART3.
5. **Controle de Reset da UART3:**

   * Realiza o reset e, em seguida, libera o reset da UART3.
6. **Configuração dos Pinos para RX e TX:**

   * Ajuste dos pinos para as funções de recepção e transmissão da UART.
7. **Ajustes de Parâmetros da UART:**

   * Desabilitação do bit de paridade, definição como 8 bits o tamanho das comunicações via UART e definição do baud rate para 9600.
   * Habilitação de FIFOs e remoção de bloqueios.
8. **Envio e recebimento de Dados:**

   * Transmissão de dados e endereços por meio da UART.
   * Leitura de dados recebidos pela UART, verificando o FIFO.

   ### Fluxograma do Menu

   O fluxograma abaixo na figura 7 apresenta a maneira como é feito o progresso entre as opções do menu do sistema:
   <div align=center>
   
   ![1703696017140](image/README/1703696017140.png)
   </br>
   </br>
   Figura 7 - Fluxograma das telas a serem exibidas no projeto
   </br>
   </br>

   </div>

   São utilizados 3 botões para navegar e selecionar as opções do menu.

   * Os **botões 1 (voltar) e 2 (selecionar)** são utilizados para se movimentar entra as camadas, sendo o botão 1 para retornar (exemplo: Categoria -> Escolha Sensor) e o 2 para avançar (exemplo: Categoria -> Modo), sendo utilizado portanto para selecionar o sensor a ser utilizado e as ações que devem ser realizadas.
   * O **botão 3 (avançar)** é utilizado para se movimentar entre as opções de cada camada nas telas de seleção (exemplo: escolha entre os sensores (0x0F -> 0x01 -> 0x02 -> 0x03) e entre as categorias (temperatura, umidade e status)).

### Processo de exibição

Nas figuras 8, 9 e 10 abaixo são apresentados os fluxogramas dos processos de exibição das informações no display LCD conforme os dados solicitados.

#### Tela de seleção
<div align=center>

![1703696035160](image/README/1703696035160.png)
</br>
</br>
Figura 8 - Fluxograma para formação de uma tela de seleção
</br>
</br>

</div>

* Formação genérica de telas de seleção (sensor, categoria, modo);
* Linha 1 fixa para cada camada, linha 2 varia por opção;

#### Tela de Resultado no modo normal (unica requisição)
<div align=center>

![1703696053075](image/README/1703696053075.png)
</br>
</br>
Figura 9 - Fluxograma para formação de resultado no modo normal
</br>
</br>

</div>

* Linha 1 é a categoria e modo selecionados;
* Linha 2 depende do dado recebido pela UART, podendo representar uma mensagem de erro ou a informação recebida pela UART (como por exemplo a medida de temperatura ou umidade ou se o sensor funciona corretamente);

#### Tela de Resultado no modo contínuo
<div align=center>

![1703696060763](image/README/1703696060763.png)
</br>
</br>
Figura 10 - Fluxograma para formação de resultado no modo contínuo
</br>
</br>

</div>

* Linha 1 é a categoria e modo selecionado;
* Linha 2 depende do dado recebido pela UART tal qual na tela de resultado para o modo normal;
* Diferentemente da tela de resultado para o modo normal, essa tela deve ser atualizada caso não seja pressionado o botão de retorno, de forma a demonstrar o sensoriamento contínuo solicitado;

### Solução do Problema

Para a criação do projeto foi utilizada a linguagem assembly e um subconjunto do conjunto de instruções da arquitetura ARMv7, bem como a utilização do editor de texto Visual Studio Code, para a elaboração dos códigos fonte. O projeto foi sintetizado utilizando um computador de placa única, o Orange PI PC Plus, ao qual foram conectados periféricos como botões de pressão (push buttons), um display LCD de 16x2 caracteres e uma placa ESP (esta previamente programada) para realização da comunicação com um sensor DHT11.

A solução desenvolvida é composta por arquivos fonte assembly (.s) e por um arquivo Make (Makefile), sendo eles:

```
├── gpio.s
├── lcd.s
|── uart.s
├── main.s
└── makefile
```

O arquivo `gpio.s` tem como principal propósito fornecer um conjunto de macros em Assembly para controle direto dos pinos de entrada e saída (GPIO) da Orange Pi, permitindo as operações como mapeamento de memória para acesso aos GPIOs, configuração de pinos como entrada ou saída, definição de estados alto ou baixo para os pinos e leitura de seus estados atuais. Estas funcionalidades são essenciais para interagir com vários componentes de hardware em nível de sistema embarcado.

O arquivo `lcd.s` tem como principal propósito fornecer uma biblioteca de rotinas em Assembly para controlar e interagir com o display LCD utilizado no projeto através de GPIOs da Orange PI. Este arquivo inclui funções para inicialização do LCD, escrita de textos e números, manipulação do cursor, e controle das configurações de exibição, permitindo ao usuário uma interface de baixo nível e flexível para a exibição de dados no LCD.

O arquivo `uart.s` tem como principal propósito configurar e gerenciar a comunicação através da interface UART (Universal Asynchronous Receiver/Transmitter) do projeto. Ele contém macros e funções em Assembly para inicializar e configurar a UART, incluindo o mapeamento de memória necessário, configuração do clock, definição dos parâmetros de transmissão como o baud rate e o tamanho da palavra, e configuração dos pinos para as funções de transmissão e recepção. Além disso, o arquivo fornece funcionalidades para enviar e receber dados, lidando com os detalhes de baixo nível do hardware da UART.

"O arquivo `main.s` tem como principal propósito servir como o código principal do projeto, ele é usado para integralizar os demais códigos e gerenciar a a interface de usuário através de botões e um display LCD, configurando e controlando as comunicações UART para interagir com a ESP e o sensor DHT11, e manipulando entradas e saídas de GPIO. O código está estruturado para inicializar os periféricos necessários, exibir informações e responder a entradas do usuário, mantendo um loop de controle para monitorar e gerenciar as interações do sistema."

O arquivo `makefile` tem como principal propósito automatizar o processo de compilação e montagem do principal arquivo assembly do projeto.

## Documentação utilizada:.

Datasheet da Orange PI PC Plus/AllWinner : Contém todas as informações relacionadas ao funcionamento dos pinos da SBC Orange Pi Pc Plus, bem como seus endereços de memória e informações extras sobre como acessá-las e enviar dados para os pinos relacionados a entrada e saída de propósito geral (GPIO).

Datasheet do display LCD: Como citado anteriormente, o modelo do display LCD é o Hitachi HD44780U, e sua documentação nos permite descobrir o algoritmo responsável pela inicialização do display bem como o tempo de execução de cada instrução, além da representação de cada caractere em forma de número binário

Tabela de syscalls do Linux 32 bits para ARM: Documentação contendo tabela de chamadas ao sistema operacional como chamadas de nanoSleep, ou de escrita para serem executadas

Raspberry Pi Assembly Language Programming, ARM Processor Coding: Livro que mostra diversos casos de exemplo na prática do uso da linguagem Assembly na programação de dispositivos de placa única, no livro foi usado a Raspberry Pi.

## Testes Realizados

Abaixo são aprsentados alguns testes realizados com o proposito de verificar o funcionamento do projeto:
<div align=center>

![1703696082233](image/README/1703696082233.png)
</br>
</br>
Figura 11 - Exemplo de fluxos de testes realizados
</br>
</br>

</div>

No primeiro teste o sensor de endereço 0x0F é selecionado e é verificado o estado de funcionamento do mesmo.

No segundo, através do sensor 0x0F é solicitada a temperatura do ambiente, sendo no modo normal e no modo continuo.

No terceiro, através do sensor 0x0F é solicitada a umidade do ambiente, tanto no modo normal como no continuo.

No quarto teste foi escolhido um dos demais sensorres (**0x01, 0x02 e 0x03**) que é exibido como resposta **'Sens Inex**' o que indique de nenhum desses sensores existem.

No quinto e ultimo teste, foi solicitado novamente o estado de funcionamento do sensor 0x0F, que, ao ser desconectado, acusa estado de '**erro'**.

Durante a realização dos teste pode-se notar que ao solicitar os valores de temperatura e umidade em qualeur um dos modos há o recebimento de valores incorretos (lixo) ou não recebimento de nenhum valor o que pode indicar que há problema no recebimento dos dados mensurados na interface uart do projeto.

## Problemas do Projeto

Durante a construção do projeto foram constatados os seguintes problemas:

* Exibição incorreta dos dados solicitados (lixo ou inexistência dos dados);
* Recebimento de dados incorretos através da UART;
* Leitura incorreta do pressionamento dos botões;

## Execução do projeto:

Em posse do código desse repositório e de um dispositivo com processador de arquitetura ARM, para testar o funcionamento do programa execute o comando:

```
make all
```

#### [Voltar ao topo](#Monitoramento-de-temperatura-e-Umidade)
