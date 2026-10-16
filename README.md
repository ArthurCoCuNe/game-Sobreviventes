# Jogo 2D Interativo em FPGA

Este é o repositório do projeto para desenvolvimento de um jogo digital 2D interativo implementado em VHDL, utilizando uma placa FPGA.
O jogo é exibido em um monitor padrão através de uma interface VGA na resolução de 640x480 pixels e possui mecânicas inspiradas em *Undertale* e *Asteroids*.

## Equipe
- **Arthur Neves:** VGA e Clock
- **Paola Perim:** Gráficos e Entrada
- **Rodrigo Namora:** FSM e Física

## Estrutura do Projeto
- `src/`: Arquivos de código fonte VHDL (`.vhd`, `.vhdl`). Os principais módulos incluem:
  - `main.vhd`: Módulo principal (Top Level)
  - `clock_div.vhd` e `vga_sync.vhd`: Módulos de clock e sincronismo VGA
  - `fsm_jogo.vhd`: Máquina de estados e lógica de física/colisão
  - `gerador_grafico.vhd`: Renderização gráfica
  - `debouncer.vhd`: Tratamento de ruídos mecânicos dos botões
- `tb/`: Testbenches para validação e simulação isolada e de integração dos módulos
- `sim/`: Scripts de simulação e arquivos de forma de onda (`.vcd`, `.ghw`)

## Ferramentas Recomendadas e Validação
- **Simulador:** GHDL
- **Visualizador de Formas de Onda:** GTKWave
