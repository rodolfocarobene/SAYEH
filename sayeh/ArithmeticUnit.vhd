-- Component of the Datapath
--
-- Arithmetic Unit for register-like parametes (16bit)

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity arithmeticunit is
  port (
    -- the two inputs of the ALU
    a : in    std_logic_vector(15 downto 0);
    b : in    std_logic_vector(15 downto 0);

    -- commands to set operation
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

    -- output of the ALU
    alout : out   std_logic_vector(15 downto 0);

    -- carriage in and out
    cin  : in    std_logic;
    cout : out   std_logic;

    -- 1 if out is all zero or if a=b and cmp is selected
    zout : out   std_logic
  );
end entity arithmeticunit;

architecture dataflow of arithmeticunit is

  -- enables to use easily the case expression
  constant b15to0h : std_logic_vector(9 downto 0) := "1000000000";
  constant aandbh  : std_logic_vector(9 downto 0) := "0100000000";
  constant aorbh   : std_logic_vector(9 downto 0) := "0010000000";
  constant notbh   : std_logic_vector(9 downto 0) := "0001000000";
  constant shlbh   : std_logic_vector(9 downto 0) := "0000100000";
  constant shrbh   : std_logic_vector(9 downto 0) := "0000010000";
  constant aaddbh  : std_logic_vector(9 downto 0) := "0000001000";
  constant asubbh  : std_logic_vector(9 downto 0) := "0000000100";
  constant amulbh  : std_logic_vector(9 downto 0) := "0000000010";
  constant acmpbh  : std_logic_vector(9 downto 0) := "0000000001";

  -- out signal
  signal aloutsignal : std_logic_vector(15 downto 0);

begin

  -- alu in sequential manner
  alu : process (
                 a, b, b15to0, aandb, aorb, notb,
                 shlb, shrb, aaddb, asubb, amulb,
                 acmpb, cin, aloutsignal
                ) is

    variable temp : std_logic_vector(9 downto 0);
    variable sum  : std_logic_vector(16 downto 0);
    variable sub  : std_logic_vector(16 downto 0);
    variable prod : std_logic_vector(15 downto 0);

  begin

    -- null initialization
    zout        <= '0';
    cout        <= '0';
    aloutsignal <= (OTHERS => '0');

    temp := (b15to0, aandb, aorb, notb, shlb, shrb, aaddb, asubb, amulb, acmpb);
    prod  := std_logic_vector(unsigned(a(7 downto 0)) + unsigned(b(7 downto 0)));
    
    if cin = '1' then    
      sum  := std_logic_vector(unsigned(a) + unsigned(b) + to_unsigned(1, 16));
      sub  := std_logic_vector(unsigned(a) - unsigned(b) - to_unsigned(1, 16));
    else
      sum  := std_logic_vector(unsigned(a) + unsigned(b));
      sub  := std_logic_vector(unsigned(a) - unsigned(b));
    end if;

    case temp is

      when b15to0h =>

        aloutsignal <= b;

      when aandbh =>

        aloutsignal <= a and b;

      when aorbh =>

        aloutsignal <= a or b;

      when notbh =>

        aloutsignal <= not (b);

      when shlbh =>

        aloutsignal <= b (14 downto 0) & b (0);

      when shrbh =>

        aloutsignal <= b(15) & b (15 downto 1);

      when aaddbh =>

        aloutsignal <= sum(15 downto 0);
        cout        <= sum (16);

      when asubbh =>

        aloutsignal <= sub(15 downto 0);
        cout        <= sub (16);

      when amulbh =>

        aloutsignal <= prod;

      when acmpbh =>

        aloutsignal <= (OTHERS => '1');

        if (a > b) then
          cout <= '1';
        else
          cout <= '0';
        end if;

        if (a=b) then
          zout <= '1';
        else
          zout <= '0';
        end if;

      when OTHERS =>

        aloutsignal <= (OTHERS => '0');

    end case;

    if (aloutsignal = "0000000000000000") then
      zout <= '1';
    end if;

  end process alu;

  alout <= aloutsignal;

end architecture dataflow;

