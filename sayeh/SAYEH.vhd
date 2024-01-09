-- Complete SAYEH processor
--
-- It is composed by a Controller and a Datapath
-- wh

library ieee;
  use ieee.std_logic_1164.all;

entity sayeh is
  port (
    clk : in    std_logic;

    externalreset : in    std_logic;
    memdataready  : in    std_logic;
    readmem       : out   std_logic;
    writemem      : out   std_logic;
    readio        : out   std_logic;
    writeio       : out   std_logic;

    databus    : inout std_logic_vector(15 downto 0);
    addressbus : out   std_logic_vector(15 downto 0)
  );
end entity sayeh;

architecture sayeharch of sayeh is

  component datapath is
    port (
      clk                    : in    std_logic;
      databus                : inout std_logic_vector(15 downto 0);
      resetpc                : in    std_logic;
      pcplusi                : in    std_logic;
      pcplus1                : in    std_logic;
      rplusl                 : in    std_logic;
      rplus0                 : in    std_logic;
      enablepc               : in    std_logic;
      rs_on_addressunitrside : in    std_logic;
      rd_on_addressunitrside : in    std_logic;
      b15to0                 : in    std_logic;
      aandb                  : in    std_logic;
      aorb                   : in    std_logic;
      notb                   : in    std_logic;
      shlb                   : in    std_logic;
      shrb                   : in    std_logic;
      aaddb                  : in    std_logic;
      asubb                  : in    std_logic;
      amulb                  : in    std_logic;
      acmpb                  : in    std_logic;
      rflwrite               : in    std_logic;
      rfhwrite               : in    std_logic;
      irload                 : in    std_logic;
      srload                 : in    std_logic;
      cset                   : in    std_logic;
      creset                 : in    std_logic;
      zset                   : in    std_logic;
      zreset                 : in    std_logic;
      cout                   : out   std_logic;
      zout                   : out   std_logic;
      wpreset                : in    std_logic;
      wpadd                  : in    std_logic;
      address_on_databus     : in    std_logic;
      alu_on_databus         : in    std_logic;
      ir_on_lopndbus         : in    std_logic;
      ir_on_hopndbus         : in    std_logic;
      rfright_on_opndbus     : in    std_logic;
      shadow                 : in    std_logic;
      shadow_en              : out   std_logic;
      addressbus             : out   std_logic_vector(15 downto 0);
      instruction            : out   std_logic_vector(7 downto 0)
    );
  end component datapath;

  component controller is
    port (
      clk                    : in    std_logic;
      irout                  : in    std_logic_vector(15 downto 0);
      externalreset          : in    std_logic;
      cflag                  : in    std_logic;
      zflag                  : in    std_logic;
      memdataready           : in    std_logic;
      shadow_en              : in    std_logic;
      shadow                 : out   std_logic;
      ir_on_hopndbus         : out   std_logic;
      pcplus1                : out   std_logic;
      enablepc               : out   std_logic;
      ir_on_lopndbus         : out   std_logic;
      rfright_on_opndbus     : out   std_logic;
      irload                 : out   std_logic;
      b15to0                 : out   std_logic;
      aaddb                  : out   std_logic;
      asubb                  : out   std_logic;
      aandb                  : out   std_logic;
      aorb                   : out   std_logic;
      amulb                  : out   std_logic;
      notb                   : out   std_logic;
      acmpb                  : out   std_logic;
      shrb                   : out   std_logic;
      shlb                   : out   std_logic;
      alu_on_databus         : out   std_logic;
      zset                   : out   std_logic;
      zreset                 : out   std_logic;
      cset                   : out   std_logic;
      creset                 : out   std_logic;
      zload                  : out   std_logic;
      cload                  : out   std_logic;
      rs_on_addressunitrside : out   std_logic;
      rd_on_addressunitrside : out   std_logic;
      pcplusi                : out   std_logic;
      resetpc                : out   std_logic;
      readmem                : out   std_logic;
      writemem               : out   std_logic;
      wpadd                  : out   std_logic;
      wpreset                : out   std_logic;
      address_on_databus     : out   std_logic;
      rplus0                 : out   std_logic;
      rplusi                 : out   std_logic;
      rfl_write              : out   std_logic;
      rfh_write              : out   std_logic;
      srload                 : out   std_logic;
      readio                 : out   std_logic;
      writeio                : out   std_logic
    );
  end component controller;

  signal resetpc                                        : std_logic;
  signal pcplusi                                        : std_logic;
  signal pcplus1                                        : std_logic;
  signal rplus1                                         : std_logic;
  signal rplus0                                         : std_logic;
  signal enablepc                                       : std_logic;
  signal rs_on_addressunitrside, rd_on_addressunitrside : std_logic;
  signal b15to0                                         : std_logic;
  signal aandb                                          : std_logic;
  signal aorb                                           : std_logic;
  signal notb                                           : std_logic;
  signal shlb                                           : std_logic;
  signal shrb                                           : std_logic;
  signal aaddb                                          : std_logic;
  signal asubb                                          : std_logic;
  signal amulb                                          : std_logic;
  signal acmpb                                          : std_logic;
  signal rflwrite,               rfhwrite               : std_logic;
  signal wpreset,                wpadd                  : std_logic;
  signal irload                                         : std_logic;
  signal srload                                         : std_logic;
  signal cset                                           : std_logic;
  signal creset                                         : std_logic;
  signal zset                                           : std_logic;
  signal zreset                                         : std_logic;
  signal address_on_databus                             : std_logic;
  signal alu_on_databus                                 : std_logic;
  signal shadow,                 shadow_en              : std_logic;
  signal ir_on_lopndbus                                 : std_logic;
  signal ir_on_hopndbus                                 : std_logic;
  signal rfright_on_opndbus                             : std_logic;
  signal cout,                   zout                   : std_logic;
  signal instruction                                    : std_logic_vector(15 downto 0);

    
