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
use work.all;

entity testbench_vgactl is
end testbench_vgactl;

architecture model of testbench_vgactl is
    signal clk  :std_logic;
    signal rst  :std_logic;

    signal COLOR  :std_logic_vector(11 downto 0);
    
    signal RED  :std_logic_vector(3 downto 0);
    signal GRN  :std_logic_vector(3 downto 0);
    signal BLU  :std_logic_vector(3 downto 0);
    signal HS      :std_logic;
    signal VS      :std_logic; 

begin
    -- instantiate the controller entity as dut
    dut : entity vga_controller port map
    (clk => clk, rst => rst, COLOR=> COLOR, RED=> RED, GRN => GRN, BLU=> BLU, HS => HS, VS=> VS);

    -- gen clk from slides
    genclk: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    COLOR <= x"0F0";

    -- start off with a reset cycle
    rst <= '1', '0' after 50 ns;

end model;
