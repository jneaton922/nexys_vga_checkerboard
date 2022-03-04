----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2022 11:23:17 PM
-- Design Name: 
-- Module Name: db_tb - Behavioral
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
use work.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity db_tb is
end db_tb;

architecture model of db_tb is

    signal clk    :std_logic := '0';
    signal rst    :std_logic := '1';

    signal button_state : std_logic := '0';
    signal debounced : std_logic;

begin
    dut : entity debounce port map
    ( clk => clk, rst => rst, button_state => button_state, debounced => debounced);

    -- gen clk from slides, run forever at 100 MHz
    genclk: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    -- Reset sequence, run once
    reset_seq: process
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait;
    end process;


    test : process
    begin
        -- simulate "noisy" switch transitions < 100ms
        for i in 0 to 3 loop

            button_state <= '1';
            wait for 100 us;
            button_state <= '0';
            wait for 1 ms;
            button_state <= '1';
            wait for 200 us;
            button_state <= '1';
            wait for 500 us;
            button_state <= '0';
            wait for 250 us;

        end loop;

        button_state <= '1';
        wait for 200 ms;

        -- simulate "noisy" switch transitions < 100ms
        for i in 0 to 3 loop

            button_state <= '1';
            wait for 100 us;
            button_state <= '0';
            wait for 1 ms;
            button_state <= '1';
            wait for 200 us;
            button_state <= '1';
            wait for 500 us;
            button_state <= '0';
            wait for 250 us;

        end loop;

        button_state <= '0';
        wait for 200 ms;
    end process;

end model;
