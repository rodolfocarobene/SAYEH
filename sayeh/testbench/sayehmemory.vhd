
library ieee;
  use ieee.std_logic_1164.all;
  use std.textio.all;
  use ieee.std_logic_textio.all;
  use IEEE.std_logic_unsigned.all;


entity memorysayeh is
  generic (
    blocksize  : integer := 1024;
    segmentsno : integer := 64
  );
  port (
    clk          : in    std_logic;
    readmem      : in    std_logic;
    writemem     : in    std_logic;
    addressbus   : in    std_logic_vector(15 downto 0);
    memdataready : out   std_logic;
    databus      : inout std_logic_vector(15 downto 0)
  );
end entity memorysayeh;

architecture behavioral of memorysayeh is

  constant shadowins : std_logic_vector(7 downto 0) := "00001111";

  type mem_type is array (0 to blocksize - 1) of std_logic_vector(15 downto 0);

  -- assembler convert and amp asm file to memory
  procedure assembler (variable mem : out mem_type) is

    file     code  : text open read_mode is "prog.txt";
    variable instr : line;

    variable addr_std_v        : std_logic_vector(15 downto 0);
    variable memonic           : string (4 downto 1);
    variable im_ch             : character;
    variable immediate         : std_logic_vector(7 downto 0);
    variable window_ptr        : std_logic_vector(3 downto 0);
    variable dest_reg, src_reg : std_logic_vector(3 downto 0);

    variable immi_str2 : string (2 downto 1);
    variable adr, addr : integer := -1;
    variable shadowen  : boolean := false;

  begin

    while not endfile (code) loop

      readline (code, instr);
      report "Instr -" & string(instr) & "-";
      hread (instr, addr_std_v);
      addr := conv_integer (addr_std_v);
      addr := addr mod blocksize;
      read (instr, memonic);

      report "Read memonic: " & memonic;
      case memonic is

        when " nop" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := (others => '0');
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := (others => '0');
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " hlt" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000001";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000001";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " szf" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000010";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000010";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " czf" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000011";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000011";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " scf" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000100";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000100";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " ccf" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000101";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000101";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " cwp" =>

          if (shadowen=true) then
            mem (adr) (7 downto 0) := "00000110";
          else
            adr                     := adr + 1;
            mem (adr) (15 downto 8) := "00000110";
            mem (adr) (7 downto 0)  := shadowins;
          end if;

          shadowen := not shadowen;

        when " jpr" =>

          shadowen                := false;
          adr                     := adr + 1;
          mem (adr) (15 downto 8) := "00000111";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)  := immediate;

        when " brz" =>

          shadowen                := false;
          adr                     := adr + 1;
          mem (adr) (15 downto 8) := "00001000";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)  := immediate;

        when " brc" =>

          shadowen                := false;
          adr                     := adr + 1;
          mem (adr) (15 downto 8) := "00001001";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)  := immediate;

        when " awp" =>

          shadowen                := false;
          adr                     := adr + 1;
          mem (adr) (15 downto 8) := "00001010";
          mem (adr) (7 downto 3)  := (others => '0');
          read (instr, im_ch);
          hread(instr, window_ptr);
          mem (adr) (2 downto 0)  := window_ptr (2 downto 0);

        when " mvr" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0001";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0001";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);

            mem (adr) (7 downto 0) := shadowins;
          end if;

          shadowen := not shadowen;

        when " lda" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0010";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0010";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " sta" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0011";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);

          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0011";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;

          end if;

          shadowen := not shadowen;

        when " inp" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0100";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0100";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " oup" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0101";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0101";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " and" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0110";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0110";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " orr" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "0111";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "0111";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " not" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1000";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1000";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " shl" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1001";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1001";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " shr" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1010";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1010";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " add" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1011";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1011";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " sub" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1100";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1100";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " mul" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1101";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1101";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " cmp" =>

          if (shadowen=true) then
            mem (adr) (7 downto 4) := "1110";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (3 downto 2) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (1 downto 0) := src_reg (1 downto 0);
          else
            adr                      := adr + 1;
            mem (adr) (15 downto 12) := "1110";
            read (instr, immi_str2);
            hread (instr, dest_reg);
            mem (adr) (11 downto 10) := dest_reg (1 downto 0);
            read (instr, immi_str2);
            hread (instr, src_reg);
            mem (adr) (9 downto 8)   := src_reg (1 downto 0);
            mem (adr) (7 downto 0)   := shadowins;
          end if;

          shadowen := not shadowen;

        when " mil" =>

          shadowen                 := false;
          adr                      := adr + 1;
          mem (adr) (15 downto 12) := "1111";
          read (instr, immi_str2);
          hread (instr, dest_reg);
          mem (adr) (11 downto 10) := dest_reg (1 downto 0);
          mem (adr) (9 downto 8)   := "00";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)   := immediate;

        when " mih" =>


          shadowen                 := false;
          adr                      := adr + 1;
          mem (adr) (15 downto 12) := "1111";
          read (instr, immi_str2);
          hread (instr, dest_reg);
          mem (adr) (11 downto 10) := dest_reg (1 downto 0);
          mem (adr) (9 downto 8)   := "01";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)   := immediate;

        when " spc" =>

          shadowen                 := false;
          adr                      := adr + 1;
          mem (adr) (15 downto 12) := "1111";
          read (instr, immi_str2);
          hread (instr, dest_reg);
          mem (adr) (11 downto 10) := dest_reg (1 downto 0);
          mem (adr) (9 downto 8)   := "10";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)   := immediate;

        when " jpa" =>

          shadowen                 := false;
          adr                      := adr + 1;
          mem (adr) (15 downto 12) := "1111";
          read (instr, immi_str2);
          hread (instr, dest_reg);
          mem (adr) (11 downto 10) := dest_reg (1 downto 0);
          mem (adr) (9 downto 8)   := "11";
          read (instr, im_ch);
          hread (instr, immediate);
          mem (adr) (7 downto 0)   := immediate;

        when others =>

          mem (adr) := (others => '0');

      end case;

    end loop;

    file_close (code);

  end procedure;

  -- load a segment from a file

  procedure memload (buffermem : out mem_type; fileno : in integer) is

    variable hexcode   : string (4 downto 1);
    variable memline   : line;
    variable offset    : integer := 0;
    variable err_check : file_open_status;
    variable hexcode_v : std_logic_vector(15 downto 0);
    file     f         : text;

  begin

    buffermem := (others => (others => '0'));
    file_open (err_check, f, ("mem" & integer'image (fileno) & ".hex"), read_mode);

    if (err_check = open_ok) then

      while not endfile (f) loop

        readline (f, memline);
        hread (memline, hexcode_v);
        buffermem (offset) := hexcode_v;
        offset             := offset + 1;

      end loop;

      file_close (f);
    end if;

  end procedure memload;

  -- write memory data of a segment to its corresponding file

  procedure updatefile (buffermem : in mem_type; fileno : in integer) is

    variable memline : line;
    file     f       : text open write_mode is ("mem" & integer'image (fileno) & ".hex");

  begin

    for i in 0 to blocksize - 1 loop

      hwrite (memline, buffermem (i));
      writeline (f, memline);

    end loop;

    file_close (f);

  end procedure updatefile;

begin

  read_write : process (clk) is

    variable buffermem   : mem_type := (others => (others => '0'));
    variable ad          : integer;
    variable memloadedno : integer  := segmentsno + 1;
    variable changemem   : boolean  := false;
    variable init        : boolean  := true;

  begin

    if (init = true) then
      assembler (buffermem);
      updatefile (buffermem, 1);
      memloadedno := 1;
      init        := false;
    end if;

    ad := conv_integer (addressbus);
    -- if (clk='0') then
    if (readmem = '0') then
      memdataready <= '0';
      databus      <= (others => 'Z');
    end if;

    -- end if;
    if (clk='0') then
      if (readmem = '1') then
        memdataready <= '0';
        -- if addressbus value >= 64*1024 databus <= NULL
        if (ad >= (segmentsno * blocksize)) then
          databus <= (others => 'Z');
        else
            -- if the page to load is different from the existing

          report "Memloadedno: " & integer'image(memloadedno);
          report "Ad: "          & integer'image(ad);
          report "blocksize: "   & integer'image(blocksize);
          report "segmentsno: "  & integer'image(segmentsno);

          if (memloadedno /= ((ad / blocksize) + 1)) then
            -- if not last page?
            if (memloadedno/= (segmentsno + 1)) then
              if (changemem=true) then
            -- load the file with updatefile procedure
                updatefile (buffermem, memloadedno);
              end if;
            end if;
            -- required page loaded to buffermem
            memload (buffermem, ( (ad / blocksize) + 1));
            changemem   := false;
            memloadedno := (ad / blocksize) + 1;
            -- load databus with the address in addressbus mod blocksize
            databus     <= buffermem (ad mod blocksize);
          else
            -- load databus with the address in addressbus mod blocksize
            databus <= buffermem (ad mod blocksize);
          end if;
        end if;
        -- signal that the data was read and its correctly stored in databus

        report "Memready read: "
          & std_logic'image(buffermem(ad mod blocksize)(15))
          & std_logic'image(buffermem(ad mod blocksize)(14))
          & std_logic'image(buffermem(ad mod blocksize)(13))
          & std_logic'image(buffermem(ad mod blocksize)(12))
          & std_logic'image(buffermem(ad mod blocksize)(11))
          & std_logic'image(buffermem(ad mod blocksize)(10))
          & std_logic'image(buffermem(ad mod blocksize)(9))
          & std_logic'image(buffermem(ad mod blocksize)(8))
          & std_logic'image(buffermem(ad mod blocksize)(7))
          & std_logic'image(buffermem(ad mod blocksize)(6))
          & std_logic'image(buffermem(ad mod blocksize)(5))
          & std_logic'image(buffermem(ad mod blocksize)(4))
          & std_logic'image(buffermem(ad mod blocksize)(3))
          & std_logic'image(buffermem(ad mod blocksize)(2))
          & std_logic'image(buffermem(ad mod blocksize)(1))
          & std_logic'image(buffermem(ad mod blocksize)(0));

        memdataready <= '1';
      elsif (writemem = '1') then
        memdataready <= '0';
        -- write if address in addressbus is valid
        if (ad < (segmentsno * blocksize)) then
          -- if we are in the correct page
          if (memloadedno = ((ad / blocksize) + 1)) then
            -- if the loaded buffer is different from what
            -- is stored in the databus, set changemem
            if (buffermem (ad mod blocksize)/=databus) then
              changemem := true;
            end if;
            buffermem (ad mod blocksize) := databus;
            -- if memory is to be changed, call updatefile and do it
            if (changemem=true) then
              updatefile (buffermem, memloadedno);
              changemem := false;
            end if;
          -- if we are not on the correct page
          else
            -- change page
            if (memloadedno/= (segmentsno + 1)) then
              if (changemem=true) then
                updatefile (buffermem, memloadedno);
              end if;
            end if;
            memloadedno := (ad / blocksize) + 1;
            memload (buffermem, memloadedno);
            changemem   := false;
            -- if the loaded buffer is different from what
            -- is stored in the databus, set changemem
            if (buffermem (ad mod blocksize)/=databus) then
              changemem := true;
            end if;
            buffermem (ad mod blocksize) := databus;
            -- if memory is to be changed, call updatefile and do it
            if (changemem=true) then
              updatefile (buffermem, memloadedno);
              changemem := false;
            end if;
          end if;
        end if;

        report "Memready write: "
          & std_logic'image(buffermem(ad mod blocksize)(15))
          & std_logic'image(buffermem(ad mod blocksize)(14))
          & std_logic'image(buffermem(ad mod blocksize)(13))
          & std_logic'image(buffermem(ad mod blocksize)(12))
          & std_logic'image(buffermem(ad mod blocksize)(11))
          & std_logic'image(buffermem(ad mod blocksize)(10))
          & std_logic'image(buffermem(ad mod blocksize)(9))
          & std_logic'image(buffermem(ad mod blocksize)(8))
          & std_logic'image(buffermem(ad mod blocksize)(7))
          & std_logic'image(buffermem(ad mod blocksize)(6))
          & std_logic'image(buffermem(ad mod blocksize)(5))
          & std_logic'image(buffermem(ad mod blocksize)(4))
          & std_logic'image(buffermem(ad mod blocksize)(3))
          & std_logic'image(buffermem(ad mod blocksize)(2))
          & std_logic'image(buffermem(ad mod blocksize)(1))
          & std_logic'image(buffermem(ad mod blocksize)(0));

        memdataready <= '1';
      end if;
    end if;

  end process read_write;

end architecture behavioral;
