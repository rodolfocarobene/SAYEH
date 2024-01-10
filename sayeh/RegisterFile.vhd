-- Datapath component
--
-- SAYEH register file.
-- Two port memoy with a moving window pointer.
-- Reading is asyncronous, while writing is synced.
-- Two registers are always output to Lout and Rout

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity registerfile is
  port (
    clk : in    std_logic;

    -- input register
    input : in    std_logic_vector(15 downto 0);
    -- base of the window pointer WP
    base : in    std_logic_vector(5 downto 0);

    -- left and right input address (short because of WP)
    laddr : in    std_logic_vector(1 downto 0);
    raddr : in    std_logic_vector(1 downto 0);

    -- write enablers
    rflwrite : in    std_logic;
    rfhwrite : in    std_logic;

    -- left and right output address
    lout : out   std_logic_vector(15 downto 0);
    rout : out   std_logic_vector(15 downto 0)
  );
end entity registerfile;

architecture dataflow of registerfile is

  -- memory for registers is a 64x16 signal

  type memory is array (0 to 63) of std_logic_vector(15 downto 0);

  signal reg_memory         : memory;
  signal raddress, laddress : std_logic_vector(5 downto 0);

begin

  -- change address considering WP
  laddress <= std_logic_vector(unsigned(base) + unsigned(laddr));
  raddress <= std_logic_vector(unsigned(base) + unsigned(raddr));

  -- perform reading, after conversion to integer
  lout <= reg_memory(to_integer(unsigned(laddress)));
  rout <= reg_memory(to_integer(unsigned(raddress)));

  write_proc : process (clk) is
  begin

    -- on rising edge
    if (clk = '1') then
      -- if left enabler is 1, then take left part
      -- of input and store it in memory(laddress)
      if (rflwrite='1') then
        reg_memory(to_integer(unsigned(laddress)))(7 downto 0) <= input(7 downto 0);
      end if;

      -- if right enabler is 1, then take right part
      -- of input and store it in memory(raddress)
      if (rfhwrite='1') then
        reg_memory(to_integer(unsigned(laddress)))(15 downto 8) <= input(15 downto 8);
      end if;
    end if;

  end process write_proc;

end architecture dataflow;

