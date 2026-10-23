library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer_tb is
end entity debouncer_tb;

architecture sim of debouncer_tb is
    -- Parametros de temporizacao do hardware
    constant CLK_PERIOD      : time := 20 ns;       -- Frequencia de 50 MHz (periodo de 20 ns)
    constant N_BTNS          : positive := 4;        -- Quantidade de botoes do barramento
    constant CLK_FREQ_HZ_VAL : positive := 50_000_000;

    -- Tempo de debounce adotado para simulacao
    -- Configurado em 1 ms para validar a rejeicao com contagem real (50.000 ciclos)
    -- e permitir inspecao grafica sem sobrecarga de memoria (pode ser alterado para 15 ou 20).
    constant DEBOUNCE_MS_VAL : positive := 10;
    constant DEBOUNCE_TIME   : time := DEBOUNCE_MS_VAL * 1 ms;
    constant STABLE_TIME     : time := DEBOUNCE_TIME + 1 ms;

    -- Sinais de conexao com a unidade sob teste (UUT)
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '1';
    signal decb          : std_logic_vector(N_BTNS - 1 downto 0) := (others => '0');
    signal decb_limpo    : std_logic_vector(N_BTNS - 1 downto 0);
    signal sim_terminada : boolean := false;

begin

    -- Instanciacao da unidade sob teste
    uut: entity work.debouncer
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ_VAL,
            DEBOUNCE_MS => DEBOUNCE_MS_VAL,
            N           => N_BTNS
        )
        port map (
            clk        => clk,
            reset      => reset,
            decb       => decb,
            decb_limpo => decb_limpo
        );

    -- Geracao de clock principal de 50 MHz
    -- Interrompe a geracao de pulsos automaticamente ao concluir os testes
    clk_process : process
    begin
        while not sim_terminada loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Procedimento de estimulos: validacao da filtragem e temporizacao
    stim_proc : process
    begin
        -- =====================================================================
        -- Etapa 1: Inicializacao e Reset do circuito
        -- =====================================================================
        reset <= '1';
        decb  <= (others => '0');
        wait for 200 ns;

        reset <= '0';
        wait for 200 ns;

        -- =====================================================================
        -- Etapa 2: Pressionamento do Botao 0 com repique mecanico (Bouncing)
        -- Pulsos transientes na ordem de centenas de microssegundos (< DEBOUNCE_TIME)
        -- devem ser descartados pelo circuito sem afetar a saida decb_limpo(0).
        -- =====================================================================
        decb(0) <= '1'; wait for 200 us;
        decb(0) <= '0'; wait for 150 us;
        decb(0) <= '1'; wait for 300 us;
        decb(0) <= '0'; wait for 200 us;
        decb(0) <= '1'; wait for 250 us;
        decb(0) <= '0'; wait for 100 us;

        -- Sinal mantido em nivel logico alto
        -- Apos decorrido o periodo DEBOUNCE_TIME, decb_limpo(0) transiciona para '1'
        decb(0) <= '1';
        wait for STABLE_TIME;

        -- =====================================================================
        -- Etapa 3: Liberacao do Botao 0 com repique mecanico na soltura
        -- Oscilacoes transitorias durante o desacoplamento mecanico
        -- =====================================================================
        decb(0) <= '0'; wait for 150 us;
        decb(0) <= '1'; wait for 200 us;
        decb(0) <= '0'; wait for 100 us;
        decb(0) <= '1'; wait for 250 us;

        -- Sinal mantido em repouso (nivel baixo)
        -- Confirmacao da transicao de retorno para '0' em decb_limpo(0)
        decb(0) <= '0';
        wait for STABLE_TIME;

        -- =====================================================================
        -- Etapa 4: Acionamento multiplo simultaneo (Botoes 1 e 2)
        -- =====================================================================
        decb(2 downto 1) <= "11"; wait for 200 us;
        decb(2 downto 1) <= "00"; wait for 150 us;
        decb(2 downto 1) <= "11";
        wait for STABLE_TIME;

        decb(2 downto 1) <= "00"; wait for 200 us;
        decb(2 downto 1) <= "11"; wait for 150 us;
        decb(2 downto 1) <= "00";
        wait for STABLE_TIME;

        -- =====================================================================
        -- Encerramento da simulacao
        -- =====================================================================
        sim_terminada <= true;
        wait;
    end process;

end architecture sim;
