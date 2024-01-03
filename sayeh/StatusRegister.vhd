-- Datapath component
--
-- Collection of two flags for ALU
-- carry and zero flag

entity statusregister is
  port (
    clk : in    std_logic;

    -- input of the flags
    cin : in    std_logic;
    zin : in    std_logic;

    -- enable loading (from ALU)
    srload : in    std_logic;

    -- output flags
    cout : out   std_logic;
    zout : out   std_logic
  );
end entity statusregister;

architecture dataflow of statusregister is

begin

  update_flags : process (clk) is
  begin

    -- rising edge
    if (clk='1') then
      -- order of operations:
      -- load > carry set > carry reset > zero set > zero reset
      if (srload = '1') then
        cout <= cin;
        zout <= zin;
      elsif (cset = '1') then
        cout <= '1';
      elsif (creset = '1') then
        cout <= '0';
      elsif (zset = '1') then
        zout <= '1';
      elsif (zreset = '1') then
        zout <= '0';
      end if;
    end if;

  end process update_flags;

end architecture dataflow;