begin

  dp : component datapath
    port map (
      clk                    => clk,
      databus                => databus,
      resetpc                => resetpc,
      pcplusi                => pcplusi,
      pcplus1                => pcplus1,
      rplusl                 => rplus1,
      rplus0                 => rplus0,
      enablepc               => enablepc,
      rs_on_addressunitrside => rs_on_addressunitrside,
      rd_on_addressunitrside => rd_on_addressunitrside,
      b15to0                 => b15to0,
      aandb                  => aandb,
      aorb                   => aorb,
      notb                   => notb,
      shlb                   => shlb,
      shrb                   => shrb,
      aaddb                  => aaddb,
      asubb                  => asubb,
      amulb                  => amulb,
      acmpb                  => acmpb,
      rflwrite               => rflwrite,
      rfhwrite               => rfhwrite,
      irload                 => irload,
      srload                 => srload,
      cset                   => cset,
      creset                 => creset,
      zset                   => zset,
      zreset                 => zreset,
      cout                   => cout,
      zout                   => zout,
      wpreset                => wpreset,
      wpadd                  => wpadd,
      address_on_databus     => address_on_databus,
      alu_on_databus         => alu_on_databus,
      ir_on_lopndbus         => ir_on_lopndbus,
      ir_on_hopndbus         => ir_on_hopndbus,
      rfright_on_opndbus     => rfright_on_opndbus,
      shadow                 => shadow,
      shadow_en              => shadow_en,
      addressbus             => addressbus,
      instruction            => instruction (15 downto 8)
    );

  p2 : component controller
    port map (
      clk                    => clk,
      irout                  => instruction,
      externalreset          => externalreset,
      cflag                  => cout,
      zflag                  => zout,
      memdataready           => memdataready,
      shadow_en              => shadow_en,
      shadow                 => shadow,
      ir_on_hopndbus         => ir_on_hopndbus,
      pcplus1                => pcplus1,
      enablepc               => enablepc,
      ir_on_lopndbus         => ir_on_lopndbus,
      rfright_on_opndbus     => rfright_on_opndbus,
      irload                 => irload,
      b15to0                 => b15to0,
      aaddb                  => aaddb,
      asubb                  => asubb,
      aandb                  => aandb,
      aorb                   => aorb,
      amulb                  => amulb,
      notb                   => notb,
      acmpb                  => acmpb,
      shrb                   => shrb,
      shlb                   => shlb,
      alu_on_databus         => alu_on_databus,
      zset                   => zset,
      zreset                 => zreset,
      cset                   => cset,
      creset                 => creset,
      zload                  => srload,
      cload                  => srload,
      rs_on_addressunitrside => rs_on_addressunitrside,
      rd_on_addressunitrside => rd_on_addressunitrside,
      pcplusi                => pcplusi,
      resetpc                => resetpc,
      readmem                => readmem,
      writemem               => writemem,
      wpadd                  => wpadd,
      wpreset                => wpreset,
      address_on_databus     => address_on_databus,
      rplus0                 => rplus0,
      rplusi                 => rplus1,
      rfl_write              => rflwrite,
      rfh_write              => rfhwrite,
      srload                 => srload,
      readio                 => readio,
      writeio                => writeio
    );

end architecture sayeharch;
