
library ieee;
  use ieee.std_logic_1164.all;

entity test_sayeh is
end entity test_sayeh;

architecture dataflow of test_sayeh is

  -- "external" processor clock
  signal clk : std_logic := '0';

  -- inout of SAYEH
  signal databus : std_logic_vector(15 downto 0);
  -- out of SAYEH
  signal addressbus : std_logic_vector(15 downto 0);
  -- outs of SAYEH
  signal readmem  : std_logic;
  signal writemem : std_logic;
  -- inputs of SAYEH
  signal externalreset : std_logic;
  signal memdataready  : std_logic;

  signal readio  : std_logic;
  signal writeio : std_logic;

  component sayeh is
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
  end component;

  component memorysayeh is
    port (
      clk          : in    std_logic;
      readmem      : in    std_logic;
      writemem     : in    std_logic;
      addressbus   : in    std_logic_vector(15 downto 0);
      memdataready : out   std_logic;
      databus      : inout std_logic_vector(15 downto 0)
    );
  end component;

begin

  -- oscillating clock
  clk <= not (clk) after 5 ns when now < 1000000 ns else
         clk;
  -- first 1 and then 0
  externalreset <= '1', '0' after 27 ns;

  processor : component sayeh
    port map (
      clk           => clk,
      externalreset => externalreset,
      memdataready  => memdataready,
      readmem       => readmem,
      writemem      => writemem,
      readio        => readio,
      writeio       => writeio,
      databus       => databus,
      addressbus    => addressbus
    );

  memory : component memorysayeh
    port map (
      clk          => clk,
      readmem      => readmem,
      writemem     => writemem,
      addressbus   => addressbus,
      memdataready => memdataready,
      databus      => databus
    );

end architecture dataflow;
