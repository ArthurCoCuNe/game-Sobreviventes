library ieee;
use ieee.std_logic_1164.all;

entity clock_div is
    port(
        Clock     : in std_logic;
        Reset     : in std_logic;
        tick_rate : out std_logic
    );
end clock_div;

architecture comportamental of clock_div is
    -- Sinal interno renomeado para ter mais significado
    signal clk_25mhz_reg : std_logic := '0'; 
begin
    process (Clock, Reset)
    begin
        -- Zera o divisor caso o Reset da placa seja acionado
        if Reset = '1' then
            clk_25mhz_reg <= '0';
            
        -- Na borda de subida do clock de 50MHz, inverte o sinal (toggle)
        elsif rising_edge(Clock) then
            clk_25mhz_reg <= not clk_25mhz_reg;
        end if;
    end process;

    -- Atribui o clock dividido para a saída que vai para o módulo vga_sync
    tick_rate <= clk_25mhz_reg;

end comportamental;
