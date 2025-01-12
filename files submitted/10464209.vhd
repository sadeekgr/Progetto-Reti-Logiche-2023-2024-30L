library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);

        o_done  : out std_logic;

        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture arch_project_reti_logiche of project_reti_logiche is
signal en_reading : std_logic;
signal update_reading : std_logic;
signal address_reading : std_logic_vector(15 downto 0);
signal sel_reading : std_logic;
signal clear_reading : std_logic;
signal en_writing : std_logic;
signal address_writing : std_logic_vector(15 downto 0);
signal data_writing : std_logic_vector(7 downto 0);
signal sel_writing : std_logic;
signal clear_writing : std_logic;

component memory_reader is
    port(
        i_clk            : in std_logic;
        i_rst            : in std_logic;
        i_address        : in std_logic_vector(15 downto 0);
        i_en_reading     : in std_logic;
        i_update_reading : in std_logic;
        i_clear          : in std_logic;

        o_address        : out std_logic_vector(15 downto 0);
        o_en_reading     : out std_logic
    );
end component;

component memory_writer is
    port(
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
end component;

component controllerFSM is
    port(
        i_clk            : in std_logic;
        i_rst            : in std_logic;
        i_start          : in std_logic;
        i_k              : in std_logic_vector(9 downto 0);

        o_clear_reading  : out std_logic;
        o_en_reading     : out std_logic;
        o_update_reading : out std_logic;
        o_clear_writing  : out std_logic;
        o_en_writing     : out std_logic;
        o_done           : out std_logic
    );
end component;

component memory_handler is
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
end component;

begin
    memory_reader_1 : memory_reader port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_address => i_add,
        i_en_reading => en_reading,
        i_update_reading => update_reading,
        i_clear => clear_reading,
        o_address => address_reading,
        o_en_reading => sel_reading
    );

    memory_writer_1 : memory_writer port map(   
        i_clk => i_clk,
        i_rst => i_rst,
        i_mem_addr => address_reading,
        i_mem_data => i_mem_data,
        i_en_writing => en_writing,
        i_clear => clear_writing,
        o_address => address_writing,
        o_data => data_writing,
        o_en_writing => sel_writing
    );

    controllerFSM_1 : controllerFSM port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        i_k => i_k,
        o_clear_reading => clear_reading,
        o_en_reading => en_reading,
        o_update_reading => update_reading,
        o_clear_writing => clear_writing,
        o_en_writing => en_writing,
        o_done => o_done
    );

    memory_handler_1 : memory_handler port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_sel_reading => sel_reading,
        i_mem_addr_reading => address_reading,
        i_sel_writing => sel_writing,
        i_mem_addr_writing => address_writing,
        i_mem_data_writing => data_writing,
        o_mem_en => o_mem_en,
        o_mem_we => o_mem_we,
        o_mem_addr => o_mem_addr,
        o_mem_data => o_mem_data
    );
end arch_project_reti_logiche;



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



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controllerFSM is
    port(
        i_clk            : in std_logic;
        i_rst            : in std_logic;
        i_start          : in std_logic;
        i_k              : in std_logic_vector(9 downto 0);

        o_clear_reading  : out std_logic;
        o_en_reading     : out std_logic;
        o_update_reading : out std_logic;
        o_clear_writing  : out std_logic;
        o_en_writing     : out std_logic;
        o_done           : out std_logic
    );
end controllerFSM;

architecture arch_controllerFSM of controllerFSM is
signal all_zeroes : std_logic_vector(9 downto 0);
type state is (SETUP, READING, WRITING, WAIT_COMPLETION, DONE);
signal curr_state : state;
signal k_left : std_logic_vector(9 downto 0);
signal reading_duration : std_logic_vector(1 downto 0);
signal writing_duration : std_logic;
signal completion_duration : std_logic;
begin
    update_state : process(i_rst, i_clk)
    variable var_k_left : std_logic_vector(9 downto 0);
    begin
        var_k_left := (others => '0');
        if i_rst = '1' then
            all_zeroes <= (others => '0');
            curr_state <= SETUP;
            k_left <= var_k_left;
            reading_duration <= "10";
            writing_duration <= '1';
            completion_duration <= '1';
            o_update_reading <= '0';
        elsif rising_edge(i_clk) then
            all_zeroes <= (others => '0');
            if i_start = '1' then
                if curr_state = SETUP then
                    if i_k /= all_zeroes then
                        curr_state <= READING;
                        o_update_reading <= '1';
                        var_k_left := std_logic_vector(unsigned(i_k)-1);
                    else
                        curr_state <= DONE;
                    end if;
                elsif curr_state = READING then
                    var_k_left := k_left;
                    if reading_duration = "00" then
                        curr_state <= WRITING;
                        reading_duration <= "10";
                    else
                        o_update_reading <= '0';
                        reading_duration <= std_logic_vector(unsigned(reading_duration)-1);
                    end if;
                elsif curr_state = WRITING then
                    if writing_duration = '0' then
                        if k_left /= all_zeroes then
                            curr_state <= READING;
                            o_update_reading <= '1';
                            var_k_left := std_logic_vector(unsigned(k_left)-1);
                        else
                            curr_state <= WAIT_COMPLETION;
                        end if;
                        writing_duration <= '1';
                    else
                        var_k_left := k_left;
                        writing_duration <= '0';
                    end if;
                elsif curr_state = WAIT_COMPLETION then
                    if completion_duration = '0' then
                        curr_state <= DONE;
                        completion_duration <= '1';
                    else
                        completion_duration <= '0';
                    end if;
                end if;
            else
                curr_state <= SETUP;
            end if;
            k_left <= var_k_left;
        end if;
    end process;

    update_output : process(curr_state)
    begin
        o_en_reading <= '0';
        o_en_writing <= '0';
        o_done <= '0';
        o_clear_reading <= '0';
        o_clear_writing <= '0';
        if curr_state = READING then
            o_en_reading <= '1';
        elsif curr_state = WRITING then
            o_en_writing <= '1';
        elsif curr_state = DONE then
            o_done <= '1';
            o_clear_reading <= '1';
            o_clear_writing <= '1';
        end if;
    end process;
end arch_controllerFSM;



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
