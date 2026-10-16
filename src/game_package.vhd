library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package game_package is

    -- CONSTANTES GLOBAIS DO JOGO

    constant PLAYER_SIZE   : integer := 16; -- Tamanho da nave em pixels
    constant VELOCIDADE    : integer := 4;  -- Pixels por frame_tick
    
    constant NUM_ASTEROIDS : integer := 10; -- Quantidade máxima de asteroides
    constant NUM_ITEMS     : integer := 4;  -- Quantidade de objetivos a coletar

    -- DEFINIÇÃO DOS TIPOS (ARRAYS)

    type array_coord_itens is array (0 to NUM_ITEMS-1) of std_logic_vector(9 downto 0);
    type array_coord_ast   is array (0 to NUM_ASTEROIDS-1) of std_logic_vector(9 downto 0);

end game_package;
