-- Small arithmetic unit that performs adding and incrementing
-- for calculating PC or memory address
--
-- It takes in input addresses from PC, Registe and Instruction

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity addresslogic is
  port (
    -- register address coming from program counter
    pcside : in    std_logic_vector(15 downto 0);
    -- register address coming from register
    rside : in    std_logic_vector(15 downto 0);
    -- instruction command coming from instruction register
    iside : in    std_logic_vector(7 downto 0);

    -- ALU command inputs
    resetpc : in    std_logic;
    pcplusi : in    std_logic;
    pcplus1 : in    std_logic;
    rplusi  : in    std_logic;
    rplus0  : in    std_logic;

    -- output of ALU
    alout : out   std_logic_vector(15 downto 0)
  );
end entity addresslogic;

architecture dataflow of addresslogic is

  -- constants to better analyze various inputs
  constant one   : std_logic_vector(4 downto 0) := "10000";
  constant two   : std_logic_vector(4 downto 0) := "01000";
  constant three : std_logic_vector(4 downto 0) := "00100";
  constant four  : std_logic_vector(4 downto 0) := "00010";
  constant five  : std_logic_vector(4 downto 0) := "00001";

begin

  -- process sensible on registers, command, and ALU instructions
  compute_alout : process (pcside, rside, iside, resetpc,  pcplusi, pcplus1, rplusi, rplus0) is

    -- temporary signal to merge commands
    variable temp : std_logic_vector(4 downto 0);

  begin

    temp := (resetpc & pcplusi & pcplus1 & rplusi & rplus0);

    case temp is

      when one =>

        -- if reset is on and others are off, reset output
        alout <= (OTHERS => '0');

      when two =>

        -- if pcplusi is on, sum pcside and iside
        alout <= std_logic_vector(unsigned(pcside) + unsigned(iside));

      when three =>

        -- if pcplus1 is one, increase pcside
        alout <= std_logic_vector(unsigned(pcside) + 1);

      when four =>

        -- if rplusi is one, sum register side and isde
        alout <= std_logic_vector(unsigned(rside) + unsigned(iside));

      when five =>

        -- if rplus0 is one, return rside
        alout <= rside;

      when OTHERS =>

        -- in other cases output pcside
        alout <= pcside;

    end case;

  end process compute_alout;

end architecture dataflow;

