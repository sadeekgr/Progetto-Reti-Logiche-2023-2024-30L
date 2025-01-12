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