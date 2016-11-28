-------------------------------------------------------------------------------
-- Title      : Testbench for design "toplevel"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : Burkart Voss  <bvoss@Troubadix>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2016-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-06-23  1.0      bvoss	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity toplevel_tb is

end toplevel_tb;

-------------------------------------------------------------------------------

architecture behaviour of toplevel_tb is
  component toplevel is
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;
      btnR     : in  std_logic;
      btnU     : in  std_logic;
      btnD     : in  std_logic;
      btnL     : in  std_logic;
      btnEnter : in  std_logic;
      sw       : in std_logic_vector(15 downto 0);
      led      : out std_logic_vector(15 downto 0));
  end component toplevel;

  -- component ports
  signal reset    : STD_LOGIC;
  signal clk      : STD_LOGIC:='0';
  signal btnR : std_logic:='0';
  signal btnU : std_logic:='0';
  signal btnD : std_logic:='0';
  signal btnL : std_logic:='0';
  signal btnEnter : std_logic:='0';
  signal sw : std_logic_vector(15 downto 0):="0000000000000000";


begin  -- behaviour

  -- component instantiation
  DUT: toplevel
    port map (
      reset    => reset,
      clk      => clk,
      btnR     => btnR,
      btnU     => btnU,
      btnD     => btnD,
      btnL     => btnL,
      btnEnter => btnEnter,
      sw       => sw);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait for 20ns;
    reset <= '1';
    wait for 101ns;
    reset <= '0';
    wait;

  end process WaveGen_Proc;

  

end behaviour;

-------------------------------------------------------------------------------

configuration toplevel_tb_behaviour_cfg of toplevel_tb is
  for behaviour
  end for;
end toplevel_tb_behaviour_cfg;

-------------------------------------------------------------------------------
