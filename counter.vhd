library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
  port (
    clock    : in std_logic;
    rotary_a : in std_logic;
    rotary_b : in std_logic;
    rotary_c : in std_logic;
    leds     : out std_logic_vector(7 downto 0)
  );
end counter;

architecture counter_arch of counter is
  signal count : std_logic_vector(7 downto 0) := x"00";
  signal rotary_q1 : std_logic;
  signal rotary_q2 : std_logic;
  signal rotary_in : std_logic_vector(1 downto 0);
  signal rotary_event : std_logic;
  signal rotary_dir : std_logic;
  signal delay_rotary_q1 : std_logic;
begin
  rotary_filter: process(clock)
  begin
    if clock'event and clock = '1' then
      rotary_in <= rotary_b & rotary_a;

      case rotary_in is
      when "11" =>
        rotary_q1 <= '1';
        rotary_q2 <= rotary_q2;
      when "01" =>
        rotary_q1 <= rotary_q1;
        rotary_q2 <= '0';
      when "10" =>
        rotary_q1 <= rotary_q1;
        rotary_q2 <= '1';
      when others =>
        rotary_q1 <= '0';
        rotary_q2 <= rotary_q2;
      end case;
    end if;
  end process rotary_filter;

  direction: process(clock)
  begin
    if clock'event and clock = '1' then
      delay_rotary_q1 <= rotary_q1;

      if rotary_q1 = '1' and delay_rotary_q1 = '0' then
        rotary_event <= '1';
        rotary_dir <= rotary_q2;
      else
        rotary_event <= '0';
        rotary_dir <= rotary_dir;
      end if;
    end if;
  end process direction;

  led_counter: process(clock)
  begin
    if clock'event and clock = '1' then
      if rotary_c = '1' then
        count <= x"00";
      elsif rotary_event = '1' and rotary_dir = '0' then
        count <= count - 1;
      elsif rotary_event = '1' and rotary_dir = '1' then
        count <= count + 1;
      end if;

      leds <= count;
    end if;
  end process;
end counter_arch;
