library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador_grafico_tb is
end entity gerador_grafico_tb;

architecture sim of gerador_grafico_tb is
    signal video_on : std_logic := '1';
    signal pixel_x  : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y  : std_logic_vector(9 downto 0) := (others => '0');
    signal player_x : std_logic_vector(9 downto 0) := (others => '0');
    signal player_y : std_logic_vector(9 downto 0) := (others => '0');
    signal rgb      : std_logic_vector(2 downto 0);

    constant PRETO : std_logic_vector(2 downto 0) := "000";
    constant AZUL  : std_logic_vector(2 downto 0) := "001";
    constant VERDE : std_logic_vector(2 downto 0) := "010";
begin

    uut : entity work.gerador_grafico
        port map (
            video_on => video_on,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            player_x => player_x,
            player_y => player_y,
            rgb      => rgb
        );

    estimulos : process
        -- Coloca um pixel, espera, e confere a cor
        procedure checar (
            px, py    : natural;
            von       : std_logic;
            esperado  : std_logic_vector(2 downto 0);
            descricao : string
        ) is
        begin
            pixel_x  <= std_logic_vector(to_unsigned(px, 10));
            pixel_y  <= std_logic_vector(to_unsigned(py, 10));
            video_on <= von;
            wait for 10 ns;
            assert rgb = esperado
                report "ERRO: " & descricao severity error;
        end procedure;
    begin
        -- Jogador em (100, 200)
        player_x <= std_logic_vector(to_unsigned(100, 10));
        player_y <= std_logic_vector(to_unsigned(200, 10));
        wait for 10 ns;

        checar(105, 205, '1', VERDE, "centro do quadrado");
        checar(100, 200, '1', VERDE, "canto superior esquerdo");
        checar(115, 215, '1', VERDE, "canto inferior direito");
        checar(116, 205, '1', AZUL,  "1 pixel a direita");
        checar(105, 216, '1', AZUL,  "1 pixel abaixo");
        checar( 99, 205, '1', AZUL,  "1 pixel a esquerda");
        checar(105, 199, '1', AZUL,  "1 pixel acima");
        checar(  0,   0, '1', AZUL,  "fundo");
        checar(105, 205, '0', PRETO, "blanking deve ser preto");

        -- Move o jogador para (300, 100)
        player_x <= std_logic_vector(to_unsigned(300, 10));
        player_y <= std_logic_vector(to_unsigned(100, 10));
        wait for 10 ns;

        checar(310, 110, '1', VERDE, "quadrado acompanhou o jogador");
        checar(105, 205, '1', AZUL,  "posicao antiga deve ser fundo");

        report "Testbench do gerador grafico finalizado." severity note;
        wait;
    end process;

end architecture sim;