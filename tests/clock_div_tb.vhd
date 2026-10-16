library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_tb is
end entity clock_div_tb;

architecture sim of clock_div_tb is
    -- Periodo de clock (ajuste conforme necessario)
    constant CLK_PERIOD : time := 20 ns;

    -- Sinais locais para conectar na UUT
    signal clk : std_logic := '0';

begin
    -- Instanciacao do circuito (UUT)
    uut: entity work.clock_div
        port map (
        );

    -- Gerador de clock
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

    -- Processo de estimulos de teste
    stim_proc : process
    begin
        -- Aplique seus estimulos de teste aqui
        wait;
    end process;

end architecture sim;
