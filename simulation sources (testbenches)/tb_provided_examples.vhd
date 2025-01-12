-- TB EXAMPLE PFRL 2023-2024


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity project_tb_multiple_starts is
end project_tb_multiple_starts;

architecture project_tb_arch of project_tb_multiple_starts is
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);

    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    constant SCENARIO1_LENGTH : integer := 10;
    type scenario1_type is array (0 to SCENARIO1_LENGTH*2-1) of integer;
    signal scenario1_input : scenario1_type := (51, 00, 00, 00, 57, 00, 24, 00, 00, 00, 00, 00,126, 00, 00, 00,192, 00, 00, 00);
    signal scenario1_full  : scenario1_type := (51, 31, 51, 30, 57, 31, 24, 31, 24, 30, 24, 29,126, 31,126, 30,192, 31,192, 30);
    
    constant SCENARIO2_LENGTH : integer := 35;
    type scenario2_type is array (0 to SCENARIO2_LENGTH*2-1) of integer;
    signal scenario2_input : scenario2_type := (51, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00);                                                                                    
    signal scenario2_full  : scenario2_type := (51, 31, 51, 30, 51, 29, 51, 28, 51, 27, 51, 26, 51, 25, 51, 24, 51, 23, 51, 22, 51, 21, 51, 20, 51, 19, 51, 18, 51, 17, 51, 16, 51, 15, 51, 14, 51, 13, 51, 12, 51, 11, 51, 10, 51, 09, 51, 08, 51, 07, 51, 06, 51, 05, 51, 04, 51, 03, 51, 02, 51, 01, 51, 00, 51, 00, 51, 00, 51, 00);
    
    constant SCENARIO3_LENGTH : integer := 33;
    type scenario3_type is array (0 to SCENARIO3_LENGTH*2-1) of integer;
    signal scenario3_input : scenario3_type := (00, 00, 255,00, 00, 00, 00, 00, 137,00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 111,00, 00, 00, 00, 00, 00, 00, 181,00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 246,00, 124,00, 00, 00, 93, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00);
    signal scenario3_full  : scenario3_type := (00, 00, 255,31, 255,30, 255,29, 137,31, 137,30, 137,29, 137,28, 137,27, 137,26, 137,25, 137,24, 137,23, 111,31, 111,30, 111,29, 111,28, 181,31, 181,30, 181,29, 181,28, 181,27, 181,26, 246,31, 124,31, 124,30, 93, 31, 93, 30, 93, 29, 93, 28, 93, 27, 93, 26, 93, 25);

    constant SCENARIO4_LENGTH : integer := 10;
    type scenario4_type is array (0 to SCENARIO4_LENGTH*2-1) of integer;
    signal scenario4_input : scenario4_type := (255,00, 00, 00, 00, 00, 143,00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00);
    signal scenario4_full  : scenario4_type := (255,31, 255,30, 255,29, 143,31, 143,30, 143,29, 143,28, 143,27, 143,26, 143,25);

    constant SCENARIO5_LENGTH : integer := 16;
    type scenario5_type is array (0 to SCENARIO5_LENGTH*2-1) of integer;
    signal scenario5_input : scenario5_type := (255,00, 91, 00, 161,00, 155,00, 178,00, 11, 00, 83, 00, 27, 00, 57, 00, 129,00, 39, 00, 243,00, 158,00, 173,00, 134,00, 58, 00);
    signal scenario5_full  : scenario5_type := (255,31, 91, 31, 161,31, 155,31, 178,31, 11, 31, 83, 31, 27, 31, 57, 31, 129,31, 39, 31, 243,31, 158,31, 173,31, 134,31, 58, 31);
    
    signal memory_control : std_logic := '0';

    constant SCENARIO1_ADDRESS : integer := 100;
    constant SCENARIO2_ADDRESS : integer := 100;
    constant SCENARIO3_ADDRESS : integer := 532;
    constant SCENARIO4_ADDRESS : integer := 19;
    constant SCENARIO5_ADDRESS : integer := 944;
    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                
                o_done => tb_done,
                
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.
    
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        wait for 50 ns;

        -- Signal initialization and reset of the component
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        
        -- Wait some time for the component to reset...
        wait for 50 ns;
        
        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO1_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO1_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario1_input(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO1_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO1_LENGTH, 10));
        
        tb_start <= '1';
        
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 10 ns;     -- small delay between done=1 and start=0
        tb_start <= '0';

        memory_control <= '0'; -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock
        -- Configure the memory
        for i in 0 to SCENARIO2_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO2_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario2_input(i), 8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);
        end loop;
        
        wait until falling_edge(tb_clk);
        
        memory_control <= '1'; -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO2_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO2_LENGTH, 10));
        
        tb_start <= '1';
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';

        memory_control <= '0'; -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock
        -- Configure the memory
        for i in 0 to SCENARIO3_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO3_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario3_input(i), 8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);
        end loop;
        
        wait until falling_edge(tb_clk);
        
        memory_control <= '1'; -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO3_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO3_LENGTH, 10));
        
        tb_start <= '1';
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';

        memory_control <= '0'; -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock
        -- Configure the memory
        for i in 0 to SCENARIO4_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO4_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario4_input(i), 8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);
        end loop;
        
        wait until falling_edge(tb_clk);
        
        memory_control <= '1'; -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO4_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO4_LENGTH, 10));
        
        tb_start <= '1';
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';

        memory_control <= '0'; -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock
        -- Configure the memory
        for i in 0 to SCENARIO5_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO5_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario5_input(i), 8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);
        end loop;
        
        wait until falling_edge(tb_clk);
        
        memory_control <= '1'; -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO5_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO5_LENGTH, 10));
        
        tb_start <= '1';
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';

        wait;
    end process;

    -- Process without sensitivity list designed to test the actual component.
    test_routine : process
    begin

        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';

        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO1_LENGTH*2-1 loop
            assert RAM(SCENARIO1_ADDRESS+i) = std_logic_vector(to_unsigned(scenario1_full(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario1_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO1_ADDRESS+i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);

        wait until rising_edge(tb_start);
        assert tb_done = '0' report "TEST FALLITO o_done != 0 after 2th start" severity failure;
        
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done. (2th scenario)" severity failure;
        
        for i in 0 to SCENARIO2_LENGTH*2-1 loop
            assert RAM(SCENARIO2_ADDRESS+i) = std_logic_vector(to_unsigned(scenario2_full(i),8)) report "TEST (2th) FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario2_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO2_ADDRESS+i)))) severity failure;
        end loop;
        
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start (2th scenario)" severity failure;
        wait until falling_edge(tb_done);

        wait until rising_edge(tb_start);
        assert tb_done = '0' report "TEST FALLITO o_done != 0 after 3th start" severity failure;
        
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done. (3th scenario)" severity failure;
        
        for i in 0 to SCENARIO3_LENGTH*2-1 loop
            assert RAM(SCENARIO3_ADDRESS+i) = std_logic_vector(to_unsigned(scenario3_full(i),8)) report "TEST (3th) FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario3_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO3_ADDRESS+i)))) severity failure;
        end loop;
        
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start (3th scenario)" severity failure;
        wait until falling_edge(tb_done);

        wait until rising_edge(tb_start);
        assert tb_done = '0' report "TEST FALLITO o_done != 0 after 4th start" severity failure;
        
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done. (4th scenario)" severity failure;
        
        for i in 0 to SCENARIO4_LENGTH*2-1 loop
            assert RAM(SCENARIO4_ADDRESS+i) = std_logic_vector(to_unsigned(scenario4_full(i),8)) report "TEST (4th) FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario4_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO4_ADDRESS+i)))) severity failure;
        end loop;
        
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start (4th scenario)" severity failure;
        wait until falling_edge(tb_done);

        wait until rising_edge(tb_start);
        assert tb_done = '0' report "TEST FALLITO o_done != 0 after 5th start" severity failure;
        
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done. (5th scenario)" severity failure;
        
        for i in 0 to SCENARIO5_LENGTH*2-1 loop
            assert RAM(SCENARIO5_ADDRESS+i) = std_logic_vector(to_unsigned(scenario5_full(i),8)) report "TEST (5th) FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario5_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO5_ADDRESS+i)))) severity failure;
        end loop;
        
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start (5th scenario)" severity failure;
        wait until falling_edge(tb_done);
        
        for i in 0 to 18 loop
            assert RAM(i) = std_logic_vector(to_unsigned(0,8)) report "TEST (1th) FALLITO" severity failure;
        end loop;
        
        for i in 39 to 99 loop
            assert RAM(i) = std_logic_vector(to_unsigned(0,8)) report "TEST (1th) FALLITO" severity failure;
        end loop;
        
        for i in 170 to 531 loop
            assert RAM(i) = std_logic_vector(to_unsigned(0,8)) report "TEST (1th) FALLITO" severity failure;
        end loop;
        
        for i in 598 to 943 loop
            assert RAM(i) = std_logic_vector(to_unsigned(0,8)) report "TEST (1th) FALLITO" severity failure;
        end loop;
                
        for i in 976 to 65535 loop
            assert RAM(i) = std_logic_vector(to_unsigned(0,8)) report "TEST (1th) FALLITO" severity failure;
        end loop;

        assert false report "Simulation Ended! TEST PASSATO (5 SCENARIOS)" severity failure;
    end process;

end architecture;
