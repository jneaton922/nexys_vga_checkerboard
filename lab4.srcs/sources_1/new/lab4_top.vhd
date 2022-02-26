----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2022 03:27:00 PM
-- Design Name: 
-- Module Name: lab4_top - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab4_top is
    Port (
        -- 100MHz system clock
        clk : in std_logic;

        -- active high reset switch
        RESET_SW : in std_logic;

        -- push buttons
        BTNU : in STD_LOGIC;
        BTND : in STD_LOGIC;
        BTNL : in STD_LOGIC;
        BTNR : in STD_LOGIC;

        -- VGA
        RED : out std_logic_vector(3 downto 0);
        GRN : out std_logic_vector(3 downto 0);
        BLU : out std_logic_vector(3 downto 0);
        VS : inout std_logic;
        HS : inout std_logic;

        -- 7 segment signals
        SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0);
        AN : out STD_LOGIC_VECTOR (7 downto 0)
    );

end lab4_top;

architecture arch of lab4_top is

    signal reset : std_logic; -- signal to assert reset downstream to other entites
    signal pulse : std_logic; -- capture output from pulse generator

    -- 4-bit hex for each 7 segment character
    signal c1 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c2 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c3 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c4 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c5 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c6 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c7 :  STD_LOGIC_VECTOR(3 downto 0);
    signal c8 :  STD_LOGIC_VECTOR(3 downto 0);
    
     -- 25MHZ pixel clock
    signal pulse25 : std_logic;


begin

    seg7 : entity work.seg7_controller port map (
        clk => clk,
        rst => reset,
        c1 => c1,
        c2 => c2,
        c3 => c3,
        c4 => c4,
        c5 => c5,
        c6 => c6,
        c7 => c7,
        c8 => c8,
        anodes => AN,
        cathodes => SEG7_CATH
    );

    pxclk : entity work.pulse_gen port map (
        clk => clk,
        rst => reset,
        pulse => pulse25,
        trig => x"0000003" -- 100MHz/4 => 25MHz
    );

    vga : entity work.vga_controller port map (
        clk => clk,
        rst => reset,
        pulse25 => pulse25,
        HS => HS,
        VS => VS,
        RED => RED,
        GRN => GRN,
        BLU => BLU
    );

    process (clk, RESET_SW)
    begin
        if (RESET_SW = '1') then
            reset <= '1';
        elsif (rising_edge(clk)) then
            -- do stuff
            reset <= '0';

        end if;

    end process;


    c1 <= x"F";
    c2 <= x"E";
    c3 <= x"E";
    c4 <= x"B";
    c5 <= x"D";
    c6 <= x"A";
    c7 <= x"E";
    c8 <= x"D";
end arch;
