-------------------------------------------------------------------------------
-- Title      : Data Memory
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_memory.vhd
-- Author     : Marie Simatic  <marie@simatic.org>
-- Company    : 
-- Created    : 2016-11-21
-- Last update: 2016-12-05
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
  type sram is array(1023 downto 0) of std_logic_vector(7 downto 0);
  signal memory_speicher : sram;
  signal stack_pointer   : integer := 1023;

begin
  writing_process : process(clk)
    variable incremented_pc_addr : std_logic_vector(11 downto 0) := (others => '0');
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        memory_speicher <= (others => (others => '0'));
        stack_pointer   <= 1023;
      else

        if write_pc_addr = '1' then
          incremented_pc_addr := unsigned(pc_addr) + 1;
          -- RCALL
          if w_e_memory = id_memory then
            memory_speicher(stack_pointer)     <= incremented_pc_addr(7 downto 0);
            memory_speicher(stack_pointer - 1) <= "0000" & incremented_pc_addr(11 downto 8);
            stack_pointer                      <= stack_pointer - 2;
          -- RET
          else
            stack_pointer <= stack_pointer + 2;
          end if;
        elsif stack_enable = '1' then
          -- PUSH
          if w_e_memory = id_memory then
            memory_speicher(stack_pointer) <= data_in;
            stack_pointer                  <= stack_pointer - 1;
          -- POP
          else
            stack_pointer <= stack_pointer + 1;
          end if;

        -- ST
        elsif w_e_memory = id_memory then
          memory_speicher(to_integer(unsigned(addr))) <= data_in;
        end if;
      end if;
    end if;
  end process writing_process;

  data_out <= memory_speicher(stack_pointer + 1) when stack_enable = '1' and stack_pointer < 1023
              else memory_speicher(to_integer(unsigned(addr)));

  -- PC addr out is the conjuction of 2 cases from the memory
  pc_addr_out <= memory_speicher(stack_pointer + 1)(3 downto 0)
                 & memory_speicher(stack_pointer + 2)
                 when write_pc_addr = '1' and w_e_memory /= id_memory else
                 (others => '0');

end Behavioral;

