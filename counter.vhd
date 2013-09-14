library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
  port (
    clk: in std_logic;
    leds: out std_logic_vector(7 downto 0)
  );
end counter;

architecture counter_arch of counter is
  signal temp_count: std_logic_vector(7 downto 0) := x"00";
  signal slow_clk: std_logic;
  -- Clock divider can be changed to suit application.
  -- Clock (clk) is normally 50 MHz, so each clock cycle
  -- is 20 ns. A clock divider of 'n' bits will make 1
  -- slow_clk cycle equal 2^n clk cycles.
  signal clk_divider: std_logic_vector(15 downto 0) := x"0000";
begin
  -- Process that makes slow clock go high only when MSB of -- clk_divider goes high.
  division: process (clk, clk_divider)
  begin
    if clk'event and clk = '1' then
      clk_divider <= clk_divider + 1;
    end if;
    slow_clk <= clk_divider(15);
  end process;

  counting: process(slow_clk, temp_count)
  begin
    if slow_clk'event and slow_clk = '1' then
      temp_count <= temp_count + 1;
    end if;

    leds <= temp_count;
  end process;
end counter_arch;
