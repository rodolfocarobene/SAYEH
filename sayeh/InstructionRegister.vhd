-- Datapath component
--
-- A 16 bit register with active high load-enable input

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity instruction_register is
  port (
    clk       : in    std_logic;
    enable_ir : in    std_logic;
    input     : in    std_logic_vector(15 downto 0);
    output    : out   std_logic_vector(15 downto 0)
  );
end entity instruction_register;

architecture dataflow of instruction_register is

begin

  store_reg : process (clk) is
  begin

    if (clk = '1') then
      if (enable_ir = '1') then
        output <= input;
      end if;
    end if;

  end process store_reg;

end architecture dataflow;
