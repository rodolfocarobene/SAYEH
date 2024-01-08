-- Multiplication unit for a 8x8 mult of the ALU

library ieee;
  use ieee.std_logic_1164.all;

entity bit1x1 is
  port (
    xi : in    std_logic;
    yi : in    std_logic;
    pi : in    std_logic;
    ci : in    std_logic;
    xo : out   std_logic;
    yo : out   std_logic;
    po : out   std_logic;
    co : out   std_logic
  );
end entity bit1x1;

architecture bitwise of bit1x1 is

  signal xy : std_logic;

begin

  xy <= xi and yi;
  co <= (pi and xy) or (pi and ci) or (xy and ci);
  po <= pi xor xy xor ci;
  xo <= xi;
  yo <= yi;

end architecture bitwise;
