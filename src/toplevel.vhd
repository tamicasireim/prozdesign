----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:45:28 PM
-- Design Name: 
-- Module Name: toplevel - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.pkg_processor.all;
use work.pkg_instrmem.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port (

    -- global ports
    clk : in std_logic;

    dummy : in std_logic;

    -- buttons PIND
    btnEnter : in std_logic;
    btnR     : in std_logic;
    btnU     : in std_logic;
    btnD     : in std_logic;
    btnL     : in std_logic;

    -- PINC & PINB (switchs)
    sw  : in  std_logic_vector(15 downto 0);
    -- PORT C & PORT B (led)
    led : out std_logic_vector(15 downto 0)
    );

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  signal reset : std_logic;
  -- outputs of "Program_Counter_1"
  signal Addr  : std_logic_vector (pc_size - 1 downto 0);

  -- outputs of "prog_mem_1"
  signal Instr : std_logic_vector (15 downto 0);

  -- outputs of "decoder_1"
  signal addr_opa    : std_logic_vector(4 downto 0);
  signal addr_opb    : std_logic_vector(4 downto 0);
  signal OPCODE      : std_logic_vector(3 downto 0);
  signal w_e_regfile : std_logic;

  signal w_e_decoder_memory : std_logic;
  signal stack_enable       : std_logic;
  signal w_e_SREG_dec       : std_logic_vector(7 downto 0);
  signal offset_pc          : std_logic_vector(pc_size - 1 downto 0);
  signal addr_from_dec      : std_logic_vector(pc_size - 1 downto 0);
  signal load_addr_from_ext : std_logic;
  signal write_pc_addr      : std_logic;

  signal regfile_datain_selector : std_logic_vector(1 downto 0);
  signal alu_sel_immediate       : std_logic;

  -- outputs of Regfile
  signal data_opa : std_logic_vector (7 downto 0);
  signal data_opb : std_logic_vector (7 downto 0);
  signal sreg     : std_logic_vector(7 downto 0);
  signal index_z  : std_logic_vector(15 downto 0);

  -- output of ALU
  signal data_res   : std_logic_vector(7 downto 0);
  signal status_alu : std_logic_vector(7 downto 0);

  -- outputs of decoder_memory
  signal w_e_memory             : std_logic_vector(3 downto 0);
  signal addr_memory            : std_logic_vector(9 downto 0);
  signal memory_output_selector : std_logic_vector(3 downto 0);

  -- outputs of data memory and ports
  signal memory_data_out     : std_logic_vector(7 downto 0);
  signal memory_output       : std_logic_vector(7 downto 0);
  signal pc_addr_from_memory : std_logic_vector(pc_size - 1 downto 0);

  -- auxiliary signals
  signal PM_data        : std_logic_vector(7 downto 0);  -- used for wiring immediate data
  signal input_alu_opb  : std_logic_vector(7 downto 0);  -- output of
                                        -- alu_sel_immediate multiplexer
  signal input_data_reg : std_logic_vector(7 downto 0);  -- output of input reg
                                                         -- multiplexer

  -- input ports
  signal pind        : std_logic_vector(7 downto 0);
  signal output_pind : std_logic_vector(7 downto 0);
  signal pinc        : std_logic_vector(7 downto 0);
  signal output_pinc : std_logic_vector(7 downto 0);
  signal pinb        : std_logic_vector(7 downto 0);
  signal output_pinb : std_logic_vector(7 downto 0);

  -- output ports
  signal portc : std_logic_vector(7 downto 0);
  signal portb : std_logic_vector(7 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component Program_Counter
    port (
      reset              : in  std_logic;
      clk                : in  std_logic;
      offset_pc          : in  std_logic_vector (pc_size - 1 downto 0);
      addr_from_ext      : in  std_logic_vector(pc_size - 1 downto 0);
      load_addr_from_ext : in  std_logic;
      Addr               : out std_logic_vector (pc_size - 1 downto 0));
  end component;

  component prog_mem
    port (
      Addr  : in  std_logic_vector (pc_size - 1 downto 0);
      dummy : in  std_logic;
      Instr : out std_logic_vector (15 downto 0));
  end component;

  component data_memory is
    port (
      clk           : in  std_logic;
      reset         : in  std_logic;
      data_out      : out std_logic_vector (7 downto 0);
      w_e_memory    : in  std_logic_vector(3 downto 0);
      data_in       : in  std_logic_vector(7 downto 0);
      write_pc_addr : in  std_logic;
      stack_enable  : in  std_logic;
      addr          : in  std_logic_vector (9 downto 0);
      pc_addr       : in  std_logic_vector(pc_size - 1 downto 0);
      pc_addr_out   : out std_logic_vector(pc_size - 1 downto 0));
  end component data_memory;

  component decoder_memory is
    port (
      clk                    : in  std_logic;
      reset                  : in  std_logic;
      index_z                : in  std_logic_vector(15 downto 0);
      w_e_decoder_memory     : in  std_logic;
      stack_enable           : in  std_logic;
      w_e_memory             : out std_logic_vector(3 downto 0);
      memory_output_selector : out std_logic_vector (3 downto 0);
      addr_memory            : out std_logic_vector(9 downto 0));
  end component decoder_memory;

  component ports is
    generic (
      read_only : std_logic;
      id_port   : std_logic_vector(3 downto 0));
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      data_out   : out std_logic_vector (7 downto 0);
      w_e_memory : in  std_logic_vector(3 downto 0);
      data_in    : in  std_logic_vector(7 downto 0));
  end component ports;

  component decoder is
    port (
      Instr                   : in  std_logic_vector(15 downto 0);
      sreg                    : in  std_logic_vector(7 downto 0);
      w_e_SREG                : out std_logic_vector(7 downto 0);
      addr_opa                : out std_logic_vector(4 downto 0);
      addr_opb                : out std_logic_vector(4 downto 0);
      w_e_regfile             : out std_logic;
      regfile_datain_selector : out std_logic_vector(1 downto 0);
      OPCODE                  : out std_logic_vector(3 downto 0);
      alu_sel_immediate       : out std_logic;
      w_e_decoder_memory      : out std_logic;
      stack_enable            : out std_logic;
      write_pc_addr           : out std_logic;
      offset_pc               : out std_logic_vector(pc_size - 1 downto 0);
      addr_pc                 : out std_logic_vector(pc_size - 1 downto 0);
      load_addr_from_ext      : out std_logic;
      pc_addr_selector        : out std_logic);
  end component decoder;

  component Reg_File is
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      addr_opa    : in  std_logic_vector (4 downto 0);
      addr_opb    : in  std_logic_vector (4 downto 0);
      w_e_regfile : in  std_logic;
      data_opa    : out std_logic_vector (7 downto 0);
      data_opb    : out std_logic_vector (7 downto 0);
      index_z     : out std_logic_vector (15 downto 0);
      data_in     : in  std_logic_vector (7 downto 0));
  end component Reg_File;

  component ALU
    port (
      OPCODE : in  std_logic_vector (3 downto 0);
      OPA    : in  std_logic_vector (7 downto 0);
      OPB    : in  std_logic_vector (7 downto 0);
      RES    : out std_logic_vector (7 downto 0);
      Status : out std_logic_vector (7 downto 0));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "Program_Counter_1"
  Program_Counter_1 : Program_Counter
    port map (
      clk                => clk,
      reset              => reset,
      offset_pc          => offset_pc,
      addr_from_ext      => pc_addr_from_memory,
      load_addr_from_ext => load_addr_from_ext,
      Addr               => Addr);

  -- instance "prog_mem_1"
  prog_mem_1 : prog_mem
    port map (
      Addr  => Addr,
      dummy => dummy,
      Instr => Instr);

  -- instance "decoder_1"
  decoder_1 : decoder
    port map (
      Instr                   => Instr,
      sreg                    => sreg,
      addr_opa                => addr_opa,
      addr_opb                => addr_opb,
      OPCODE                  => OPCODE,
      offset_pc               => offset_pc,
      w_e_regfile             => w_e_regfile,
      stack_enable            => stack_enable,
      write_pc_addr           => write_pc_addr,
      addr_pc                 => addr_from_dec,
      load_addr_from_ext      => load_addr_from_ext,
      w_e_decoder_memory      => w_e_decoder_memory,
      w_e_SREG                => w_e_SREG_dec,
      alu_sel_immediate       => alu_sel_immediate,
      regfile_datain_selector => regfile_datain_selector);

  -- instance "Reg_File_1"

  Reg_File_1 : Reg_File
    port map (
      clk         => clk,
      reset       => reset,
      addr_opa    => addr_opa,
      addr_opb    => addr_opb,
      w_e_regfile => w_e_regfile,
      data_opa    => data_opa,
      data_opb    => data_opb,
      index_z     => index_z,
      data_in     => input_data_reg);

  -- instance "ALU_1"
  ALU_1 : ALU
    port map (
      OPCODE => OPCODE,
      OPA    => data_opa,
      OPB    => input_alu_opb,
      RES    => data_res,
      Status => status_alu);

  -- instance "decoder_memory_1"
  decoder_memory_1 : decoder_memory
    port map (
      clk                    => clk,
      reset                  => reset,
      index_z                => index_z,
      w_e_decoder_memory     => w_e_decoder_memory,
      stack_enable           => stack_enable,
      memory_output_selector => memory_output_selector,
      w_e_memory             => w_e_memory,
      addr_memory            => addr_memory);

  -- instance "data_memory_1"
  data_memory_1 : data_memory
    port map(
      clk           => clk,
      reset         => reset,
      data_out      => memory_data_out,
      write_pc_addr => write_pc_addr,
      stack_enable  => stack_enable,
      w_e_memory    => w_e_memory,
      data_in       => data_opa,
      addr          => addr_memory,
      pc_addr       => Addr,
      pc_addr_out   => pc_addr_from_memory);

  -- instances of port
  inst_pinc : ports
    generic map (
      read_only => '1',
      id_port   => id_pinc)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => output_pinc,
      w_e_memory => w_e_memory,
      data_in    => pinc);

  inst_pind : ports
    generic map (
      read_only => '1',
      id_port   => id_pind)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => output_pind,
      w_e_memory => w_e_memory,
      data_in    => pind);


  inst_pinb : ports
    generic map (
      read_only => '1',
      id_port   => id_pinb)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => output_pinb,
      w_e_memory => w_e_memory,
      data_in    => pinb);

  inst_portc : ports
    generic map (
      read_only => '0',
      id_port   => id_portc)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => portc,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_portb : ports
    generic map (
      read_only => '0',
      id_port   => id_portb)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => portb,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  -- variable from instruction
  PM_Data          <= Instr(11 downto 8)&Instr(3 downto 0);
  reset            <= btnR and btnU and btnD and btnL and btnEnter;
  -- port in definitions
  pind             <= "000" & btnR & btnU & btnD & btnL & btnEnter;
  pinc             <= sw(15 downto 8);
  pinb             <= sw(7 downto 0);
  -- port out definitions
  led(15 downto 8) <= portc;
  led(7 downto 0)  <= portb;


  -- ALU data OPB multiplexor
  input_alu_opb <= data_opb when alu_sel_immediate = '0'
                   else PM_Data;

  -- regfile datain multiplexor
  regfile_datain_mux : process (regfile_datain_selector, PM_Data,
                                data_res, data_opb, memory_output)
  begin
    case regfile_datain_selector is
      when regfile_data_in_instruction =>
        input_data_reg <= PM_Data;
      when regfile_data_in_alu =>
        input_data_reg <= data_res;
      when regfile_data_in_datab =>
        input_data_reg <= data_opb;
      when regfile_data_in_memory =>
        input_data_reg <= memory_output;
      when others =>
        input_data_reg <= "00000000";
    end case;
  end process regfile_datain_mux;

  -- memory output multiplexor
  memory_output_mux : process (memory_output_selector, memory_data_out,
                               portc, portb,
                               output_pind, output_pinc, output_pinb)
  begin
    case memory_output_selector is
      when id_memory =>
        memory_output <= memory_data_out;
      when id_pind =>
        memory_output <= output_pind;
      when id_pinc =>
        memory_output <= output_pinc;
      when id_pinb =>
        memory_output <= output_pinb;
      when id_portc =>
        memory_output <= portc;
      when id_portb =>
        memory_output <= portb;
      when others =>
        memory_output <= "00000000";
    end case;
  end process memory_output_mux;

  -- SREG
  sreg_process : process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        sreg <= "00000000";
      else
        sreg <= (not(w_e_SREG_dec) and sreg) or (w_e_SREG_dec and status_alu);
      end if;
    end if;
  end process sreg_process;


end Behavioral;
