----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2022 10:30:24 AM
-- Design Name: 
-- Module Name: testbench_vgactl - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity testbench_vgactl is
end testbench_vgactl;

architecture model of testbench_vgactl is
    signal clk    :std_logic := '0';
    signal rst    :std_logic := '1';
    signal pulse25    :std_logic := '0';

    signal COLOR  :std_logic_vector(11 downto 0);
    
    signal RED    :std_logic_vector(3 downto 0);
    signal GRN    :std_logic_vector(3 downto 0);
    signal BLU    :std_logic_vector(3 downto 0);
    signal HS     :std_logic;
    signal VS     :std_logic; 
    
begin

    -- instantiate the controller entity as dut
    dut : entity vga_controller port map
    (clk => clk, rst => rst, pulse25 => pulse25, RED=> RED, GRN => GRN, BLU=> BLU, HS => HS, VS=> VS);  

    COLOR(11 downto 8) <= RED;
    COLOR(7 downto 4)  <= GRN;
    COLOR(3 downto 0)  <= BLU;

    -- gen clk from slides, run forever at 100 MHz
    genclk: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    -- gen px clock, run forever
    genp25 : process
    begin
        -- high for one clock cycle of every 4
        pulse25 <= '1';
        wait for 10 ns;
        pulse25 <= '0';
        wait for 30 ns;
    end process; 

    -- Reset sequence, run once
    reset_seq: process
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait;
    end process;
   
    VS_timing_test: process
    begin 
        -- full "frame" should be 16.7 ms
        wait until VS = '1';
        -- VS should stay high for Tdisp+Tfp+Tbp = 16.608 ms
        wait for 16.607 ms;
        assert (VS'stable(16.607 ms) and VS = '1')
            report "VS fell too soon"
            severity error;

        -- VS should fall here
        wait for 2 us;
        assert ((not VS'stable(2 us)) and VS = '0')
            report "VS fell too late"
            severity error;
    
    end process;

    HS_timing_test: process
    begin
        wait until HS = '1';
        -- HS should stay high for Tdisp+Tfp+Tbp = 28.16 us
        wait for 28.15 us;
        assert HS = '1' and HS'stable(28.15 us)
            report "HS fell too soon"
            severity error;

        -- should fall in the next 20 ns
        wait for 20 ns;
        assert HS='0' and (not HS'stable(20 ns))
            report "HS fell too late"
            severity error;

    end process;

    vertical_retrace_test: process
    begin
        -- assert no data within tpw of edges
        wait until VS = '1';
        assert (RED = x"0" and GRN = x"0" and BLU = x"0") report "WARN: non-zero data during retrace" severity error;
        wait for 63 us;
        -- data should have been stable for last tpw+tfp+tbp = 1312 us
        assert (RED'stable(1312 us) and GRN'stable(1312 us) and BLU'stable(1312 us))
            report "WARN: non-zero data during retrace"
            severity warning;    

    end process;
    



end model;
