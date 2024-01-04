-- Datapath
--
-- It is composed of Addresing Unit, Arithmetic Logic Unit,
-- Register File, Instruction Register, Window Pointer,
-- Flags (Status Register)

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity datapath is
  port (
    clk : in    std_logic;

    -- Databus:
    -- input of RegisterFile, InstructionRegister
    databus : inout std_logic_vector(15 downto 0);

    -- AddressingUnit inputs (ALU commands)
    resetpc  : in    std_logic;
    pcplusi  : in    std_logic;
    pcplus1  : in    std_logic;
    rplusl   : in    std_logic;
    rplus0   : in    std_logic;
    enablepc : in    std_logic;
    -- External AddressingUnit additional ctrls
    rs_on_addressunitrside : in    std_logic;
    rd_on_addressunitrside : in    std_logic;

    -- ALU inputs (set operation)
    b15to0 : in    std_logic;
    aandb  : in    std_logic;
    aorb   : in    std_logic;
    notb   : in    std_logic;
    shlb   : in    std_logic;
    shrb   : in    std_logic;
    aaddb  : in    std_logic;
    asubb  : in    std_logic;
    amulb  : in    std_logic;
    acmpb  : in    std_logic;

    -- RegisterFile write-enablers
    rflwrite : in    std_logic;
    rfhwrite : in    std_logic;

    -- InstructionRegister store_enabler
    irload : in    std_logic;

    -- StatusRegister controllers
    srload : in    std_logic;
    cset   : in    std_logic;
    creset : in    std_logic;
    zset   : in    std_logic;
    zreset : in    std_logic;
    -- StatusRegister outputs
    cout : out   std_logic;
    zout : out   std_logic;

    -- WindowPointer controls
    wpreset : in    std_logic;
    wpadd   : in    std_logic;

    -- Other controller inputs
    address_on_databus : in    std_logic;
    alu_on_databus     : in    std_logic;
    ir_on_lopndbus     : in    std_logic;
    ir_on_hopndbus     : in    std_logic;
    rfright_on_opndbus : in    std_logic;
    shadow             : in    std_logic;
    shadow_en          : out   std_logic;

    addressbus  : out   std_logic_vector(15 downto 0);
    instruction : out   std_logic_vector(7  downto 0)
  );
end entity datapath;

architecture path of datapath is

  component adressingunit is
    port (
      clk      : in    std_logic;
      rside    : in    std_logic_vector(15 downto 0);
      iside    : in    std_logic_vector(7 downto 0);
      resetpc  : in    std_logic;
      pcplusi  : in    std_logic;
      pcplus1  : in    std_logic;
      rplusi   : in    std_logic;
      rplus0   : in    std_logic;
      pcenable : in    std_logic;
      address  : out   std_logic_vector(15 downto 0)
    );
  end component adressingunit;

  component alu is
    port (
      a      : in    std_logic_vector(15 downto 0);
      b      : in    std_logic_vector(15 downto 0);
      b15to0 : in    std_logic;
      aandb  : in    std_logic;
      aorb   : in    std_logic;
      notb   : in    std_logic;
      shlb   : in    std_logic;
      shrb   : in    std_logic;
      aaddb  : in    std_logic;
      asubb  : in    std_logic;
      amulb  : in    std_logic;
      acmpb  : in    std_logic;
      alout  : out   std_logic_vector(15 downto 0);
      cin    : in    std_logic;
      cout   : out   std_logic;
      zout   : out   std_logic
    );
  end component alu;

  component register_file is
    port (
      clk      : in    std_logic;
      input    : in    std_logic_vector(15 downto 0);
      base     : in    std_logic_vector(5 downto 0);
      laddr    : in    std_logic_vector(1 downto 0);
      raddr    : in    std_logic_vector(1 downto 0);
      rflwrite : in    std_logic;
      rfhwrite : in    std_logic;
      lout     : out   std_logic_vector(15 downto 0);
      rout     : out   std_logic_vector(15 downto 0)
    );
  end component register_file;

  component instruction_register is
    port (
      clk       : in    std_logic;
      enable_ir : in    std_logic;
      input     : in    std_logic_vector(15 downto 0);
      output    : out   std_logic_vector(15 downto 0)
    );
  end component instruction_register;

  component status_register is
    port (
      clk    : in    std_logic;
      cin    : in    std_logic;
      zin    : in    std_logic;
      srload : in    std_logic;
      cset   : in    std_logic;
      creset : in    std_logic;
      zset   : in    std_logic;
      zreset : in    std_logic;
      cout   : out   std_logic;
      zout   : out   std_logic
    );
  end component status_register;

  component window_pointer is
    port (
      clk    : in    std_logic;
      input  : in    std_logic_vector(5 downto 0);
      wprst  : in    std_logic;
      wpadd  : in    std_logic;
      output : out   std_logic_vector(5 downto 0)
    );
  end component window_pointer;

  -- Address used (7 downto 0) as i_side input of the AU
  -- Output of the InstructionRegister
  -- USed (5 downto 0) as WP input
  signal irout : std_logic_vector(15 downto 0);
  -- Address used as output of the AU
  signal address : std_logic_vector(15 downto 0);
  -- Address used as register_side input of the AU
  signal addressunitrsidebus : std_logic_vector(15 downto 0);

  -- Right signal from RegisterFile
  signal right : std_logic_vector(15 downto 0);
  -- Left signal from RegisterFile to ALU (a)
  signal left : std_logic_vector(15 downto 0);
  -- Operand on Bus (second input to ALU (b))
  signal opndbus : std_logic_vector(15 downto 0);

  -- Used for ALU and StatusRegister
  signal aluout : std_logic_vector(15 downto 0);
  signal srcin  : std_logic;
  signal srzout : std_logic;
  signal srcout : std_logic;

  -- used for status register (not for ALU??)
  signal srzin : std_logic;
  -- output of the WindowPointer (base)
  signal wpout : std_logic_vector(5 downto 0);
  -- left and right address of RegisterFile
  signal laddr, raddr : std_logic_vector(1 downto 0);

