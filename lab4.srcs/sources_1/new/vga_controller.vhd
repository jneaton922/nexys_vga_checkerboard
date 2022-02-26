----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2022 03:29:34 PM
-- Design Name: 
-- Module Name: vga_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_controller is
--  Port ( );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        pulse25 : in std_logic;

        HS : out std_logic;
        VS : out std_logic;
        RED : out std_logic_vector(3 downto 0);
        GRN : out std_logic_vector(3 downto 0);
        BLU : out std_logic_vector(3 downto 0)
    );
end vga_controller;

architecture arch of vga_controller is

    -- color definitions
    constant blue : std_logic_vector(11 downto 0) := x"30f";
    constant green : std_logic_vector(11 downto 0) := x"179";

    -- horizontal counter
    signal hcnt : unsigned(9 downto 0);
    signal hspulse : std_logic;

    -- vertical counter
    signal vcnt : unsigned(9 downto 0);
    signal vdisp: std_logic;

    -- 12-bit color data
    signal color : std_logic_vector(11 downto 0);
    signal start_color : std_logic_vector(11 downto 0);

    -- track pixel index
    signal px : unsigned(9 downto 0);
    signal py : unsigned(8 downto 0); 

begin


    -- HSYNC and pixel data
    process (clk, rst)
    begin
        if (rst = '1') then
            -- shut her down!
            hcnt <= (others => '0');
            HS <= '0';
            RED <= x"0";
            GRN <= x"0";
            BLU <= x"0"; 

            px <= (others => '0');
            py <= (others => '0');

        elsif (rising_edge(clk)) then

            -- pulse-enabled counter
            if (pulse25 = '1') then
                hcnt <= hcnt + 1;

                -- HSYNC if tpw has passed (3.84 us = 96 ticks)
                if (hcnt < 96) then
                    HS <= '0';
                    hspulse <= '0';
                elsif (hcnt = 96) then --pulse to trigger vertical count
                    HS <= '1';
                    hspulse <= '1';
                else
                    HS <= '1';
                    hspulse <= '0';
                end if;

                -- data if between porches and valid line (not in vertical retrace), 
                -- else zeros
                if (hcnt >= 96+48 and hcnt < (96+48+640) and vdisp = '1') then
                    RED <= color(11 downto 8);
                    GRN <= color(7 downto 4);
                    BLU <= color(3 downto 0);
                    
                    px <= px + 1; -- increment pixel index
                else 
                    RED <= x"0";
                    GRN <= x"0";
                    BLU <= x"0";
                end if;

                -- toggle blue/green every 32 px
                if (px mod 32 = 0) then
                    if (color = blue) then
                        color <= green;
                    else
                        color <= blue;
                    end if;
                end if;

            end if;

            if (hcnt >= 800) then
                HS <= '0';
                hcnt <= (others => '0');
                px <= (others => '0');
                py <= py + 1;

                if (py mod 32 = 0 ) then
                    if (start_color = green) then
                        start_color <= blue;
                    else
                        start_color <= green;
                    end if;
                end if;

                color <= start_color;

                if (py >= 521
                ) then
                    py <= (others => '0');
                    start_color <= green;
                end if;

            end if;

        end if;
    end process;

    -- VSYNC process, HSYNC-enabled counter;
    process(clk, rst)
    begin

        if (rst = '1') then
            -- shut her down!
            vcnt <= (others => '0');
            vdisp <= '0';
            VS <= '0';
        elsif (rising_edge(clk)) then
            if (pulse25 = '1') then
                if (hspulse = '1') then
                    vcnt <= vcnt + 1;
                    
                    -- vsync if tpw has passed (2 lines)
                    if (vcnt < 2 ) then
                        VS <= '0';
                        vdisp <= '0';
                    else
                        VS <= '1';

                    end if;

                    -- vdisp when between porches, else retracing
                    if (vcnt >= (2+29) and vcnt < (2+29+480)) then
                        vdisp <= '1';
                    else
                        vdisp <= '0';
                    end if;

                    if (vcnt >= 521) then
                        vcnt <= (others => '0');
                        VS <= '0';
                        vdisp <= '0';
                    end if;
                        
                end if;
            end if;
        end if;

    end process;

end arch;
