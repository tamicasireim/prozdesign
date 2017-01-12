-------------------------------------------------------------------------------
-- Title      : Data Memory
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_memory.vhd
-- Author     : Marie Simatic  <marie@simatic.org>
-- Company    : 
-- Created    : 2016-11-21
-- Last update: 2017-01-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-11-21  1.0      marie   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_processor.all;
use work.ram_pkg.all;

entity data_memory is
  port(clk      : in  std_logic;
       reset    : in  std_logic;
       data_out : out std_logic_vector (7 downto 0);

       -- Memory
       w_e_memory : in std_logic_vector(3 downto 0);
       data_in    : in std_logic_vector(7 downto 0);
       addr       : in std_logic_vector (9 downto 0);

       -- RCALL / RET
       stack_enable  : in  std_logic;
       write_pc_addr : in  std_logic;
       pc_addr       : in  std_logic_vector(pc_size - 1 downto 0);
       pc_addr_out   : out std_logic_vector(pc_size - 1 downto 0)

       );
end data_memory;

architecture Behavioral of data_memory is
  signal stack_pointer   : std_logic_vector(9 downto 0);
  signal local_adress : std_logic_vector(9 downto 0);
  signal ram_data : std_logic_vector(7 downto 0);
  signal local_we : std_logic ;

  component xilinx_single_port_ram_write_first is
    generic (
      RAM_WIDTH       : integer;
      RAM_DEPTH       : integer;
      RAM_PERFORMANCE : string;
      INIT_FILE       : string);
    port (
      addra  : in  std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);
      dina   : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      clka   : in  std_logic;
      wea    : in  std_logic;
      ena    : in  std_logic;
      rsta   : in  std_logic;
      regcea : in  std_logic;
      douta  : out std_logic_vector(RAM_WIDTH-1 downto 0));
  end component xilinx_single_port_ram_write_first;

begin
  xilinx_single_port_ram_write_first_1: entity work.xilinx_single_port_ram_write_first
    generic map (
      RAM_WIDTH       => 8,
      RAM_DEPTH       => 1024,
      RAM_PERFORMANCE => "LOW_LATENCY",
      INIT_FILE       => "")
    port map (
      addra  => local_adress,
      dina   => data_in,
      clka   => clk,
      wea    => local_we,
      ena    => '1',
      rsta   => reset,
      regcea => '1',
      douta  => ram_data);

  stack_process : process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        stack_pointer <= (others => '1');
      else
        if write_pc_addr = '1' then
          null;                         -- RCALL / RET
        elsif stack_enable = '1' then
          if w_e_memory = id_memory then
            stack_pointer <= std_logic_vector(unsigned(stack_pointer) - 1);
          else
            stack_pointer <= std_logic_vector(unsigned(stack_pointer) + 1);
          end if;
        end if;
      end if;
    end if;
  end process stack_process;

  local_adress_process : process (stack_pointer, stack_enable, addr, local_we)
  begin
    if stack_enable = '1' then
      if local_we = '1' then
        -- push
        local_adress <= stack_pointer;
      else
        local_adress <= std_logic_vector(unsigned(stack_pointer) + 1);
      end if;
    else
      local_adress <= addr;
    end if;
  end process local_adress_process;

  -- data out multiplexor, depending on wether or not to use the stack
  -- data_out <= memory_speicher(to_integer(unsigned(local_adress)));
  data_out <= ram_data;

  pc_addr_out <= (others => '0');
  -- PC addr out is the conjuction of 2 cases from the memory
  --pc_addr_out <= (others => '0') when (write_pc_addr = '0' or w_e_memory = id_memory
  --                                     or stack_pointer>1021) else
  --               std_logic_vector(resize(unsigned(memory_speicher(stack_pointer + 1))
  --               & unsigned(memory_speicher(stack_pointer + 2)), pc_addr'length));


end Behavioral;

