library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
    port (
        Clock      : in  std_logic;
        Reset      : in  std_logic;
        tick_rate  : in  std_logic;
        h_sync     : out std_logic;
        v_sync     : out std_logic;
        pixel_x    : out std_logic_vector(9 downto 0);
        pixel_y    : out std_logic_vector(9 downto 0);
        video_on   : out std_logic;
        frame_tick : out std_logic
    );
end vga_sync;

architecture comportamental of vga_sync is

    -- Parâmetros de temporização horizontal (Total = 800 pixels: 0 a 799)
    constant HD : integer := 640; -- Área visível horizontal
    constant HF : integer := 16;  -- Front porch horizontal
    constant HR : integer := 96;  -- Retrace (pulso h_sync)
    constant HB : integer := 48;  -- Back porch horizontal

    -- Parâmetros de temporização vertical (Total = 525 linhas: 0 a 524)
    constant VD : integer := 480; -- Área visível vertical
    constant VF : integer := 10;  -- Front porch vertical
    constant VR : integer := 2;   -- Retrace (pulso v_sync)
    constant VB : integer := 33;  -- Back porch vertical

    -- Contadores internos de 10 bits (0 a 1023)
    signal h_count : unsigned(9 downto 0) := (others => '0');
    signal v_count : unsigned(9 downto 0) := (others => '0');

    -- Registradores de saída para evitar glitches nos pinos de sincronismo
    signal h_sync_reg : std_logic := '1';
    signal v_sync_reg : std_logic := '1';

begin

    -- Processo síncrono: atualiza os contadores e registradores de saída
    process (Clock, Reset)
    begin
        if Reset = '1' then
            h_count    <= (others => '0');
            v_count    <= (others => '0');
            h_sync_reg <= '1';
            v_sync_reg <= '1';
        elsif rising_edge(Clock) then
            -- Avança os contadores apenas quando o pulso de 25 MHz (tick_rate) está ativo
            if tick_rate = '1' then
                -- Contador Horizontal (0 a 799)
                if h_count = (HD + HF + HR + HB - 1) then
                    h_count <= (others => '0');
                    
                    -- Contador Vertical (0 a 524): avança ao fim de cada linha
                    if v_count = (VD + VF + VR + VB - 1) then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
            end if;

            -- Pulso de sincronismo horizontal (ativo em nível baixo '0' entre 656 e 751)
            if (h_count >= (HD + HF)) and (h_count <= (HD + HF + HR - 1)) then
                h_sync_reg <= '0';
            else
                h_sync_reg <= '1';
            end if;

            -- Pulso de sincronismo vertical (ativo em nível baixo '0' entre 490 e 491)
            if (v_count >= (VD + VF)) and (v_count <= (VD + VF + VR - 1)) then
                v_sync_reg <= '0';
            else
                v_sync_reg <= '1';
            end if;
        end if;
    end process;

    -- Habilita a exibição apenas dentro da região visível de 640x480
    video_on <= '1' when (h_count < HD) and (v_count < VD) else '0';

    -- Gera um pulso único de 1 ciclo de Clock a 60 Hz ao fim de cada quadro completo
    frame_tick <= '1' when (tick_rate = '1') and 
                           (h_count = (HD + HF + HR + HB - 1)) and 
                           (v_count = (VD + VF + VR + VB - 1)) else '0';

    -- Atribuição das saídas finais do módulo
    h_sync  <= h_sync_reg;
    v_sync  <= v_sync_reg;
    pixel_x <= std_logic_vector(h_count);
    pixel_y <= std_logic_vector(v_count);

end comportamental;