-- Datapath component
--
-- The unit has two control lines
-- one for rst and one for adding its 6-bit
-- input to register contents

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity window_pointer is
  port (
    clk : in    std_logic;

    -- input of 6bit
    input : in    std_logic_vector(5 downto 0);

    -- reset and add control
    wprst : in    std_logic;
    wpadd : in    std_logic;

    -- output
    output : out   std_logic_vector(5 downto 0)
  );
end entity window_pointer;

architecture dataflow of window_pointer is

  signal outputsignal : std_logic_vector(5 downto 0);

begin

  reset_or_move : process (clk) is
  begin

    if (clk = '1') then
      if (wprst = '1') then
        outputsignal <= "000000";
      elsif (wpadd='1') then
        outputsignal <= std_logic_vector(unsigned(outputsignal) + unsigned(input));
      end if;
    end if;

  end process reset_or_move;

  output <= outputsignal;

end architecture dataflow;


