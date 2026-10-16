library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_package.all;

entity modulo_movimento_tb is
end entity modulo_movimento_tb;

architecture sim of modulo_movimento_tb is
    -- Clock em 60 Hz (1 / 60 s = 16.67 ms, que e o tempo de cada quadro da tela)
    constant CLK_PERIOD : time := 16.67 ms;

    -- Sinais locais para conectar na UUT
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    -- Como o vga_sync ainda nao foi feito, mantemos frame_tick em '1'
    -- para o clock de 60 Hz atualizar a cada frame:
    signal frame_tick : std_logic := '1'; 
    signal decb_limpo : std_logic_vector(3 downto 0) := (others => '0');
    signal player_x   : std_logic_vector(9 downto 0);
    signal player_y   : std_logic_vector(9 downto 0);

begin
    -- Instanciacao do modulo de movimento (UUT)
    uut: entity work.modulo_movimento
        port map (
            clk        => clk,
            reset      => reset,
            frame_tick => frame_tick,
            decb_limpo => decb_limpo,
            player_x   => player_x,
            player_y   => player_y
        );

    -- Gerador de clock a 60 Hz (16.67 ms por ciclo)
    clk_process : process
    begin
        while now < 200 ms loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Processo de testes: boneco no meio e 1 passo em cada direcao possivel
    stim_proc : process
    begin
        -- =====================================================================
        -- 1. Reset inicial: boneco comeca no centro da tela (X=312, Y=232)
        -- =====================================================================
        reset <= '1';
        decb_limpo <= "0000";
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD; -- 1 frame parado no centro

        -- =====================================================================
        -- 2. Anda UMA VEZ para a Direita: decb_limpo(3) = '1'
        -- Esperado: X vai de 312 para 316 (312 + 4)
        -- =====================================================================
        decb_limpo <= "1000";
        wait for CLK_PERIOD;
        decb_limpo <= "0000";
        wait for CLK_PERIOD;

        -- =====================================================================
        -- 3. Anda UMA VEZ para a Esquerda: decb_limpo(2) = '1'
        -- Esperado: X volta de 316 para 312 (316 - 4)
        -- =====================================================================
        decb_limpo <= "0100";
        wait for CLK_PERIOD;
        decb_limpo <= "0000";
        wait for CLK_PERIOD;

        -- =====================================================================
        -- 4. Anda UMA VEZ para Cima: decb_limpo(1) = '1'
        -- Esperado: Y vai de 232 para 228 (232 - 4)
        -- =====================================================================
        decb_limpo <= "0010";
        wait for CLK_PERIOD;
        decb_limpo <= "0000";
        wait for CLK_PERIOD;

        -- =====================================================================
        -- 5. Anda UMA VEZ para Baixo: decb_limpo(0) = '1'
        -- Esperado: Y volta de 228 para 232 (228 + 4)
        -- =====================================================================
        decb_limpo <= "0001";
        wait for CLK_PERIOD;
        decb_limpo <= "0000";
        wait for CLK_PERIOD;

        -- =====================================================================
        -- 6. Diagonal (Cima + Direita): decb_limpo = "1010"
        -- Esperado: X=316, Y=228
        -- =====================================================================
        decb_limpo <= "1010";
        wait for CLK_PERIOD;
        decb_limpo <= "0000";
        wait for CLK_PERIOD;

        -- Fim do teste
        wait;
    end process;

end architecture sim;
