import random

def generate_sequence(k_lenght):
    sequence = []
    i = 1
    while i <= k_lenght:
        choice = random.randint(0,10)
        if choice == 0:
            sequence.append(random.randint(0, 255))
        else:
            sequence.append(0)
        sequence.append(0)
        i+=1
    return sequence

def print_sequence(sequence):
    string = ""
    for index, num in enumerate(sequence):
        if index != len(sequence)-1:
            num_str = str(num) + ','
            string += f'{num_str:<4}'
        else:
            string += str(num)
    return string

def final_sequence_printer(num_seq):
    cred = 0
    prev_num = 0
    k_lenght = random.randint(1, 1023)
    sequence = generate_sequence(k_lenght)
    string = f"""
    constant SCENARIO{num_seq}_LENGTH : integer := {k_lenght};
    type scenario{num_seq}_type is array (0 to SCENARIO{num_seq}_LENGTH*2-1) of integer;
"""
    string += f"""    signal scenario{num_seq}_input : scenario{num_seq}_type := ("""
    string += print_sequence(sequence)
    string += ');\n'
    if len(sequence)%2 == 0:
        for index, num in enumerate(sequence):
            if index % 2 == 0:
                if num == 0:
                    sequence[index] = prev_num
                    if cred > 0:
                        cred -= 1
                else:
                    prev_num = num
                    cred = 31
            else:
                sequence[index] = cred
        string += f"""    signal scenario{num_seq}_full  : scenario{num_seq}_type := ("""
        string += print_sequence(sequence)
        string += ');\n'
    else:
        print("Something went wrong")
    return string, k_lenght, sequence



def write_test(num):
    final_RAM = []
    k_lefts = []
    final_sequences = []
    addresses = []
    i = 0
    while i <= 65535:
        final_RAM.append(0)
        i+=1
    with open('tb_general.vhd', 'w+') as file:
        section ="""-- TB EXAMPLE PFRL 2023-2024


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
"""
        file.write(section)
        i = 1
        while i <= num:
            section, k_left, final_sequence = final_sequence_printer(i)
            k_lefts.append(k_left)
            final_sequences.append(final_sequence)
            file.write(section)
            i+=1
        file.write("\n    signal memory_control : std_logic := '0';\n")
        i=1
        while i <= num:
            addr = random.randint(0, 65535-(k_lefts[i-1]*2))
            addresses.append(addr)
            for ind, num1 in enumerate(final_sequences[i-1]):
                final_RAM[addr+ind] = num1
            file.write(f"\n    constant SCENARIO{i}_ADDRESS : integer := {addr};")
            i+=1
        i=2
        section = """
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
"""
        file.write(section)
        while i <= num:
            section = f"""
        memory_control <= '0'; -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock
        -- Configure the memory
        for i in 0 to SCENARIO{i}_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO{i}_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario{i}_input(i), 8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);
        end loop;
        
        wait until falling_edge(tb_clk);
        
        memory_control <= '1'; -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO{i}_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO{i}_LENGTH, 10));
        
        tb_start <= '1';
        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';
"""
            file.write(section)
            i+=1
        i = 2
        section = """
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
"""
        file.write(section)
        while i <= num:
            section = f"""
        wait until rising_edge(tb_start);
        assert tb_done = '0' report "TEST FALLITO o_done != 0 after {i}th start" severity failure;
        
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done. ({i}th scenario)" severity failure;
        
        for i in 0 to SCENARIO{i}_LENGTH*2-1 loop
            assert RAM(SCENARIO{i}_ADDRESS+i) = std_logic_vector(to_unsigned(scenario{i}_full(i),8)) report "TEST ({i}th) FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario{i}_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO{i}_ADDRESS+i)))) severity failure;
        end loop;
        
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start ({i}th scenario)" severity failure;
        wait until falling_edge(tb_done);
"""
            file.write(section)
            i+=1
        i = 0
        seqmap = []
        while i <= len(k_lefts)-1:
            seqmap.append([addresses[i], addresses[i]+k_lefts[i]*2-1])
            i+=1
        seqmap.sort(key=lambda x: x[0])
        ranges_to_check = [[0, seqmap[0][0]-1]]
        i = 0
        while i <= len(seqmap)-2:
            if seqmap[i][1] > seqmap[i+1][0]:
                if seqmap[i+1][1] >= seqmap[i][1]-1:
                    seqmap[i][1] = seqmap[i + 1][1]
                seqmap.remove(seqmap[i+1])
            else:
                i+=1
        for n, check in enumerate(seqmap):
            if n < len(seqmap)-1:
                ranges_to_check.append([check[1]+1, seqmap[n+1][0]-1])
        ranges_to_check.append([seqmap[len(seqmap)-1][1]+1, 65535])
        i = 0
        while i <= len(ranges_to_check)-1:
            section = f"""
        for i in {ranges_to_check[i][0]} to {ranges_to_check[i][1]} loop
            assert RAM(i) = std_logic_vector(to_unsigned({final_RAM[i]},8)) report "TEST ({i}th) FALLITO" severity failure;
        end loop;
            """
            file.write(section)
            i += 1
        section = f"""
        assert false report "Simulation Ended! TEST PASSATO ({num} SCENARIOS)" severity failure;
    end process;

end architecture;
"""
        file.write(section)

sequences_count = 1000      # sequences_count specifies how many sequences are randomly generated and tested
write_test(sequences_count) # creates a testbench file named tb_general.vhd in the current directory
                            # the probability of getting a zero in the sequence has been vastly incresed because that tends to cause problems, which makes for a good test