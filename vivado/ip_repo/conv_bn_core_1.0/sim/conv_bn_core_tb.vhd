library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity conv_bn_core_tb is
end conv_bn_core_tb;

architecture Behavioral of conv_bn_core_tb is
    component conv_bn_core_v1_0 is generic (
        -- Parameters of Axi Slave Bus Interface S00_AXIS
        C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;
        -- Parameters of Axi Slave Bus Interface S01_AXIS
        C_S01_AXIS_TDATA_WIDTH	: integer	:= 32;
        -- Parameters of Axi Master Bus Interface M00_AXIS
        C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
        C_M00_AXIS_START_COUNT	: integer	:= 32;
        -- Parameters of Axi Master Bus Interface M01_AXIS
        C_M01_AXIS_TDATA_WIDTH	: integer	:= 32;
        C_M01_AXIS_START_COUNT	: integer	:= 32;
		-- Number of filter input/output
		NF 						: integer	:= 8);
	port (
		-- Users to add ports here
		clk_board : IN STD_LOGIC;
        clk_100 : IN STD_LOGIC;
        clk_50 : IN STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
		led_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		freq_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		max_m00_cnt_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		max_m01_cnt_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		max_s00_cnt_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		max_s01_cnt_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		wea00_o : OUT STD_LOGIC;
		addra00_o : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		addrb00_o : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		dina00dma0_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		dina00dma1_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		doutb00dma0_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		doutb00dma1_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		doutb01dma0_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		doutb01dma1_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		-- frame border
		x_is_min_o : OUT STD_LOGIC;
		x_is_max_o : OUT STD_LOGIC;
		y_is_min_o : OUT STD_LOGIC;
		y_is_max_o : OUT STD_LOGIC;
		x_o : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		y_o : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        -- 3x3 filter cells
        cell_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_4 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_5 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_6 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cell_8 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		eell_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_4 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_5 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_6 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_8 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		arm_enable_mm2s_tready : in STD_LOGIC;
		arm_update_weights : in STD_LOGIC;
		arm_update_conv_core_config : in STD_LOGIC;
		arm_xn_or_relu_or_pool : in STD_LOGIC_VECTOR(1 DOWNTO 0);
		arm_enable_filter : in STD_LOGIC;
		arm_merge_xn : in STD_LOGIC;
		arm_fc2_to_ddr : in STD_LOGIC;
		arm_update_fc1_b : in STD_LOGIC;
		arm_update_fc2_b : in STD_LOGIC;
		arm_update_fc1_data : in STD_LOGIC;
		arm_enable_fc1_filter : in STD_LOGIC;
		arm_enable_fc2_filter : in STD_LOGIC;
		arm_enable_fc_out_read_back : in STD_LOGIC;
		arm_delay_conv_valid0_start : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_delay_conv_valid1_start : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_delay_border_pix_deny_start : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_delay_conv_valid0_done : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_delay_conv_valid1_done : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_x_max : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_y_max : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_fc1_max : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_fc2_max : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_fc1_in_max : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		B_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		ka_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		be_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_select_conv_core_config : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_tic : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_toc : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		arm_precision : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- handshake
		arm_ack_done : IN STD_LOGIC;
		operation_done : OUT STD_LOGIC;
		-- User ports ends
		-- Do not modify the ports beyond this line
		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		-- s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;
		-- Ports of Axi Slave Bus Interface S01_AXIS
		s01_axis_aclk	: in std_logic;
		s01_axis_aresetn: in std_logic;
		s01_axis_tready	: out std_logic;
		s01_axis_tdata	: in std_logic_vector(C_S01_AXIS_TDATA_WIDTH-1 downto 0);
		-- s01_axis_tstrb	: in std_logic_vector((C_S01_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s01_axis_tlast	: in std_logic;
		s01_axis_tvalid	: in std_logic;
		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic;
		-- Ports of Axi Master Bus Interface M01_AXIS
		m01_axis_aclk	: in std_logic;
		m01_axis_aresetn: in std_logic;
		m01_axis_tvalid	: out std_logic;
		m01_axis_tdata	: out std_logic_vector(C_M01_AXIS_TDATA_WIDTH-1 downto 0);
		m01_axis_tstrb	: out std_logic_vector((C_M01_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m01_axis_tlast	: out std_logic;
		m01_axis_tready	: in std_logic);
    end component;
    constant C_S00_AXIS_TDATA_WIDTH : integer := 32;
    constant C_S01_AXIS_TDATA_WIDTH : integer := 32;
    constant C_M00_AXIS_TDATA_WIDTH : integer := 32;
    constant C_M01_AXIS_TDATA_WIDTH : integer := 32;
    signal clk_board : STD_LOGIC;
    signal clk_100 : STD_LOGIC;
    signal clk_50 : STD_LOGIC;
    signal btnl : STD_LOGIC;
    signal btnu : STD_LOGIC;
	signal led_o : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal freq_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal max_m00_cnt_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal max_m01_cnt_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal max_s00_cnt_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal max_s01_cnt_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- signal din   : STD_LOGIC_VECTOR(17 DOWNTO 0);
    -- signal wr_en : STD_LOGIC;
    -- signal rd_en : STD_LOGIC;
    -- signal dout01  : STD_LOGIC_VECTOR(17 DOWNTO 0);
    -- signal dout02  : STD_LOGIC_VECTOR(17 DOWNTO 0);
	signal wea00_o : STD_LOGIC;
	signal addra00_o : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal addrb00_o : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal dina00dma0_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal dina00dma1_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal doutb00dma0_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal doutb00dma1_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal doutb01dma0_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal doutb01dma1_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
	-- frame border
	signal x_is_min_o : STD_LOGIC;
	signal x_is_max_o : STD_LOGIC;
	signal y_is_min_o : STD_LOGIC;
	signal y_is_max_o : STD_LOGIC;
	signal x_o : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal y_o : STD_LOGIC_VECTOR(8 DOWNTO 0);
    -- 3x3 filter cells
    signal cell_0 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_5 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_6 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal cell_8 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal eell_0 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_5 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_6 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal eell_8 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal arm_enable_mm2s_tready	 : std_logic;
    signal arm_enable_filter	 : std_logic;
    signal arm_update_weights	 : std_logic;
    signal arm_update_conv_core_config	 : std_logic;
	signal arm_xn_or_relu_or_pool : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal arm_merge_xn	 : std_logic;
    signal arm_fc2_to_ddr	 : std_logic;
    signal arm_update_fc1_b	 : std_logic;
    signal arm_update_fc2_b	 : std_logic;
	signal arm_update_fc1_data	 : std_logic;
    signal arm_enable_fc1_filter	 : std_logic;
    signal arm_enable_fc2_filter	 : std_logic;
    signal arm_enable_fc_out_read_back	 : std_logic;
	signal arm_delay_conv_valid0_start : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_delay_conv_valid1_start : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_delay_border_pix_deny_start : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_delay_conv_valid0_done : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_delay_conv_valid1_done : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_x_max : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_y_max : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_fc1_max : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_fc2_max : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_fc1_in_max : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal B_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal ka_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal be_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_select_conv_core_config : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_tic, arm_toc : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_precision : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal arm_ack_done		 : STD_LOGIC;
	signal operation_done	 : STD_LOGIC;
    signal s00_axis_aclk	 : std_logic;
    signal s00_axis_aresetn  : std_logic;
    signal s00_axis_tready   : std_logic;
    signal s00_axis_tdata    : std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
    -- signal s00_axis_tstrb    : std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
    signal s00_axis_tlast    : std_logic;
    signal s00_axis_tvalid   : std_logic;
    signal s01_axis_aclk	 : std_logic;
    signal s01_axis_aresetn  : std_logic;
    signal s01_axis_tready   : std_logic;
    signal s01_axis_tdata    : std_logic_vector(C_S01_AXIS_TDATA_WIDTH-1 downto 0);
    -- signal s01_axis_tstrb    : std_logic_vector((C_S01_AXIS_TDATA_WIDTH/8)-1 downto 0);
    signal s01_axis_tlast    : std_logic;
    signal s01_axis_tvalid   : std_logic;    
    signal m00_axis_aclk	 : std_logic;
    signal m00_axis_aresetn  : std_logic;
    signal m00_axis_tvalid   : std_logic;
    signal m00_axis_tdata    : std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
    signal m00_axis_tstrb    : std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
    signal m00_axis_tlast    : std_logic;
    signal m00_axis_tready   : std_logic; 
    signal m01_axis_aclk	 : std_logic;
    signal m01_axis_aresetn  : std_logic;
    signal m01_axis_tvalid   : std_logic;
    signal m01_axis_tdata    : std_logic_vector(C_M01_AXIS_TDATA_WIDTH-1 downto 0);
    signal m01_axis_tstrb    : std_logic_vector((C_M01_AXIS_TDATA_WIDTH/8)-1 downto 0);
    signal m01_axis_tlast    : std_logic;
    signal m01_axis_tready   : std_logic; 
    
    signal cnt32b, cnt : unsigned(31 downto 0):=(others=>'0');
    -- Clock period definitions
    constant clk_period    : time := 10 ns;
    constant clk_50_period    : time := 20 ns;
    constant s00_axis_aclk_period : time := 10 ns;
    constant s01_axis_aclk_period : time := 10 ns;
    constant m00_axis_aclk_period : time := 10 ns;
    constant m01_axis_aclk_period : time := 10 ns;
	constant x_max : integer := 128-1; -- 512x384, 256x192, 128x96, 64x48, 32x24, 16x12
	constant y_max : integer := 128-1;
	constant fc1_max : integer := 128-1;--128-1; -- num of outputs in FC1
	constant fc2_max : integer := 80-1;--80-1; -- num of outputs in FC2
	constant ed : integer := 3+3; -- extra delay for conv, bn ed=3+2, relu ed=3+3, max pool ed=3+3
	constant fc1_in_x : integer := 64-1; -- 512x384, 256x192, 128x96, 64x48, 32x24, 16x12
	constant fc1_in_y : integer := 64-1;
	constant fc1_in_max : integer := (fc1_in_x+1)*(fc1_in_y+1)-1;--16*12-1;
begin

fifo_proc1: process
begin
	btnl <= '1';
	btnu <= '1';
	arm_precision <= x"00000001";
	arm_tic <= x"00000000";
	-- add reg to sum11
	arm_delay_conv_valid0_start <= STD_LOGIC_VECTOR(to_unsigned((ed+12+x_max)*2,32)); --
	arm_delay_conv_valid1_start <= STD_LOGIC_VECTOR(to_unsigned((ed+12+x_max)*2,32)); --
	arm_delay_border_pix_deny_start <= STD_LOGIC_VECTOR(to_unsigned((6+x_max)*2,32)); --
	arm_delay_conv_valid0_done <= STD_LOGIC_VECTOR(to_unsigned((ed+12+x_max)*2+1,32)); --
	arm_delay_conv_valid1_done <= STD_LOGIC_VECTOR(to_unsigned((ed+12+x_max)*2+1,32)); --
	arm_x_max <= STD_LOGIC_VECTOR(to_unsigned(x_max,32)); -- 511 max
	arm_y_max <= STD_LOGIC_VECTOR(to_unsigned(y_max,32)); -- 511 max
	arm_fc1_max <= STD_LOGIC_VECTOR(to_unsigned(fc1_max,32)); -- 1023 max
	arm_fc2_max <= STD_LOGIC_VECTOR(to_unsigned(fc2_max,32)); -- 1023 max
	arm_fc1_in_max <= STD_LOGIC_VECTOR(to_unsigned(fc1_in_max,32));
	B_in <= x"00000" & "000" & "000000000";
	ka_in <= x"0000" & "00000001" & "00000000";
	be_in <= x"0000" & "00000001" & "00000000";
	arm_select_conv_core_config <= x"00000000"; -- only last 3b, 0-7 configurations available
	arm_enable_mm2s_tready <= '0';
	wait for 100 ns;
	arm_enable_mm2s_tready <= '1';
    wait;
end process;

m_axis_tready: process
begin
    m00_axis_tready <= '0';
    m01_axis_tready <= '0';
    wait for 400 ns;
    m00_axis_tready <= '1';
    m01_axis_tready <= '1';
    wait;
end process;

s00_s01_axis: process
begin
	-- arm_enable_mm2s_tready <= '0';
	arm_update_fc1_b <= '0';						arm_update_fc2_b <= '0';
	arm_update_fc1_data <= '0';						arm_merge_xn <= '0';
	arm_enable_fc1_filter <= '0';					arm_enable_fc2_filter <= '0';
	arm_enable_fc_out_read_back <= '0';				arm_fc2_to_ddr <= '0';
	arm_update_weights <= '0';						arm_enable_filter <= '0';
	arm_update_conv_core_config <= '0';				arm_xn_or_relu_or_pool <= "10"; -- "10" or "11"-xn, "00"-relu, "01"-pool
    s00_axis_tlast <= '0'; 							s01_axis_tlast <= '0';
    s00_axis_tvalid <= '0'; 						s01_axis_tvalid <= '0';
    s00_axis_tdata <= (others=>'0');				s01_axis_tdata <= (others=>'0');
	arm_ack_done <= '0'; wait for clk_period; 		arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 500 ns;
	
	-- send fc1 b ------------------------------------------------------------------------------------
	arm_update_fc1_b <= '1';
	cnt32b <= x"00000001";
	wait for 100 ns;
	s00_axis_tvalid <= '1';							-- s01_axis_tvalid <= '1';
	for i in 0 to (fc1_max+1)/2-1 loop 				-- /2 because 2b/cycle
		cnt32b <= cnt32b + 1;
		-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00";				
		-- s00_axis_tdata <= x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0));				
		s00_axis_tdata <= x"0002" & x"0002"; 		-- CH 1 0
		if i=(fc1_max+1)/2-1 then
			s00_axis_tlast <= '1';					--s01_axis_tlast <= '1';
		end if;
		wait for clk_period;
	end loop;
	s00_axis_tlast <= '0';							--s01_axis_tlast <= '0';
	s00_axis_tvalid <= '0';							--s01_axis_tvalid <= '0';
	arm_update_fc1_b <= '0';
	cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000";

	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- send fc2 b ------------------------------------------------------------------------------------
	arm_update_fc2_b <= '1';
	cnt32b <= x"00000001";
	wait for 100 ns;
	s00_axis_tvalid <= '1';							-- s01_axis_tvalid <= '1';
	for i in 0 to (fc2_max+1)/2-1 loop 				-- /2 because 2b/cycle
		cnt32b <= cnt32b + 1;
		-- s00_axis_tdata <= x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0));
		-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00" & STD_LOGIC_VECTOR(cnt32b(7 downto 0)) & x"00";				
		s00_axis_tdata <= x"0000" & x"0000"; 		-- CH 1 0
		-- s00_axis_tdata <= x"0001" & x"0001"; 	-- CH 1 0
		if i=(fc2_max+1)/2-1 then
			s00_axis_tlast <= '1';					--s01_axis_tlast <= '1';
		end if;
		wait for clk_period;
	end loop;
	s00_axis_tlast <= '0';							--s01_axis_tlast <= '0';
	s00_axis_tvalid <= '0';							--s01_axis_tvalid <= '0';
	arm_update_fc2_b <= '0';
	cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000";

	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- send weights ------------------------------------------------------------------------------------
	arm_update_weights <= '1';
	wait for 100 ns; cnt <= (others=>'0');
	for i in 0 to 2047 loop
		cnt <= cnt + 1;
		s00_axis_tvalid <= '1';
		if cnt(3 downto 2) = "00" then -- B
			s00_axis_tdata <= x"0000" & x"0000";
		elsif cnt(3 downto 2) = "01" then -- ka
			if cnt(6 downto 4) = "000" then -- filter No. 0
				if(cnt(1 downto 0)="00" or cnt(1 downto 0)="10") then -- leave CH0 + CH4 ka = 1.0
					s00_axis_tdata <= x"0000" & x"0400";
				else
					s00_axis_tdata <= x"0000" & x"0000";
				end if;
				-- if 	  cnt(1 downto 0)="00" then -- leave CH1 ka = 1.0, CH0 ka = 1.0
					-- s00_axis_tdata <= x"0400" & x"0400";
				-- elsif cnt(1 downto 0)="01" then -- leave CH3 ka = 0.0, CH2 ka = 1.0
					-- s00_axis_tdata <= x"0400" & x"0400";
				-- elsif cnt(1 downto 0)="10" then -- leave CH5 ka = 0.0, CH4 ka = 1.0
					-- s00_axis_tdata <= x"0400" & x"0400";
				-- elsif cnt(1 downto 0)="11" then -- leave CH7 ka = 0.0, CH6 ka = 1.0
					-- s00_axis_tdata <= x"0400" & x"0400";
				-- else
					-- s00_axis_tdata <= x"0000" & x"0000";
				-- end if;
			elsif cnt(6 downto 4) = "001" then -- filter No. 1
				if(cnt(1 downto 0)="00" or cnt(1 downto 0)="10") then -- leave CH1 + CH5 ka = 1.0
					s00_axis_tdata <= x"0400" & x"0000";
				else
					s00_axis_tdata <= x"0000" & x"0000";
				end if;
			elsif cnt(6 downto 4) = "010" then -- filter No. 2
				if(cnt(1 downto 0)="01" or cnt(1 downto 0)="11") then -- leave CH2 + CH6 ka = 1.0
					s00_axis_tdata <= x"0000" & x"0400";
				else
					s00_axis_tdata <= x"0000" & x"0000";
				end if;
			elsif cnt(6 downto 4) = "011" then -- filter No. 3
				if(cnt(1 downto 0)="01" or cnt(1 downto 0)="11") then -- leave CH3 + CH7 ka = 1.0
					s00_axis_tdata <= x"0400" & x"0000";
				else
					s00_axis_tdata <= x"0000" & x"0000";
				end if;
			else
				s00_axis_tdata <= x"0000" & x"0000";
			end if;
		elsif cnt(3 downto 2) = "10" then -- be
			s00_axis_tdata <= x"0000" & x"0000";
		else							-- zeros
			s00_axis_tdata <= x"0000" & x"0000";
		end if;
		if i=2047 then
			s00_axis_tlast <= '1';
		end if;
		wait for clk_period;
	end loop;
	s00_axis_tvalid <= '0';
	s00_axis_tlast <= '0'; cnt <= (others=>'0');
	wait for 100 ns;
	arm_update_weights <= '0';
	wait for 500 ns;
	-- arm_update_weights <= '1';
	-- wait for 100 ns;
	-- for i in 0 to 2047 loop
		-- cnt <= cnt + 1;
		-- s00_axis_tvalid <= '1';
		-- if cnt(3 downto 2) = "00" then -- B
			-- s00_axis_tdata <= x"0000" & x"0000";
		-- elsif cnt(3 downto 2) = "01" then -- ka
			-- s00_axis_tdata <= x"0100" & x"0100";
		-- elsif cnt(3 downto 2) = "10" then -- be
			-- s00_axis_tdata <= x"0000" & x"0000";
		-- else							-- zeros
			-- s00_axis_tdata <= x"0000" & x"0000";
		-- end if;
		-- if i=2047 then
			-- s00_axis_tlast <= '1';
		-- end if;
		-- wait for clk_period;
	-- end loop;
	-- s00_axis_tvalid <= '0';
	-- s00_axis_tlast <= '0';
	-- wait for 100 ns;
	-- arm_update_weights <= '0';
	-- wait for 500 ns;
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- enable conv filter then send frame ------------------------------------------------------------------------------------
	arm_enable_filter <= '1'; 
	arm_merge_xn <= '1'; -- '1' if merging xn+xn
	wait for 100 ns;
    s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
    -- wait for clk_period*(512*512-1);
	for i in 0 to 2*(x_max+1)*(y_max+1)-1 loop
        cnt32b <= cnt32b + 1;
		-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
		if cnt32b(0) = '0' then -- even cycle
			-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
			-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
			s00_axis_tdata <= x"0400" & x"0400"; -- CH 1 0
			s01_axis_tdata <= x"0400" & x"0400"; -- CH 5 4
		else					-- odd cycle
			-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
			-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
			s00_axis_tdata <= x"0400" & x"0400"; -- CH 3 2
			s01_axis_tdata <= x"0400" & x"0400"; -- CH 7 6
		end if;
		if i=2*(x_max+1)*(y_max+1)-1 then
			s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
		end if;
        wait for clk_period;
    end loop;
    s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
    -- s00_axis_tdata <= STD_LOGIC_VECTOR(to_unsigned(0,32));
    s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
    arm_enable_filter <= '0';
	arm_merge_xn <= '0'; -- if merging xn+xn
	cnt32b <= (others=>'0');
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	
	-- FC 1st run
	
	
	for j in 0 to 0 loop
		-- send ch0-ch7 fc1 input data ------------------------------------------------------------------------------------
		arm_update_fc1_data <= '1';
		wait for 100 ns;
		s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
		-- for i in 0 to 2*(fc1_in_x+1)*(fc1_in_y+1)-1 loop
		for i in 0 to 2*(fc1_in_max+1)-1 loop
			cnt32b <= cnt32b + 1;
			-- cnt32b <= x"00000002";
			-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
			if cnt32b(0) = '0' then -- even cycle
				-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s00_axis_tdata <= x"0200" & x"0100"; -- CH 1 0
				-- s01_axis_tdata <= x"0600" & x"0500"; -- CH 5 4
				s00_axis_tdata <= x"0400" & x"0400"; -- CH 1 0
				s01_axis_tdata <= x"0000" & x"0000"; -- CH 5 4
			else					-- odd cycle
				-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s00_axis_tdata <= x"0400" & x"0300"; -- CH 3 2
				-- s01_axis_tdata <= x"0800" & x"0700"; -- CH 7 6
				s00_axis_tdata <= x"0000" & x"0000"; -- CH 3 2
				s01_axis_tdata <= x"0000" & x"0000"; -- CH 7 6
			end if;
			-- if i=2*(fc1_in_x+1)*(fc1_in_y+1)-1 then
			if i=2*(fc1_in_max+1)-1 then
				s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
			end if;
			wait for clk_period;
		end loop;
		s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
		s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
		arm_update_fc1_data <= '0';
		cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";

		-- arm op ack
		while operation_done = '0' loop
			wait for clk_period;
		end loop;
		arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
		wait for 1 us;
		
		-- stream fc1 weights, compute FC1 output ------------------------------------------------------------------------------------
		arm_enable_fc1_filter <= '1';
		wait for 100 ns;
		s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
		-- for i in 0 to 8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 loop -- /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
		for i in 0 to 8*(fc1_max+1)/2*(fc1_in_max+1)/2-1 loop --8* eight CH, /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
			cnt32b <= cnt32b + 2;
			-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
			-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
			-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
			s00_axis_tdata <= x"0002" & x"0002"; -- CH 1 0
			s01_axis_tdata <= x"0002" & x"0002"; -- CH 5 4
			-- if i=8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 then
			if i=8*(fc1_max+1)/2*(fc1_in_max+1)/2-1 then
				s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
			end if;
			wait for clk_period;
		end loop;
		arm_enable_fc_out_read_back <= '1'; -- enable before next data load or processing of  8x 64 x 48 mem
		s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
		s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
		arm_enable_fc1_filter <= '0';
		cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";
		
		-- arm op ack
		while operation_done = '0' loop
			wait for clk_period;
		end loop;
		arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
		wait for 1 us;
	end loop;
	arm_enable_fc_out_read_back <= '0';
	
	-- stream fc2 weights, compute FC2 output
	arm_enable_fc2_filter <= '1';
	wait for 100 ns;
	s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
	-- for i in 0 to 8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 loop -- /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
	for i in 0 to 2*(fc2_max+1)/2*(fc1_max+1)/2/2-1 loop -- 2* two CH, /2 because dma0 and dma1, /2 because two w in a cycle, /2 because (fc1_max+1) neurons are for two CH - continuous stream of w for all FC1 out = fc1_max+1
		cnt32b <= cnt32b + 2;
		-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
		-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
		-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
		s00_axis_tdata <= x"FE40" & x"FE40"; -- CH 1 0
		s01_axis_tdata <= x"FE40" & x"FE40"; -- CH 5 4
		-- if i=8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 then
		if i=2*(fc2_max+1)/2*(fc1_max+1)/2/2-1 then
			s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
		end if;
		wait for clk_period;
	end loop;
	s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
	s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
	arm_enable_fc2_filter <= '0';
	cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- FC1 to DDR ------------------------------------------------------------------------------------
	arm_enable_fc1_filter <= '1';	wait for 2*clk_period;	arm_enable_fc1_filter <= '0';	wait for clk_period;
	arm_fc2_to_ddr <= '1'; 		-- 0-relu_or_pool, 1-fc2 (priority to read fc2)
	wait for 2*clk_period;
	arm_fc2_to_ddr <= '0'; 
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- FC2 to DDR ------------------------------------------------------------------------------------
	arm_enable_fc2_filter <= '1';	wait for 2*clk_period;	arm_enable_fc2_filter <= '0';	wait for clk_period;
	arm_fc2_to_ddr <= '1'; 		-- 0-relu_or_pool, 1-fc2 (priority to read fc2)
	wait for 2*clk_period;
	arm_fc2_to_ddr <= '0'; 
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	
	-- FC 2nd run --
	
	
	for j in 0 to 0 loop
		-- send ch0-ch7 fc1 input data ------------------------------------------------------------------------------------
		arm_update_fc1_data <= '1';
		wait for 100 ns;
		s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
		-- for i in 0 to 2*(fc1_in_x+1)*(fc1_in_y+1)-1 loop
		for i in 0 to 2*(fc1_in_max+1)-1 loop
			cnt32b <= cnt32b + 1;
			-- cnt32b <= x"00000002";
			-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
			if cnt32b(0) = '0' then -- even cycle
				-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s00_axis_tdata <= x"0200" & x"0100"; -- CH 1 0
				-- s01_axis_tdata <= x"0600" & x"0500"; -- CH 5 4
				s00_axis_tdata <= x"0010" & x"0010"; -- CH 1 0
				s01_axis_tdata <= x"0010" & x"0010"; -- CH 5 4
			else					-- odd cycle
				-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(2 downto 1)) & x"00";		
				-- s00_axis_tdata <= x"0400" & x"0300"; -- CH 3 2
				-- s01_axis_tdata <= x"0800" & x"0700"; -- CH 7 6
				s00_axis_tdata <= x"0010" & x"0010"; -- CH 3 2
				s01_axis_tdata <= x"0010" & x"0010"; -- CH 7 6
			end if;
			-- if i=2*(fc1_in_x+1)*(fc1_in_y+1)-1 then
			if i=2*(fc1_in_max+1)-1 then
				s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
			end if;
			wait for clk_period;
		end loop;
		s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
		s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
		arm_update_fc1_data <= '0';
		cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";

		-- arm op ack
		while operation_done = '0' loop
			wait for clk_period;
		end loop;
		arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
		wait for 1 us;
		
		-- stream fc1 weights, compute FC1 output ------------------------------------------------------------------------------------
		arm_enable_fc1_filter <= '1';
		wait for 100 ns;
		s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
		-- for i in 0 to 8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 loop -- /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
		for i in 0 to 8*(fc1_max+1)/2*(fc1_in_max+1)/2-1 loop --8* eight CH, /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
			cnt32b <= cnt32b + 2;
			-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
			-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
			-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
			s00_axis_tdata <= x"0010" & x"0010"; -- CH 1 0
			s01_axis_tdata <= x"0010" & x"0010"; -- CH 5 4
			-- if i=8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 then
			if i=8*(fc1_max+1)/2*(fc1_in_max+1)/2-1 then
				s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
			end if;
			wait for clk_period;
		end loop;
		arm_enable_fc_out_read_back <= '1'; -- enable before next data load or processing of  8x 64 x 48 mem
		s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
		s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
		arm_enable_fc1_filter <= '0';
		cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";
		
		-- arm op ack
		while operation_done = '0' loop
			wait for clk_period;
		end loop;
		arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
		wait for 1 us;
	end loop;
	arm_enable_fc_out_read_back <= '0';
	
	-- stream fc2 weights, compute FC2 output
	arm_enable_fc2_filter <= '1';
	wait for 100 ns;
	s00_axis_tvalid <= '1';							s01_axis_tvalid <= '1';
	-- for i in 0 to 8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 loop -- /2 because dma0 and dma1, /2 because two w in a cycle, (fc1_max+1) - continuous stream of w for all FC1 out = fc1_max+1
	for i in 0 to 2*(fc2_max+1)/2*(fc1_max+1)/2/2-1 loop -- 2* two CH, /2 because dma0 and dma1, /2 because two w in a cycle, /2 because (fc1_max+1) neurons are for two CH - continuous stream of w for all FC1 out = fc1_max+1
		cnt32b <= cnt32b + 2;
		-- s00_axis_tdata <= STD_LOGIC_VECTOR(cnt32b(31 downto 0));
		-- s00_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
		-- s01_axis_tdata <= x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)+1) & x"00" & x"0" & "00" & STD_LOGIC_VECTOR(cnt32b(1 downto 0)) & x"00";		
		s00_axis_tdata <= x"0010" & x"0010"; -- CH 1 0
		s01_axis_tdata <= x"0010" & x"0010"; -- CH 5 4
		-- if i=8*(fc1_max+1)/2*((fc1_in_x+1)/2)*(fc1_in_y+1)-1 then
		if i=2*(fc2_max+1)/2*(fc1_max+1)/2/2-1 then
			s00_axis_tlast <= '1';					s01_axis_tlast <= '1';
		end if;
		wait for clk_period;
	end loop;
	s00_axis_tlast <= '0';							s01_axis_tlast <= '0';
	s00_axis_tvalid <= '0';							s01_axis_tvalid <= '0';
	arm_enable_fc2_filter <= '0';
	cnt32b <= (others=>'0');						s00_axis_tdata <= x"0000" & x"0000"; s01_axis_tdata <= x"0000" & x"0000";
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- FC1 to DDR ------------------------------------------------------------------------------------
	arm_enable_fc1_filter <= '1';	wait for 2*clk_period;	arm_enable_fc1_filter <= '0';	wait for clk_period;
	arm_fc2_to_ddr <= '1'; 		-- 0-relu_or_pool, 1-fc2 (priority to read fc2)
	wait for 2*clk_period;
	arm_fc2_to_ddr <= '0'; 
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	-- FC2 to DDR ------------------------------------------------------------------------------------
	arm_enable_fc2_filter <= '1';	wait for 2*clk_period;	arm_enable_fc2_filter <= '0';	wait for clk_period;
	arm_fc2_to_ddr <= '1'; 		-- 0-relu_or_pool, 1-fc2 (priority to read fc2)
	wait for 2*clk_period;
	arm_fc2_to_ddr <= '0'; 
	
	-- arm op ack
	while operation_done = '0' loop
		wait for clk_period;
	end loop;
	arm_ack_done <= '1'; wait for clk_period; arm_ack_done <= '0';
	wait for 1 us;
	
	--
	
	wait for 1 us;
	wait;
