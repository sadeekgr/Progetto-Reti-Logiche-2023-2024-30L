library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_reader is
    port (
        i_clk            : in std_logic;
        i_rst            : in std_logic;
        i_address        : in std_logic_vector(15 downto 0);
        i_en_reading     : in std_logic;
        i_update_reading : in std_logic;
        i_clear          : in std_logic;

        o_address        : out std_logic_vector(15 downto 0);
        o_en_reading     : out std_logic
    );
end memory_reader;

architecture arch_memory_reader of memory_reader is
signal all_zeroes : std_logic_vector(15 downto 0);
signal curr_address : std_logic_vector(15 downto 0);
begin
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            all_zeroes <= (others => '0');
            curr_address <= (others => '0');
            o_address <= (others => '0');
            o_en_reading <= '0';
        elsif rising_edge(i_clk) then
            all_zeroes <= (others => '0');
            if i_clear = '0' then
                o_en_reading <= i_en_reading;
                if i_en_reading = '1' then
                    if curr_address = all_zeroes then
                        curr_address <= std_logic_vector(unsigned(i_address)+2);
                        o_address <= i_address;
                    elsif i_update_reading = '1' then
                        o_address <= curr_address;
                        curr_address <= std_logic_vector(unsigned(curr_address)+2);
                    end if;
                end if;
            else
                curr_address <= (others => '0');
                o_address <= (others => '0');
                o_en_reading <= '0';
            end if;
        end if;
    end process;
end arch_memory_reader;