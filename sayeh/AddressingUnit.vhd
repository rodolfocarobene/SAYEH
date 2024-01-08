-- Component of the Datapath
--
-- It is composed of AddressLogic and ProgramCounter

library ieee;
  use ieee.std_logic_1164.all;

entity addressingunit is
  port (
    clk : in    std_logic;

    -- Addresses inputs of the AddressLogic
    rside : in    std_logic_vector(15 downto 0);
    iside : in    std_logic_vector(7 downto 0);

    -- ALU command inputs (for AddressLogic)
    resetpc : in    std_logic;
    pcplusi : in    std_logic;
    pcplus1 : in    std_logic;
    rplusi  : in    std_logic;
    rplus0  : in    std_logic;

    -- Enable storage of address in the PC
    pcenable : in    std_logic;

    -- sole output of the AddressLogic
    address : out   std_logic_vector(15 downto 0)
  );
end entity addressingunit;

architecture addressuni of addressingunit is

  -- Internal address, output of the PC
  signal pcout : std_logic_vector(15 downto 0);
  -- Output of the AddressLogic, used as input of the PC
  signal temp : std_logic_vector(15 downto 0);

  -- PC component
  component programcounter is
    port (
      clk      : in    std_logic;
      enablepc : in    std_logic;
      input    : in    std_logic_vector(15 downto 0);
      output   : out   std_logic_vector(15 downto 0)
    );
  end component programcounter;

  -- AddressLogic component
  component addresslogic is
    port (
      pcside  : in    std_logic_vector(15 downto 0);
      rside   : in    std_logic_vector(15 downto 0);
      iside   : in    std_logic_vector(7 downto 0);
      resetpc : in    std_logic;
      pcplusi : in    std_logic;
      pcplus1 : in    std_logic;
      rplusi  : in    std_logic;
      rplus0  : in    std_logic;
      alout   : out   std_logic_vector(15 downto 0)
    );
  end component addresslogic;

begin

  p0 : component programcounter
    port map (
      clk      => clk,
      enablepc => pcenable,
      input    => temp,
      output   => pcout
    );

  p1 : component addresslogic
    port map (
      pcside  => pcout,
      rside   => rside,
      iside   => iside,
      resetpc => resetpc,
      pcplusi => pcplusi,
      pcplus1 => pcplus1,
      rplusi  => rplusi,
      rplus0  => rplus0,
      alout   => temp
    );

  address <= temp;

end architecture addressuni;