end process;

design1: conv_bn_core_v1_0 
port map (
    clk_board => clk_board,
    clk_100 => clk_100,
    clk_50 => clk_50,
    btnl => btnl,
    btnu => btnu,
    led_o => led_o,
    freq_o => freq_o,
    max_m00_cnt_o => max_m00_cnt_o,
    max_m01_cnt_o => max_m01_cnt_o,
    max_s00_cnt_o => max_s00_cnt_o,
    max_s01_cnt_o => max_s01_cnt_o,
	wea00_o => wea00_o,
	addra00_o => addra00_o,
	addrb00_o => addrb00_o,
	dina00dma0_o => dina00dma0_o,
	dina00dma1_o => dina00dma1_o,
	doutb00dma0_o => doutb00dma0_o,
	doutb00dma1_o => doutb00dma1_o,
	doutb01dma0_o => doutb01dma0_o,
	doutb01dma1_o => doutb01dma1_o,
-- frame border
	x_is_min_o => x_is_min_o,
	x_is_max_o => x_is_max_o,
	y_is_min_o => y_is_min_o,
	y_is_max_o => y_is_max_o,
	x_o => x_o,
	y_o => y_o,
-- 3x3 filter cells
    cell_0 => cell_0,
    cell_1 => cell_1,
    cell_2 => cell_2,
    cell_3 => cell_3,
    cell_4 => cell_4,
    cell_5 => cell_5,
    cell_6 => cell_6,
    cell_7 => cell_7,
    cell_8 => cell_8,
    eell_0 => eell_0,
	eell_1 => eell_1,
    eell_2 => eell_2,
    eell_3 => eell_3,
    eell_4 => eell_4,
    eell_5 => eell_5,
    eell_6 => eell_6,
    eell_7 => eell_7,
    eell_8 => eell_8,
    arm_update_weights => arm_update_weights,
    arm_update_conv_core_config => arm_update_conv_core_config,
    arm_xn_or_relu_or_pool => arm_xn_or_relu_or_pool,
    arm_enable_filter => arm_enable_filter,
    arm_merge_xn => arm_merge_xn,
    arm_fc2_to_ddr => arm_fc2_to_ddr,
    arm_update_fc1_b => arm_update_fc1_b,
    arm_update_fc2_b => arm_update_fc2_b,
    arm_update_fc1_data => arm_update_fc1_data,
    arm_enable_fc1_filter => arm_enable_fc1_filter,
    arm_enable_fc2_filter => arm_enable_fc2_filter,
    arm_enable_fc_out_read_back => arm_enable_fc_out_read_back,
    arm_enable_mm2s_tready => arm_enable_mm2s_tready,
    arm_delay_conv_valid0_start => arm_delay_conv_valid0_start,
    arm_delay_conv_valid1_start => arm_delay_conv_valid1_start,
    arm_delay_border_pix_deny_start => arm_delay_border_pix_deny_start,
	arm_delay_conv_valid0_done => arm_delay_conv_valid0_done,
	arm_delay_conv_valid1_done => arm_delay_conv_valid1_done,
	arm_x_max => arm_x_max,
	arm_y_max => arm_y_max,
	arm_fc1_max => arm_fc1_max,
	arm_fc2_max => arm_fc2_max,
	arm_fc1_in_max => arm_fc1_in_max,
	B_in => B_in,
	ka_in => ka_in,
	be_in => be_in,
	arm_select_conv_core_config => arm_select_conv_core_config,
	arm_tic => arm_tic,
	arm_toc => arm_toc,
	arm_precision => arm_precision,
	
	arm_ack_done => arm_ack_done,
	operation_done => operation_done,
	
    s00_axis_aclk => s00_axis_aclk,
    s00_axis_aresetn => s00_axis_aresetn,
    s00_axis_tready => s00_axis_tready,
    s00_axis_tdata => s00_axis_tdata,
    -- s00_axis_tstrb => s00_axis_tstrb,
    s00_axis_tlast => s00_axis_tlast,
    s00_axis_tvalid => s00_axis_tvalid,

    s01_axis_aclk => s01_axis_aclk,
    s01_axis_aresetn => s01_axis_aresetn,
    s01_axis_tready => s01_axis_tready,
    s01_axis_tdata => s01_axis_tdata,
    -- s01_axis_tstrb => s01_axis_tstrb,
    s01_axis_tlast => s01_axis_tlast,
    s01_axis_tvalid => s01_axis_tvalid,

    m00_axis_aclk => m00_axis_aclk,
    m00_axis_aresetn => m00_axis_aresetn,
    m00_axis_tvalid => m00_axis_tvalid,
    m00_axis_tdata => m00_axis_tdata,
    m00_axis_tstrb => m00_axis_tstrb,
    m00_axis_tlast => m00_axis_tlast,
    m00_axis_tready => m00_axis_tready,

    m01_axis_aclk => m01_axis_aclk,
    m01_axis_aresetn => m01_axis_aresetn,
    m01_axis_tvalid => m01_axis_tvalid,
    m01_axis_tdata => m01_axis_tdata,
    m01_axis_tstrb => m01_axis_tstrb,
    m01_axis_tlast => m01_axis_tlast,
    m01_axis_tready => m01_axis_tready
);

