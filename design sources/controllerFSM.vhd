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