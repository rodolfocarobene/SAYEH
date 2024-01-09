-- Controller of SAYEH
--
-- It is a 11-state machine that issues
-- the appropriate signals to the Datapath

library ieee;
  use ieee.std_logic_1164.all;

entity controller is
  port (
    clk : in    std_logic;

    -- inputs: irout Register output, ALU flags,
    -- external control signals
    irout         : in    std_logic_vector(15 downto 0);
    externalreset : in    std_logic;
    -- outputs of the StatusRegister
    cflag : in    std_logic;
    zflag : in    std_logic;
    -- Memory output
    memdataready : in    std_logic;

    shadow_en : in    std_logic;
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
    rfh_write              : out   std_logic;

    srload  : out   std_logic;
    readio  : out   std_logic;
    writeio : out   std_logic
  );
end entity controller;

architecture dataflow of controller is

  type state is (
    halt,
    reset,
    fetch,
    memread,
    exec1,
    exec2,
    exec1lda,
    exec2lda,
    exec1sta,
    exec2sta,
    incpc
  );

  constant b0000 : std_logic_vector(3 downto 0) := "0000";
  constant b1111 : std_logic_vector(3 downto 0) := "1111";

  constant nop : std_logic_vector(3 downto 0) := "0000";
  constant hlt : std_logic_vector(3 downto 0) := "0001";
  constant szf : std_logic_vector(3 downto 0) := "0010";
  constant czf : std_logic_vector(3 downto 0) := "0011";
  constant scf : std_logic_vector(3 downto 0) := "0100";
  constant ccf : std_logic_vector(3 downto 0) := "0101";
  constant cwp : std_logic_vector(3 downto 0) := "0110";
  constant jpr : std_logic_vector(3 downto 0) := "0111";
  constant brz : std_logic_vector(3 downto 0) := "1000";
  constant brc : std_logic_vector(3 downto 0) := "1001";
  constant awp : std_logic_vector(3 downto 0) := "1010";

  constant mvr : std_logic_vector(3 downto 0) := "0001";
  constant lda : std_logic_vector(3 downto 0) := "0010";
  constant sta : std_logic_vector(3 downto 0) := "0011";
  constant inp : std_logic_vector(3 downto 0) := "0100";
  constant oup : std_logic_vector(3 downto 0) := "0101";
  constant anl : std_logic_vector(3 downto 0) := "0110";
  constant orr : std_logic_vector(3 downto 0) := "0111";
  constant nol : std_logic_vector(3 downto 0) := "1000";
  constant shl : std_logic_vector(3 downto 0) := "1001";
  constant shr : std_logic_vector(3 downto 0) := "1010";
  constant add : std_logic_vector(3 downto 0) := "1011";
  constant sub : std_logic_vector(3 downto 0) := "1100";
  constant mul : std_logic_vector(3 downto 0) := "1101";
  constant cmp : std_logic_vector(3 downto 0) := "1110";

  constant mil : std_logic_vector(1 downto 0) := "00";
  constant mih : std_logic_vector(1 downto 0) := "01";
  constant spc : std_logic_vector(1 downto 0) := "10";
  constant jpa : std_logic_vector(1 downto 0) := "11";

  signal pstate, nstate    : state;
  signal regd_memdataready : std_logic;