-- Clock 100 process definitions
clk_100_process :process
begin
    clk_board <= '1';
    clk_100 <= '1';
    wait for clk_period/2;
    clk_board <= '0';
	clk_100 <= '0';
    wait for clk_period/2;
end process;

-- Clock 50 process definitions
clk_50_process :process
begin
    clk_50 <= '1';
    wait for clk_50_period/2;
	clk_50 <= '0';
    wait for clk_50_period/2;
end process;

-- Clock PL process definitions
m01_clk_process :process
begin
    s00_axis_aclk <= '1';
    s01_axis_aclk <= '1';
    m00_axis_aclk <= '1';
    m01_axis_aclk <= '1';
    wait for m01_axis_aclk_period/2;
    s00_axis_aclk <= '0';
    s01_axis_aclk <= '0';
    m00_axis_aclk <= '0';
    m01_axis_aclk <= '0';
    wait for m01_axis_aclk_period/2;
end process;

reset_proc0: process
begin
    s00_axis_aresetn <= '0';
    s01_axis_aresetn <= '0';
    m00_axis_aresetn <= '0';
    m01_axis_aresetn <= '0';
    wait for 100 ns;
    s00_axis_aresetn <= '1';
    s01_axis_aresetn <= '1';
    m00_axis_aresetn <= '1';
    m01_axis_aresetn <= '1';
    wait;
end process;

end Behavioral;