
-- debouncer.vhd
-- Filtra o ruido mecanico 
-- Um sinal so muda na saida depois de ficar estavel por DEBOUNCE_MS milissegundos.
-- Generic N permite reutilizar o modulo (4 bits para os direcionais,
-- 1 bit para o botao Reset/Play).

library ieee;
use ieee.std_logic_1164.all;

entity debouncer is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;  -- AJUSTAR para o clock da sua placa
        DEBOUNCE_MS : positive := 15;          -- proposta: 10 a 20 ms
        N           : positive := 4            -- largura do barramento de botoes
    );
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;            -- assumido ativo em nivel alto
        decb       : in  std_logic_vector(N - 1 downto 0);
        decb_limpo : out std_logic_vector(N - 1 downto 0)
    );
end entity debouncer;

architecture rtl of debouncer is
    -- Numero de ciclos de clock que a entrada precisa ficar estavel
    constant LIMITE : natural := (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

    type cnt_array is array (0 to N - 1) of natural range 0 to LIMITE;
    signal cnt     : cnt_array := (others => 0);

    signal sync0   : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal sync1   : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal estavel : std_logic_vector(N - 1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sync0   <= (others => '0');
                sync1   <= (others => '0');
                estavel <= (others => '0');
                cnt     <= (others => 0);
            else
                -- Sincronizador de 2 flip-flops (botao e assincrono ao clock)
                sync0 <= decb;
                sync1 <= sync0;

                for i in 0 to N - 1 loop
                    if sync1(i) = estavel(i) then
                        cnt(i) <= 0;                    -- nada mudou
                    elsif cnt(i) = LIMITE - 1 then
                        estavel(i) <= sync1(i);         -- mudanca confirmada
                        cnt(i)     <= 0;
                    else
                        cnt(i) <= cnt(i) + 1;           -- mudanca em teste
                    end if;
                end loop;
            end if;
        end if;
    end process;

    decb_limpo <= estavel;

end architecture rtl;