begin

  choose_next : process (irout, pstate, externalreset, cflag, zflag, regd_memdataready, shadow_en) is
  begin

    resetpc                <= '0';
    pcplusi                <= '0';
    pcplus1                <= '0';
    rplusi                 <= '0';
    rplus0                 <= '0';
    enablepc               <= '0';
    b15to0                 <= '0';
    aandb                  <= '0';
    aorb                   <= '0';
    notb                   <= '0';
    shrb                   <= '0';
    shlb                   <= '0';
    aaddb                  <= '0';
    asubb                  <= '0';
    amulb                  <= '0';
    acmpb                  <= '0';
    rfl_write              <= '0';
    rfh_write              <= '0';
    wpreset                <= '0';
    wpadd                  <= '0';
    irload                 <= '0';
    srload                 <= '0';
    address_on_databus     <= '0';
    alu_on_databus         <= '0';
    ir_on_lopndbus         <= '0';
    ir_on_hopndbus         <= '0';
    rfright_on_opndbus     <= '0';
    readmem                <= '0';
    writemem               <= '0';
    readio                 <= '0';
    writeio                <= '0';
    shadow                 <= '0';
    cset                   <= '0';
    creset                 <= '0';
    zset                   <= '0';
    zreset                 <= '0';
    rs_on_addressunitrside <= '0';
    rd_on_addressunitrside <= '0';

    case pstate is

      when reset =>

        if (externalreset = '1') then
          wpreset  <= '1';
          resetpc  <= '1';
          enablepc <= '1';
          creset   <= '1';
          zreset   <= '1';
          nstate   <= reset;
        else
          nstate <= fetch;
        end if;

      when halt =>

        if (externalreset = '1') then
          nstate <= fetch;
        else
          nstate <= halt;
        end if;

      when fetch =>

        if (externalreset = '1') then
          nstate <= reset;
        else
          readmem <= '1';
          nstate  <= memread;
        end if;

      when memread =>

        if (externalreset = '1') then
          nstate <= reset;
        else
          if (regd_memdataready = '0') then
            readmem <= '1';
            nstate  <= memread;
          else
            readmem <= '1';
            irload  <= '1';
            nstate  <= exec1;
          end if;
        end if;

      when exec1 =>

        if (externalreset = '1') then
          nstate <= reset;
        else

          case irout (7 downto 4)is

            when b0000 =>

              case irout (3 downto 0) is

                when nop =>

                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when hlt =>

                  nstate <= halt;

                when szf =>

                  zset <= '1';
                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when czf =>

                  zreset <= '1';
                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when scf =>

                  cset <= '1';
                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when ccf =>

                  creset <= '1';
                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when cwp =>

                  wpreset <= '1';
                  if (shadow_en='1') then
                    nstate <= exec2;
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                    nstate   <= fetch;
                  end if;

                when jpr =>

                  pcplusi  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when brz =>

                  if (zflag = '1') then
                    pcplusi  <= '1';
                    enablepc <= '1';
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                  end if;
                  nstate <= fetch;

                when brc =>

                  if (cflag = '1') then
                    pcplusi  <= '1';
                    enablepc <= '1';
                  else
                    pcplus1  <= '1';
                    enablepc <= '1';
                  end if;
                  nstate <= fetch;

                when awp =>

                  pcplus1  <= '1';
                  enablepc <= '1';
                  wpadd    <= '1';
                  nstate   <= fetch;

                when others =>

                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

              end case;

            when mvr =>

              rfright_on_opndbus <= '1';
              b15to0             <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when lda =>

              rplus0                 <= '1';
              rs_on_addressunitrside <= '1';
              readmem                <= '1';
              rfl_write              <= '1';
              rfh_write              <= '1';
              nstate                 <= exec1lda;

            when sta =>

              rplus0                 <= '1';
              rd_on_addressunitrside <= '1';
              rfright_on_opndbus     <= '1';
              b15to0                 <= '1';
              alu_on_databus         <= '1';
              writemem               <= '1';
              nstate                 <= exec1sta;

            when inp =>

              rplus0                 <= '1';
              rs_on_addressunitrside <= '1';
              readio                 <= '1';
              rfl_write              <= '1';
              rfh_write              <= '1';
              srload                 <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                nstate <= incpc;
              end if;

            when oup =>

              rplus0                 <= '1';
              rd_on_addressunitrside <= '1';
              b15to0                 <= '1';
              alu_on_databus         <= '1';
              writeio                <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                nstate <= incpc;
              end if;

            when anl =>

              rfright_on_opndbus <= '1';
              aandb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when orr =>

              rfright_on_opndbus <= '1';
              aorb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when nol =>

              rfright_on_opndbus <= '1';
              notb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when shl =>

              rfright_on_opndbus <= '1';
              shlb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when shr =>

              rfright_on_opndbus <= '1';
              shrb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when add =>

              rfright_on_opndbus <= '1';
              aaddb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when sub =>

              rfright_on_opndbus <= '1';
              asubb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when mul =>

              rfright_on_opndbus <= '1';
              amulb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when cmp =>

              rfright_on_opndbus <= '1';
              acmpb              <= '1';
              srload             <= '1';
              if (shadow_en='1') then
                nstate <= exec2;
              else
                pcplus1  <= '1';
                enablepc <= '1';
                nstate   <= fetch;
              end if;

            when b1111 =>

              case irout (1 downto 0) is

                when mil =>

                  ir_on_lopndbus <= '1';
                  alu_on_databus <= '1';
                  b15to0         <= '1';
                  rfl_write      <= '1';
                  srload         <= '1';
                  pcplus1        <= '1';
                  enablepc       <= '1';
                  nstate         <= fetch;

                when mih =>

                  ir_on_hopndbus <= '1';
                  alu_on_databus <= '1';
                  b15to0         <= '1';
                  rfh_write      <= '1';
                  srload         <= '1';
                  pcplus1        <= '1';
                  enablepc       <= '1';
                  nstate         <= fetch;

                when spc =>

                  pcplusi            <= '1';
                  address_on_databus <= '1';
                  rfl_write          <= '1';
                  rfh_write          <= '1';
                  enablepc           <= '1';
                  nstate             <= incpc;

                when jpa =>

                  rd_on_addressunitrside <= '1';
                  rplusi                 <= '1';
                  enablepc               <= '1';
                  nstate                 <= fetch;

                when others =>

                  nstate <= fetch;

              end case;

            when others =>

              nstate <= fetch;

          end case;

        end if;

      when exec1lda =>

        if (externalreset = '1') then
          nstate <= reset;
        else
          if (regd_memdataready = '0') then
            rplus0                 <= '1';
            rs_on_addressunitrside <= '1';
            readmem                <= '1';
            rfl_write              <= '1';
            rfh_write              <= '1';
            nstate                 <= exec1lda;
          else
            if (shadow_en='1') then
              nstate <= exec2;
            else
              pcplus1  <= '1';
              enablepc <= '1';
              nstate   <= fetch;
            end if;
          end if;
        end if;

      when exec1sta =>

        if (externalreset = '1') then
          nstate <= reset;
        else
          if (regd_memdataready = '0') then
            rplus0                 <= '1';
            rd_on_addressunitrside <= '1';
            rfright_on_opndbus     <= '1';
            b15to0                 <= '1';
            alu_on_databus         <= '1';
            writemem               <= '1';
            nstate                 <= exec1sta;
          else
            --  writemem <= '1';
            if (shadow_en='1') then
              nstate <= exec2;
            else
              nstate <= incpc;
            end if;
          end if;
        end if;

      when exec2 =>

        shadow <= '1';

        if (externalreset = '1') then
          nstate <= reset;
        else

          case irout (7 downto 4)is

            when b0000 =>

              case irout (3 downto 0) is

                when hlt =>

                  nstate <= halt;

                when szf =>

                  zset     <= '1';
                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when czf =>

                  zreset   <= '1';
                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when scf =>

                  cset     <= '1';
                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when ccf =>

                  creset   <= '1';
                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when cwp =>

                  wpreset  <= '1';
                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

                when others =>

                  pcplus1  <= '1';
                  enablepc <= '1';
                  nstate   <= fetch;

              end case;

            when mvr =>

              rfright_on_opndbus <= '1';
              b15to0             <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when lda =>

              rplus0                 <= '1';
              rs_on_addressunitrside <= '1';
              readmem                <= '1';
              rfl_write              <= '1';
              rfh_write              <= '1';
              nstate                 <= exec2lda;

            when sta =>

              rplus0                 <= '1';
              rd_on_addressunitrside <= '1';
              rfright_on_opndbus     <= '1';
              b15to0                 <= '1';
              alu_on_databus         <= '1';
              writemem               <= '1';
              nstate                 <= exec2sta;

            when inp =>

              rplus0                 <= '1';
              rs_on_addressunitrside <= '1';
              readio                 <= '1';
              rfl_write              <= '1';
              rfh_write              <= '1';
              srload                 <= '1';
              nstate                 <= incpc;

            when oup =>

              rplus0                 <= '1';
              rd_on_addressunitrside <= '1';
              b15to0                 <= '1';
              alu_on_databus         <= '1';
              writeio                <= '1';
              nstate                 <= incpc;

            when anl =>

              rfright_on_opndbus <= '1';
              aandb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when orr =>

              rfright_on_opndbus <= '1';
              aorb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when nol =>

              rfright_on_opndbus <= '1';
              notb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when shl =>

              rfright_on_opndbus <= '1';
              shlb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when shr =>

              rfright_on_opndbus <= '1';
              shrb               <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when add =>

              rfright_on_opndbus <= '1';
              aaddb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when sub =>

              rfright_on_opndbus <= '1';
              asubb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when mul =>

              rfright_on_opndbus <= '1';
              amulb              <= '1';
              alu_on_databus     <= '1';
              rfl_write          <= '1';
              rfh_write          <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when cmp =>

              rfright_on_opndbus <= '1';
              acmpb              <= '1';
              srload             <= '1';
              pcplus1            <= '1';
              enablepc           <= '1';
              nstate             <= fetch;

            when others =>

              nstate <= fetch;

          end case;

        end if;

      when exec2lda =>

        shadow <= '1';

        if (externalreset = '1') then
          nstate <= reset;
        else
          if (regd_memdataready = '0') then
            rplus0                 <= '1';
            rs_on_addressunitrside <= '1';
            readmem                <= '1';
            rfl_write              <= '1';
            rfh_write              <= '1';
            nstate                 <= exec2lda;
          else
            pcplus1  <= '1';
            enablepc <= '1';
            nstate   <= fetch;
          end if;
        end if;

      when exec2sta =>

        shadow <= '1';

        if (externalreset = '1') then
          nstate <= reset;
        else
          if (regd_memdataready = '0') then
            rplus0                 <= '1';
            rd_on_addressunitrside <= '1';
            rfright_on_opndbus     <= '1';
            b15to0                 <= '1';
            alu_on_databus         <= '1';
            writemem               <= '1';
            nstate                 <= exec2sta;
          else
            nstate <= incpc;
          end if;
        end if;

      when incpc =>

        pcplus1  <= '1';
        enablepc <= '1';
        nstate   <= fetch;

      when others =>

        nstate <= reset;

    end case;

  end process choose_next;

  go_next : process (clk) is
  begin

    if (clk = '1') then
      regd_memdataready <= memdataready;
      pstate            <= nstate;
    end if;

  end process go_next;

end architecture dataflow;
