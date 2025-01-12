library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_handler is
    port (
        i_clk              : in std_logic;
        i_rst              : in std_logic;
        i_sel_reading      : in std_logic;
        i_mem_addr_reading : in std_logic_vector(15 downto 0);
        i_sel_writing      : in std_logic;
        i_mem_addr_writing : in std_logic_vector(15 downto 0);
        i_mem_data_writing : in std_logic_vector(7 downto 0);

        o_mem_en           : out std_logic;
        o_mem_we           : out std_logic;
        o_mem_addr         : out std_logic_vector(15 downto 0);
        o_mem_data         : out std_logic_vector(7 downto 0)
    );
end memory_handler;

architecture arch_memory_handler of memory_handler is
begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_mem_en <= '0';
            o_mem_we <= '0';
            o_mem_addr <= (others => '0');
            o_mem_data <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_sel_reading = '1' then
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_mem_addr <= i_mem_addr_reading;
            elsif i_sel_writing = '1' then
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_mem_addr <= i_mem_addr_writing;
                o_mem_data <= i_mem_data_writing;
            else
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_mem_addr <= (others => '0');
                o_mem_data <= (others => '0');
            end if ;
        end if;
    end process;
end arch_memory_handler;