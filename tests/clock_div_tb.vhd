library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_tb is
end entity clock_div_tb;

architecture sim of clock_div_tb is
    -- Periodo do clock de entrada (50 MHz = 20 ns)
    constant CLK_PERIOD : time := 20 ns;

    -- Sinais locais para conectar na UUT
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal tick_rate : std_logic;

begin
    -- Instanciacao do circuito (UUT)
    uut: entity work.clock_div
        port map (
            Clock     => clk,
            Reset     => reset,
            tick_rate => tick_rate
        );

    -- Gerador de clock de 50 MHz
    clk_process : process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Processo de estimulo: pulso de reset inicial
    stim_proc : process
    begin
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait;
    end process;

end architecture sim;
