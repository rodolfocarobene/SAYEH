-- Controller of SAYEH
--
-- It is a 11-state machine that issues
-- the appropriate signals to the Datapath

library ieee;
  use ieee.std_logic_1164.all;

entity controller is
  port (
    clk : in    std_logic;

    -- inputs: Instruction Register output, ALU flags,
    -- external control signals
    irout         : in    std_logic_vector(15 downto 0);
    externalreset : in    std_logic;
    -- outputs of the StatusRegister
    cflag : in    std_logic;
    zflag : in    std_logic;
    -- Memory output
    memdataready : in    std_logic;

    shadow_en              : in    std_logic;
    -- control inputs of the datapath
    shadow                 : out   std_logic;
    ir_on_hopndbus         : out   std_logic;
    pcplus1                : out   std_logic;
    enablepc               : out   std_logic;
    ir_on_lopndbus         : out   std_logic;
    rfright_on_opndbus     : out   std_logic;
    irload                 : out   std_logic;
    b15to0                 : out   std_logic;
    aaddb                  : out   std_logic;
    asubb                  : out   std_logic;
    aandb                  : out   std_logic;
    aorb                   : out   std_logic;
    amulb                  : out   std_logic;
    adivb                  : out   std_logic;
    notb                   : out   std_logic;
    acmpb                  : out   std_logic;
    shrb                   : out   std_logic;
    shlb                   : out   std_logic;
    alu_on_databus         : out   std_logic;
    zset                   : out   std_logic;
    zreset                 : out   std_logic;
    cset                   : out   std_logic;
    creset                 : out   std_logic;
    zload                  : out   std_logic;
    cload                  : out   std_logic;
    rs_on_addressunitrside : out   std_logic;
    rd_on_addressunitrside : out   std_logic;
    pcplusi                : out   std_logic;
    resetpc                : out   std_logic;
    readmem                : out   std_logic;
    writemem               : out   std_logic;
    wpadd                  : out   std_logic;
    wpreset                : out   std_logic;
    address_on_databus     : out   std_logic;
    rplus0                 : out   std_logic;
    rplusi                 : out   std_logic;
    rfl_write              : out   std_logic;
    rfh_write              : out   std_logic
  );
end entity controller;

architecture rtl of controller is

  type state is (
    halt,
    reset,
    fetch,
    memread,
    exec1,
    exec2,
    exec1lda,
    exec2lda,
    incpc
  );

  signal current_state, next_state : state;

  signal check_next : std_logic;

