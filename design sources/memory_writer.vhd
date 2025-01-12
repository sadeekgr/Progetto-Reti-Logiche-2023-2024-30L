library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_writer is
    port (
        i_clk        : in std_logic;
        i_rst        : in std_logic;
        i_mem_addr   : in std_logic_vector(15 downto 0);
        i_mem_data   : in std_logic_vector(7 downto 0);
        i_en_writing : in std_logic;
        i_clear      : in std_logic;

        o_address    : out std_logic_vector(15 downto 0);
        o_data       : out std_logic_vector(7 downto 0);
        o_en_writing : out std_logic
    );
end memory_writer;

architecture arch_memory_writer of memory_writer is
signal all_zeroes : std_logic_vector(7 downto 0);
signal prev_data : std_logic_vector(7 downto 0);
signal prev_cred : std_logic_vector(7 downto 0);
signal cred_to_write : std_logic;
begin
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            all_zeroes <= (others => '0');
            prev_data <= (others => '0');
            prev_cred <= (others => '0');
            cred_to_write <= '0';
            o_address <= (others => '0');
            o_data <= (others => '0');
            o_en_writing <= '0';
        elsif rising_edge(i_clk) then
            all_zeroes <= (others => '0');
            if i_clear = '0' then
                o_en_writing <= i_en_writing;
                if i_en_writing = '1' then
                    if cred_to_write = '0' then
                        cred_to_write <= '1';
                        o_address <= i_mem_addr;
                        if i_mem_data = all_zeroes then
                            o_data <= prev_data;
                            if prev_cred /= all_zeroes then
                                prev_cred <= std_logic_vector(unsigned(prev_cred)-1);
                            end if;
                        else
                            o_data <= i_mem_data;
                            prev_data <= i_mem_data;
                            prev_cred <= std_logic_vector(unsigned(all_zeroes)+31);
                        end if;
                    else
                        cred_to_write <= '0';
                        o_address <= std_logic_vector(unsigned(i_mem_addr)+1);
                        o_data <= prev_cred;
                    end if;
                end if;
            else
                prev_data <= (others => '0');
                prev_cred <= (others => '0');
                cred_to_write <= '0';
                o_address <= (others => '0');
                o_data <= (others => '0');
                o_en_writing <= '0';
            end if;
        end if;
    end process;
end arch_memory_writer;