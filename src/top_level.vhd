library ieee;
use ieee.std_logic_1164.all;
use work.game_package.all;

entity main is
    port (
        Clock  : in  std_logic;
        Reset  : in  std_logic;
        decb   : in  std_logic_vector(3 downto 0); -- Direita, Esquerda, Cima, Baixo
        h_sync : out std_logic;
        v_sync : out std_logic;
        RGB    : out std_logic_vector(2 downto 0)
    );
end main;

architecture estrutural of main is

    -- Sinais internos de temporização e controle VGA
    signal tick_rate  : std_logic;
    signal frame_tick : std_logic;
    signal video_on   : std_logic;
    signal pixel_x    : std_logic_vector(9 downto 0);
    signal pixel_y    : std_logic_vector(9 downto 0);

    -- Sinal dos botões filtrado pelo debouncer
    signal decb_limpo : std_logic_vector(3 downto 0);

    -- Sinais de posição do jogador vindos do modulo_movimento
    signal player_x   : std_logic_vector(9 downto 0);
    signal player_y   : std_logic_vector(9 downto 0);

begin

    -- 1. Divisor de Clock (50 MHz -> pulso de 25 MHz)
    inst_clock_div: entity work.clock_div
        port map (
            Clock     => Clock,
            Reset     => Reset,
            tick_rate => tick_rate
        );

    -- 2. Sincronizador VGA (640x480 @ 60Hz)
    inst_vga_sync: entity work.vga_sync
        port map (
            Clock      => Clock,
            Reset      => Reset,
            tick_rate  => tick_rate,
            h_sync     => h_sync,
            v_sync     => v_sync,
            pixel_x    => pixel_x,
            pixel_y    => pixel_y,
            video_on   => video_on,
            frame_tick => frame_tick
        );

    -- 3. Debouncer para os 4 botões direcionais
    inst_debouncer: entity work.debouncer
        generic map (
            CLK_FREQ_HZ => 50_000_000,
            DEBOUNCE_MS => 20,
            N           => 4
        )
        port map (
            clk        => Clock,
            reset      => Reset,
            decb       => decb,
            decb_limpo => decb_limpo
        );

    -- 4. Módulo de Movimento (Física do MVP)
    inst_movimento: entity work.modulo_movimento
        port map (
            clk        => Clock,
            reset      => Reset,
            frame_tick => frame_tick,
            decb_limpo => decb_limpo,
            player_x   => player_x,
            player_y   => player_y
        );

    -- 5. Gerador Gráfico Primitivo (Apenas fundo + bloco do jogador)
    inst_gerador_grafico: entity work.gerador_grafico
        port map (
            video_on => video_on,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            player_x => player_x,
            player_y => player_y,
            rgb      => RGB
        );

end estrutural;