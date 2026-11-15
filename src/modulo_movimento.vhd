library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.game_package.all; -- Puxa as constantes globais do jogo

entity modulo_movimento is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        frame_tick    : in  std_logic;
        
        -- Botões Direita, Esquerda, Cima, Baixo
        decb_limpo    : in  std_logic_vector(3 downto 0);
        
        -- Saídas para o Gerador Gráfico
        player_x      : out std_logic_vector(9 downto 0);
        player_y      : out std_logic_vector(9 downto 0)
    );
end modulo_movimento;

architecture logica of modulo_movimento is
   
    signal x_reg, x_next : integer range 0 to 639;
    signal y_reg, y_next : integer range 0 to 479;

begin

    -- Memória
    process(clk, reset)
    begin
        if reset = '1' then
            x_reg <= 320 - (PLAYER_SIZE / 2);
            y_reg <= 240 - (PLAYER_SIZE / 2);
        elsif rising_edge(clk) then
            if frame_tick = '1' then
                x_reg <= x_next; 
                y_reg <= y_next; 
            end if;
        end if;
    end process;

   -- Física (Atualização de posição e colisão com paredes)
    process(x_reg, y_reg, decb_limpo)
    begin
        x_next <= x_reg;
        y_next <= y_reg;

        -- Eixo x (Direita / Esquerda)
        -- decb_limpo(3) = Direita, decb_limpo(2) = Esquerda
        
        if decb_limpo(3) = '1' and decb_limpo(2) = '0' then 
            if x_reg < (639 - PLAYER_SIZE - VELOCIDADE) then
                x_next <= x_reg + VELOCIDADE;
            else
                x_next <= 639 - PLAYER_SIZE; 
            end if;
            
        elsif decb_limpo(2) = '1' and decb_limpo(3) = '0' then
            if x_reg > VELOCIDADE then
                x_next <= x_reg - VELOCIDADE;
            else
                x_next <= 0; 
            end if;
        end if;

        -- Eixo y (Cima / Baixo)
        -- decb_limpo(1) = Cima, decb_limpo(0) = Baixo
        if decb_limpo(0) = '1' and decb_limpo(1) = '0' then
            if y_reg < (479 - PLAYER_SIZE - VELOCIDADE) then
                y_next <= y_reg + VELOCIDADE;
            else
                y_next <= 479 - PLAYER_SIZE; 
            end if;
            
        elsif decb_limpo(1) = '1' and decb_limpo(0) = '0' then
            if y_reg > VELOCIDADE then
                y_next <= y_reg - VELOCIDADE;
            else
                y_next <= 0; 
            end if;
        end if;

    end process;

    -- Conversão para bits
    player_x <= std_logic_vector(to_unsigned(x_reg, 10));
    player_y <= std_logic_vector(to_unsigned(y_reg, 10));

end logica;
