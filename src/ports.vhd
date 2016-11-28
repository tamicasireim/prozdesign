library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_memory.all;

entity ports is
  generic(
    -- read only attribute :
    -- if set to 0 (port is read only)
    --   data_in should be linked to hardware port (ex :switch, button)
    --   data_out is equal to data_in
    -- else
    --   component act as a 8 bits memory.
    --   data_out shall be linked to hardware port (ex : led)
    read_only : std_logic;
    id_port : std_logic_vector(3 downto 0)
    );
  port(clk        : in  std_logic;
       reset : in std_logic;

       data_out   : out std_logic_vector (7 downto 0);
       w_e_memory : in  std_logic_vector(3 downto 0);
       data_in    : in  std_logic_vector(7 downto 0)
       );
end ports;

architecture Behavioral of ports is
  data <= std_logic_vector (7 downto 0) := "00000000";
begin

  write_process : process(clk, data_in)
  begin
    if read_only = '1' then
      data <= data_in
    else if clk'event and clk = '1' then
      if reset = '1' then
        data <= "00000000"
      else
        if w_e_memory = id_port then
            data <= data_in;
        end if;
      end if;
    end if;
  end process write_process;

  data_out <= data;

end Behavioral;
