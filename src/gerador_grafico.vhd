library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.game_package.all; -- Importa PLAYER_SIZE (16 pixels)

entity gerador_grafico is
    port (
        video_on : in  std_logic;
        pixel_x  : in  std_logic_vector(9 downto 0);
        pixel_y  : in  std_logic_vector(9 downto 0);
        player_x : in  std_logic_vector(9 downto 0);
        player_y : in  std_logic_vector(9 downto 0);
        rgb      : out std_logic_vector(2 downto 0)
    );
end gerador_grafico;

architecture primitivo of gerador_grafico is

    signal pix_x, pix_y : unsigned(9 downto 0);
    signal p_x, p_y     : unsigned(9 downto 0);
    signal player_on    : std_logic;

begin

    -- Conversão de std_logic_vector para unsigned para permitir comparações matemáticas
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    p_x   <= unsigned(player_x);
    p_y   <= unsigned(player_y);

    -- Verifica se a varredura atual do monitor está dentro da caixa do jogador
    player_on <= '1' when (pix_x >= p_x) and (pix_x < p_x + PLAYER_SIZE) and
                          (pix_y >= p_y) and (pix_y < p_y + PLAYER_SIZE) else '0';

    -- Multiplexador de cores com blanking obrigatório fora da área visível
    process (video_on, player_on)
    begin
        if video_on = '0' then
            rgb <= "000"; -- Força preto nas bordas de sincronismo (blanking)
        elsif player_on = '1' then
            rgb <= "010"; -- Cor do jogador: Verde ("100"=Vermelho, "111"=Branco, etc.)
        else
            rgb <= "001"; -- Cor de fundo na área visível: Azul ("000" para fundo preto)
        end if;
    end process;

end primitivo;