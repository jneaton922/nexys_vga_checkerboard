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
        COLOR : in STD_LOGIC_VECTOR(11 downto 0);

        HS : out std_logic;
        VS : out std_logic;
        RED : out std_logic_vector(3 downto 0);
        GRN : out std_logic_vector(3 downto 0);
        BLU : out std_logic_vector(3 downto 0)
    );
end vga_controller;

architecture arch of vga_controller is

    -- 25MHZ pulse output 
    signal pulse25 : std_logic;

    -- horizontal counter
    signal hcnt : unsigned(9 downto 0);
    signal HSpulse : std_logic; -- first HS px cycle, for VSYNC counter

    -- vertical counter
    signal vcnt : unsigned(9 downto 0);
    signal vdisp: std_logic;

begin

    pxclk : entity work.pulse_gen port map (
        clk => clk,
        rst => rst,
        pulse => pulse25,
        trig => x"4" -- 100MHz/4 => 25MHz
    );


    -- HSYNC and pixel data
    process (clk, rst)
    begin
        if (reset = '1') then
            -- shut her down!
            hcnt <= 0;
            HS <= '0';
            RED <= x"0";
            GRN <= x"0";
            BLU <= x"0"; 
        elsif (rising_edge(clk)) then

            -- pulse-enabled counter
            if (pulse25 = '1') then
                hcnt <= hcnt + 1;
                HSpulse <= '0';

                -- HSYNC if tpw has passed (3.84 us = 96 ticks)
                if (HS = '0') then
                    
                    RED <= x"0";
                    GRN <= x"0";
                    BLU <= x"0"; 

                    if (hcnt < 96) then
                        HS <= '0';
                    else
                        HS <= '1';
                        HSpulse <= '1';
                    end if;

                else -- HS is 1

                    -- data if between porches and valid line (not in vertical retrace), 
                    -- else zeros
                    if (hcnt > 96+48 and hcnt < (96+48+640) and vdisp = '1') then
                        RED <= COLOR(11 downto 8);
                        GRN <= COLOR(7 downto 4);
                        BLU <= COLOR(3 downto 0);
                    else 
                        RED <= x"0";
                        GRN <= x"0";
                        BLU <= x"0";
                    end if;

                end if;

            end if;

            if (hcnt >= 800) then
                HS <= '0';
                hcnt <= 0;
            end if;

        end if;
    end process;

    -- VSYNC process, HSYNC-enabled counter;
    process(clk, rst)

        if (reset = '1') then
            -- shut her down!
            vcnt <= 0;
            VS <= '0';
        elsif (rising_edge(clk)) then

            if (HSpulse = '1') then
                vcnt <= vcnt + 1;
                
                
                if (VS = '0') then

                    -- vsync if tpw has passed (2 lines)
                    if (vcnt < 2 ) then
                        VS <= '0';
                        vdisp <= '0';
                    else
                        VS <= '1';
                    end if;

                else -- VS is 1'
                    
                    -- vdisp when between porches, else retracing
                    if (vcnt > (2+29) and vcnt < (2+29+480)) then
                        vdisp <= '1';
                    else
                        vdisp <= '1';
                    end if;
                end if;

                if (vcnt >= 521) then
                    vcnt <= 0;
                    VS <= '0';
                    vdisp <= '0';
                end if;
                    
            end if;
        end if;

    end process;



end arch;