begin

  -- components initialization
  au : component adressingunit
    port map (
      clk      => clk,
      rside    => addressunitrsidebus,
      irside   => irout(7 downto 0),
      resetpc  => resetpc,
      pcplusi  => pcplusi,
      pcplus1  => pcplus1,
      rplusl   => rplusl,
      rplus0   => rplus0,
      enablepc => enablepc,
      address  => address
    );

  alu : component alu
    port map (
      a      => left,
      b      => opndbus,
      b15to0 => b15to0,
      aandb  => aandb,
      aorb   => aorb,
      notb   => notb,
      shlb   => shlb,
      shrb   => shrb,
      aaddb  => aaddb,
      asubb  => asubb,
      amulb  => amulb,
      acmpb  => acmpb,
      alout  => alout,
      cin    => srcin,
      cout   => srcout,
      zout   => srzout
    );

  rf : component register_file
    port map (
      clk      => clk,
      input    => databus,
      base     => wpout,
      laddr    => laddr,
      raddr    => raddr,
      rflwrite => rflwrite,
      rfhwrite => rfhwrite,
      lout     => left,
      rout     => right
    );

  ir : component instruction_register
    port map (
      clk       => clk,
      enable_ir => irload,
      input     => databus,
      output    => irout
    );

  sr : component status_register
    port map (
      clk    => clk,
      cin    => srcin,
      zin    => srzin,
      srload => srload,
      cset   => cset,
      creset => creset,
      zset   => zset,
      zreset => zreset,
      cout   => srcout,
      zout   => srzout,
    );

  wp : component window_pointer
    port map (
      clk    => clk,
      input  => irout(5 downto 0),
      wprst  => wpreset,
      wpadd  => wpadd,
      output => wpout
    );

  -- end component initialization

  addressbus <= address;
  zout       <= srzout;
  cout       <= srcout;

  addressunitrsidebus <= right when (rs_on_addressunitrside = '1') else
                         left when (rd_on_addressunitrside = '1') else
                         (others => 'Z');

  databus <= address when (address_on_databus = '1') else
             aluout when (alu_on_databus = '1') else
             (others => 'Z');

  opndbus(7 downto 0)  <= irout (7 downto 0) when (ir_on_lopndbus ='1') else
                          (others => 'Z');
  opndbus(15 DOWNTO 8) <= irout (7 downto 0) when (ir_on_hopndbus ='1') else
                          (others => 'Z');
  opndbus              <= right when (rfright_on_opndbus = '1') else
                          (others => 'Z');

  instruction <= irout (15 downto 0) when shadow else
                 (others => 'Z');
  shadow_en   <= '0' when irout(7 downto 0) = "00001111" else
                 '1';

  laddr <= irout(11 downto 10) when (shadow = '0') else
           irout(3 downto 2);

  raddr <= irout(9 downto 8) when (shadow = '0') else
           irout(1 downto 0);

end architecture path;
