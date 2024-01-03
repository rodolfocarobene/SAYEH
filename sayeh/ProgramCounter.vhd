-- ProgramCounter: a simple register with enabling
-- and resetting mechanisms
--
-- Output stored = input when enablepc is = 1 (on
-- rising_edge of clk)

library ieee;
  use ieee.std_logic_1164.all;

entity programcounter is
  port (
    clk : in    std_logic;
    -- enable storage
    enablepc : in    std_logic;
    -- input address
    input : in    std_logic_vector(15 downto 0);
    -- output address
    output : out   std_logic_vector(15 downto 0)
  );
end entity programcounter;

architecture dataflow of programcounter is begin

  sync_store : process (clk) is
  begin

    -- sincronous process
    if (clk = '1') then -- on rising edge
      if (enablepc = '1') then
        output <= input;
      end if;
    end if;

  end process sync_store;

end architecture dataflow;
