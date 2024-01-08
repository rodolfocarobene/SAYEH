-- Part of the ALU, performs 8x8 multiplatcations (bitwise)

library ieee;
  use ieee.std_logic_1164.all;

entity bit8x8 is
  port (
    x : in    std_logic_vector(7 downto 0);
    y : in    std_logic_vector(7 downto 0);
    z : out   std_logic_vector(15 downto 0)
  );
end entity bit8x8;

architecture bitwise of bit8x8 is

  component bit1x1 is
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
  end component;

  type pair is ARRAY (8 downto 0, 8 downto 0) OF std_logic;

  signal xv : pair;
  signal yv : pair;
  signal cv : pair;
  signal pv : pair;

begin

  rows : for i IN x'range generate

    cols : for j IN y'range generate

      cell : component bit1x1
        port map (
          xi => xv (i, j),
          yi => yv (i, j),
          pi => pv (i, j + 1),
          ci => cv (i, j),
          xo => xv (i, j + 1),
          yo => yv (i + 1, j),
          po => pv (i + 1, j),
          co => cv (i, j + 1)
        );

    end generate cols;

  end generate rows;

  sides : for i IN x'range generate
    xv (i, 0)            <= x (i);
    cv (i, 0)            <= '0';
    pv (0, i + 1)        <= '0';
    pv (i + 1, x'LENGTH) <= cv (i, x'length);
    yv (0, i)            <= y (i);
    z (i)                <= pv (i + 1, 0);
    z (i + x'LENGTH)     <= pv (x'length, i + 1);
  end generate sides;

end architecture bitwise;