begin

  clocked_transitions : process (clk, externalreset) is
  begin

    if (externalreset='1') then
      current_state <= reset;
    else
      if (clk'event and clk = '1') then
        current_state <= next_state;
      end if;
    end if;

  end process clocked_transitions;

  control_outputs_and_transition : process (current_state) is
  begin

    check_next <= '1'; -- deafult to check if shadow inst is present

    -- outp<="00";
    shadow                 <= '0';
    enablepc               <= '0';
    pcplus1                <= '0';
    irload                 <= '0';
    b15to0                 <= '0';
    aandb                  <= '0';
    aaddb                  <= '0';
    asubb                  <= '0';
    aorb                   <= '0';
    amulb                  <= '0';
    adivb                  <= '0';
    notb                   <= '0';
    acmpb                  <= '0';
    shrb                   <= '0';
    shlb                   <= '0';
    alu_on_databus         <= '0';
    zset                   <= '0';
    zreset                 <= '0';
    cset                   <= '0';
    creset                 <= '0';
    zload                  <= '0';
    cload                  <= '0';
    rs_on_addressunitrside <= '0';
    rd_on_addressunitrside <= '0';
    pcplusi                <= '0';
    resetpc                <= '0';
    readmem                <= '0';
    writemem               <= '0';
    wpadd                  <= '0';
    wpreset                <= '0';
    address_on_databus     <= '0';
    rplus0                 <= '0';
    rplusi                 <= '0';
    rfl_write              <= '0';
    rfh_write              <= '0';
    ir_on_hopndbus         <= '0';
    ir_on_lopndbus         <= '0';
    rfright_on_opndbus     <= '0';

    case current_state is

      when halt =>

        next_state <= halt;

      when reset =>

        -- reset state
        enablepc <= '1';
        wpreset  <= '1';
        resetpc  <= '1';
        creset   <= '1';
        zreset   <= '1';

        next_state <= fetch;

      when fetch =>

        readmem <= '1';

        next_state <= memread;

      when memread =>

        irload     <= '1';
        next_state <= exec1;

      when exec1 =>

        case(irout(15 downto 12)) is

          when("0000") =>

            case(irout(11 downto 8)) is

              -- 0000-00-00 no operation
              when ("0000") =>

              -- 0000-00-01 halt
              when ("0001") =>

                check_next <= '0';
                next_state <= halt;

              -- 0000-00-10 set zero flag
              when ("0010") =>

                zset <= '1';

              -- 0000-00-11 clr zero flag
              when ("0011") =>

                zreset <= '1';

              -- 0000-01-00 set carry flag
              when ("0100") =>

                cset <= '1';

              -- 0000-01-01 clr carry flag
              when ("0101") =>

                creset <= '1';

              -- 0000-01-10 clr window pointer
              when ("0110") =>

                wpreset <= '1';

              -- 0000-01-11 jump relative
              when ("0111") =>

                pcplusi <= '1';

                check_next <= '0';
                next_state <= incpc;

              -- 0000-10-00 branch if zero
              when ("1000") =>

                if (zflag <= '1') then
                  pcplusi <= '1';

                  check_next <= '0';
                  next_state <= incpc;
                end if;

              -- 0000-10-00 branch if carry
              when ("1001") =>

                if (cflag <= '1') then
                  pcplusi <= '1';

                  check_next <= '0';
                  next_state <= incpc;
                end if;

              -- 0000-10-10 add win pointer
              when ("1010") =>

                wpadd <= '1';

              when OTHERS =>

                next_state <= fetch;

            end case;

          -- 0001-DD-SS move register
          when("0001") =>

            rfright_on_opndbus <= '1';
            b15to0             <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 0010-DD-SS load addressed
          when("0010") =>

            readmem                <= '1';
            rs_on_addressunitrside <= '1';
            rplus0                 <= '1';

            check_next <= '0';
            next_state <= exec1lda;

          -- 0011-DD-SS store addressed
          when("0011") =>

            rfright_on_opndbus     <= '1';
            writemem               <= '1';
            b15to0                 <= '1';
            alu_on_databus         <= '1';
            rd_on_addressunitrside <= '1';
            rplus0                 <= '1';

          -- 0100-DD-SS input from port
          when("0100") =>

          -- 0101-DD-SS output from port
          when("0101") =>

          -- 0110-DD-SS alu and
          when("0110") =>

            rfright_on_opndbus <= '1';
            aandb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 0111-DD-SS alu or
          when("0111") =>

            rfright_on_opndbus <= '1';
            aorb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1000-DD-SS alu not
          when("1000") =>

            rfright_on_opndbus <= '1';
            notb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1001-DD-SS alu shift left
          when("1001") =>

            rfright_on_opndbus <= '1';
            shlb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1010-DD-SS alu shift right
          when("1010") =>

            rfright_on_opndbus <= '1';
            shrb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1011-DD-SS alu add
          when("1011") =>

            rfright_on_opndbus <= '1';
            aaddb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1100-DD-SS alu sub
          when("1100") =>

            rfright_on_opndbus <= '1';
            asubb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1101-DD-SS alu mul
          when("1101") =>

            rfright_on_opndbus <= '1';
            amulb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1110-DD-SS alu cmp
          when("1110") =>

            rfright_on_opndbus <= '1';
            alu_on_databus     <= '1';
            acmpb              <= '1';
            cload              <= '1';
            zload              <= '1';

          when("1111") =>

            case(irout(9 downto 8)) is

              -- 1110-DD-00-I move Immd low
              when("00") =>

                b15to0         <= '1';
                rfl_write      <= '1';
                rfh_write      <= '1';
                ir_on_lopndbus <= '1';

              -- 1110-DD-01-I move Immd high
              when("01") =>

                b15to0         <= '1';
                rfl_write      <= '1';
                rfh_write      <= '1';
                ir_on_lopndbus <= '1';

              -- 1110-DD-10-I save PC
              when("10") =>

                pcplusi            <= '1';
                address_on_databus <= '1';
                rfl_write          <= '1';
                rfh_write          <= '1';

                check_next <= '0';
                next_state <= incpc;

              -- 1110-DD-11-I jump addresed
              when("11") =>

                pcplusi                <= '1';
                rd_on_addressunitrside <= '1';

                check_next <= '0';
                next_state <= incpc;

              when OTHERS =>

                check_next <= '0';
                next_state <= fetch;

            end case;

          when OTHERS =>

            next_state <= fetch;
            check_next <= '0';

        end case;

        -- if (irout(15 downto 8) != "00000001"
        --     and irout(15 downto 12) != "0010"
        --     and irout(15 downto 12) != "0100" -- verify
        --     and irout(15 downto 12) != "0101" -- verify
        --   ) then
        if (check_next = '1') then
          if (shadow_en = '1') then
            next_state <= exec2;
          else
            pcplus1 <= '1';

            enablepc   <= '1';
            next_state <= fetch;
          end if;
        end if;

      when exec1lda =>

        if (memdataready = '0') then
          rplus0                 <= '1';
          rs_on_addressunitrside <= '1';
          readmem                <= '1';
          next_state             <= exec1lda;
        else
          rfl_write <= '1';
          rfh_write <= '1';

          if (shadow_en = '1') then
            next_state <= exec2;
          else
            pcplus1    <= '1';
            enablepc   <= '1';
            next_state <= fetch;
          end if;
        end if;

      when exec2 =>

        case(irout(7 downto 4)) is

          when("0000") =>

            case(irout(3 downto 0)) is

              -- 0000-00-00 no operation
              when ("0000") =>

              -- 0000-00-01 halt
              when ("0001") =>

                next_state <= halt;

              -- 0000-00-10 set zero flag
              when ("0010") =>

                zset <= '1';

              -- 0000-00-11 clr zero flag
              when ("0011") =>

                zreset <= '1';

              -- 0000-01-00 set carry flag
              when ("0100") =>

                cset <= '1';

              -- 0000-01-01 clr carry flag
              when ("0101") =>

                creset <= '1';

              -- 0000-01-10 clr window pointer
              when ("0110") =>

                wpreset <= '1';

              -- 0000-01-11 jump relative
              when ("0111") =>

                pcplusi <= '1';

                check_next <= '0';
                next_state <= incpc;

              -- 0000-10-00 branch if zero
              when ("1000") =>

                if (zflag <= '1') then
                  pcplusi <= '1';

                  check_next <= '0';
                  next_state <= incpc;
                end if;

              -- 0000-10-00 branch if carry
              when ("1001") =>

                if (cflag <= '1') then
                  pcplusi <= '1';

                  check_next <= '0';
                  next_state <= incpc;
                end if;

              -- 0000-10-10 add win pointer
              when ("1010") =>

                wpadd <= '1';

              when OTHERS =>

                next_state <= fetch;

            end case;

          -- 0001-DD-SS move register
          when("0001") =>

            rfright_on_opndbus <= '1';
            b15to0             <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 0010-DD-SS load addressed
          when("0010") =>

            readmem                <= '1';
            rs_on_addressunitrside <= '1';
            rplus0                 <= '1';

            check_next <= '0';
            next_state <= exec2lda;

          -- 0011-DD-SS store addressed
          when("0011") =>

            rfright_on_opndbus     <= '1';
            writemem               <= '1';
            b15to0                 <= '1';
            alu_on_databus         <= '1';
            rd_on_addressunitrside <= '1';
            rplus0                 <= '1';

          -- 0100-DD-SS input from port
          when("0100") =>

          -- 0101-DD-SS output from port
          when("0101") =>

          -- 0110-DD-SS alu and
          when("0110") =>

            rfright_on_opndbus <= '1';
            aandb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 0111-DD-SS alu or
          when("0111") =>

            rfright_on_opndbus <= '1';
            aorb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1000-DD-SS alu not
          when("1000") =>

            rfright_on_opndbus <= '1';
            notb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1001-DD-SS alu shift left
          when("1001") =>

            rfright_on_opndbus <= '1';
            shlb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1010-DD-SS alu shift right
          when("1010") =>

            rfright_on_opndbus <= '1';
            shrb               <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1011-DD-SS alu add
          when("1011") =>

            rfright_on_opndbus <= '1';
            aaddb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1100-DD-SS alu sub
          when("1100") =>

            rfright_on_opndbus <= '1';
            asubb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1101-DD-SS alu mul
          when("1101") =>

            rfright_on_opndbus <= '1';
            amulb              <= '1';
            alu_on_databus     <= '1';
            rfl_write          <= '1';
            rfh_write          <= '1';
            cload              <= '1';
            zload              <= '1';

          -- 1110-DD-SS alu cmp
          when("1110") =>

            rfright_on_opndbus <= '1';
            alu_on_databus     <= '1';
            acmpb              <= '1';
            cload              <= '1';
            zload              <= '1';

          when("1111") =>

            case(irout(1 downto 0)) is

              -- 1110-DD-00-I move Immd low
              when("00") =>

                b15to0         <= '1';
                rfl_write      <= '1';
                rfh_write      <= '1';
                ir_on_lopndbus <= '1';

              -- 1110-DD-01-I move Immd high
              when("01") =>

                b15to0         <= '1';
                rfl_write      <= '1';
                rfh_write      <= '1';
                ir_on_lopndbus <= '1';

              -- 1110-DD-10-I save PC
              when("10") =>

                pcplusi            <= '1';
                address_on_databus <= '1';
                rfl_write          <= '1';
                rfh_write          <= '1';

                check_next <= '0';
                next_state <= incpc;

              -- 1110-DD-11-I jump addresed
              when("11") =>

                pcplusi                <= '1';
                rd_on_addressunitrside <= '1';

                check_next <= '0';
                next_state <= incpc;

              when OTHERS =>

                next_state <= fetch;

            end case;

          when OTHERS =>

            next_state <= fetch;

        end case;

        if (check_next = '1') then
          pcplus1    <= '1';
          enablepc   <= '1';
          next_state <= fetch;
        end if;

      when exec2lda =>

        if (memdataready = '0') then
          rplus0                 <= '1';
          rs_on_addressunitrside <= '1';
          readmem                <= '1';
          next_state             <= exec2lda;
        else
          rfl_write <= '1';
          rfh_write <= '1';

          pcplus1    <= '1';
          enablepc   <= '1';
          next_state <= fetch;
        end if;

      when incpc =>

        pcplus1    <= '1';
        enablepc   <= '1';
        next_state <= fetch;

      when OTHERS =>

        next_state <= reset;

    end case;

  end process control_outputs_and_transition;

end architecture rtl;

