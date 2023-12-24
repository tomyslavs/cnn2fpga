-- C:\vivado\project_12axis\project_12axis.sdk\app_ip\src Import source to SDK project
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity conv_bn_core_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

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
		NF 						: integer	:= 8
	);
	port (
		-- Users to add ports here
		-- fifo ports
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
        -- 3x3 filter cells
        eell_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_4 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_5 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_6 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        eell_8 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		-- control
		arm_enable_mm2s_tready : in STD_LOGIC;						-- hold hi when filtering and weigths update
		arm_enable_filter : in STD_LOGIC; 							-- _| edge and arm_enable_mm2s_tready hold hi
		arm_update_weights : in STD_LOGIC;							-- _| edge to update weights. B, ka, be from ddr to bram
		arm_update_conv_core_config : in STD_LOGIC;					-- _| edge to update conv core config, 0-7 configurations available
		arm_xn_or_relu_or_pool : in STD_LOGIC_VECTOR(1 DOWNTO 0);	-- hold hi when transfer mm2s and s2mm ends
		arm_merge_xn : in STD_LOGIC;								-- hold hi when transfer mm2s and s2mm ends
		arm_fc2_to_ddr : in STD_LOGIC;								-- starts at _| edge, hold not needed anymore (+ hold hi when transfer, because it denies arm_xn_or_relu_or_pool selection)
		arm_update_fc1_b : in STD_LOGIC;							-- _| edge to transfer and arm_enable_mm2s_tready hold hi
		arm_update_fc2_b : in STD_LOGIC;							-- _| edge to transfer and arm_enable_mm2s_tready hold hi
		arm_update_fc1_data : in STD_LOGIC;							-- _| edge to transfer and arm_enable_mm2s_tready hold hi
		arm_enable_fc1_filter : in STD_LOGIC;						-- hold hi when transfer
		arm_enable_fc2_filter : in STD_LOGIC;						-- hold hi when transfer
		arm_enable_fc_out_read_back : in STD_LOGIC;					-- hold hi when read back from bram to accumulate FC1/2 neurons: 1st iteration ='0', all next ='1'
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
--		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;
		-- Ports of Axi Slave Bus Interface S01_AXIS
		s01_axis_aclk	: in std_logic;
		s01_axis_aresetn: in std_logic;
		s01_axis_tready	: out std_logic;
		s01_axis_tdata	: in std_logic_vector(C_S01_AXIS_TDATA_WIDTH-1 downto 0);
--		s01_axis_tstrb	: in std_logic_vector((C_S01_AXIS_TDATA_WIDTH/8)-1 downto 0);
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
		m01_axis_tready	: in std_logic
	); 
end conv_bn_core_v1_0;

architecture arch_imp of conv_bn_core_v1_0 is 	
	-- filter block
	component filter_block_8in_1out is Port(
		clk_100 	: in STD_LOGIC;
		arm_prec	: in STD_LOGIC;
		arm_needs_xn: in STD_LOGIC;
		arm_merge_xn: in STD_LOGIC;
		even_tick 	: in STD_LOGIC;
		B_all_in  	: in STD_LOGIC_VECTOR(9*NF-1 DOWNTO 0);
		ka_all_in 	: in STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0);
		be_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		x33, x32, x31, x23, x22, x21, x13, x12, x11 : in STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0);
		m3, m2, m1, m0 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		xn_o 		: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		dsp_xn_o 	: out STD_LOGIC_VECTOR(19 DOWNTO 0);
		xn_relu_o 	: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		max_pool_o 	: out STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	end component filter_block_8in_1out;
	
	-- filter block
	component filter_block is Port( 	
		clk_100 	: in STD_LOGIC;
		even_tick 	: in STD_LOGIC;
		B_in  		: in STD_LOGIC_VECTOR(8 DOWNTO 0);
		ka_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		be_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		x33, x32, x31, x23, x22, x21, x13, x12, x11 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
		m3, m2, m1, m0 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		xn_o 		: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		dsp_xn_o 	: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		xn_relu_o 	: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		max_pool_o	: out STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	end component filter_block;
	
	-- dsp macro
	component dsp00 IS PORT(
		CLK : IN STD_LOGIC;
		A 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		B 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		C 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		P 	: OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
	);
	END component dsp00;
	
	-- bram fifo 512 x 128b, filter lines
	component blk_mem_gen_0 IS PORT(
		clka 	: IN STD_LOGIC;
		wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra 	: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dina 	: IN STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0);
		clkb 	: IN STD_LOGIC;
		addrb 	: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		doutb 	: OUT STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0)
	);
	END component blk_mem_gen_0;
	
	-- bram fifo IN 2048 x 32b, OUT 512 x 128b, weights
	component blk_mem_gen_1 IS PORT(
		clka 	: IN STD_LOGIC;
		wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra 	: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		dina 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		clkb 	: IN STD_LOGIC;
		addrb 	: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		doutb 	: OUT STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0)
	);
	END component blk_mem_gen_1;
	
	-- bram 64 x 64 = 4096 x 16b = 2048 x 32b, FC1 input data
	component blk_mem_gen_2 IS PORT(
		clka 	: IN STD_LOGIC;
		wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		dina 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clkb 	: IN STD_LOGIC;
		addrb 	: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		doutb 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END component blk_mem_gen_2;
	
	-- bram 2048 x 16b = 1024 x 32b, max = 2048 neurons on FC1/FC2 output to single BRAM, 4096 with dual BRAM
	component blk_mem_gen_3 IS PORT(
		clka 	: IN STD_LOGIC;
		wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra 	: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		dina 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clkb 	: IN STD_LOGIC;
		addrb 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		doutb 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END component blk_mem_gen_3;
	
	-- bram 2048 x 16b = 2048 x 16b, max = 2048 b_coef for FC1, FC2 in single BRAM, 4096 with dual BRAM
	component blk_mem_gen_4 IS PORT(
		clka 	: IN STD_LOGIC;
		wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra 	: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		dina 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clkb 	: IN STD_LOGIC;
		addrb 	: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		doutb 	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
	END component blk_mem_gen_4;
	
	-- dma
	signal L_m00_axis_tvalid, L_m01_axis_tvalid : std_logic:='0';
	signal L_m00_axis_tdata	: std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0):=(OTHERS=>'0');
	signal L_m00_axis_tlast, L_m01_axis_tlast : std_logic:='0';
	signal L_m01_axis_tdata	: std_logic_vector(C_M01_AXIS_TDATA_WIDTH-1 downto 0):=(OTHERS=>'0');
	-- bram
	signal wea00 : STD_LOGIC_VECTOR(0 DOWNTO 0):=(OTHERS=>'0');
	signal addra00, addra01 : STD_LOGIC_VECTOR(8 DOWNTO 0):=(OTHERS=>'0');
	signal dina_CH1_CH0, dina_CH3_CH2 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal dina_CH76543210, doutb00_CH76543210, doutb01_CH76543210 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
	signal dina_xn_relu, doutb_xn_relu : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
	signal CH1_CH0_reg, CH3_CH2_reg, CH5_CH4_reg, CH7_CH6_reg : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal addrb00, addrb01 : STD_LOGIC_VECTOR(8 DOWNTO 0):=(OTHERS=>'0');
	signal doutb00_CH1_CH0, doutb01_CH1_CH0 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal cnt00 : UNSIGNED(8 DOWNTO 0):=(OTHERS=>'0');
	-- bram weights wr/rd control
	signal wea_w : STD_LOGIC_VECTOR(0 DOWNTO 0):=(OTHERS=>'0');
	signal addra_w : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal dina_w : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_w : STD_LOGIC_VECTOR(8 DOWNTO 0):=(OTHERS=>'0');
	signal doutb_w : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
	type state_w_type is (s_idle, s_dma_wr);
	signal state_w : state_w_type := s_idle;
	type state_wa_type is (s_idle, s_incr_addr, s_assign_weights);
	signal state_wa : state_wa_type := s_idle;
	signal filter_idx : integer range 0 to 7:=0;
	signal addra_w_cnt : UNSIGNED(10 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_w_cnt, addrb_w_shift : UNSIGNED(8 DOWNTO 0):=(OTHERS=>'0');
	signal cnt_w, weight_type : UNSIGNED(1 DOWNTO 0):=(OTHERS=>'0');
	signal conv_core_config_4b : UNSIGNED(3 DOWNTO 0):=(OTHERS=>'0');
	signal t_s00_axis_tdata : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	signal t_arm_update_weights, t_s00_axis_tvalid, tt_s00_axis_tvalid, weights_wr_done, t_weights_wr_done : STD_LOGIC:='0';
	signal weights_assign_done, t_arm_update_conv_core_config : STD_LOGIC:='0';
	signal arm_xn_or_relu_or_pool_reg : STD_LOGIC_VECTOR(1 downto 0):=(others=>'0');
	-- FC 1 in 
	signal wea_f, wea_b1, wea_b2 : STD_LOGIC_VECTOR(0 DOWNTO 0):=(OTHERS=>'0');
	signal addra_f : STD_LOGIC_VECTOR(11 DOWNTO 0):=(OTHERS=>'0');
	signal addra_b1, addra_b2 : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal dina_f_ch0, dina_f_ch1, dina_f_ch2, dina_f_ch3, dina_f_ch4, dina_f_ch5, dina_f_ch6, dina_f_ch7 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal dina_b1_0, dina_b1_1, dina_b2_0, dina_b2_1 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal doutb_f_ch0, doutb_f_ch1, doutb_f_ch2, doutb_f_ch3, doutb_f_ch4, doutb_f_ch5, doutb_f_ch6, doutb_f_ch7 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal doutb_b_0, doutb_b_1, doutb_b1_0, doutb_b1_1, doutb_b2_0, doutb_b2_1 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_f : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_b : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal arm_update_fc1_data_reg, tt_fc_tvalid, t_fc_tvalid, tt_fc_tlast, t_fc_tlast, even_tick_f, fc_wr_done, switch_fc_in_ch : STD_LOGIC:='0';
	signal arm_update_fc1_b_reg, tt_fc1_b_tvalid, t_fc1_b_tvalid, tt_fc1_b_tlast, t_fc1_b_tlast, fc1_b_wr_done : STD_LOGIC:='0';
	signal arm_update_fc2_b_reg, tt_fc2_b_tvalid, t_fc2_b_tvalid, tt_fc2_b_tlast, t_fc2_b_tlast, fc2_b_wr_done : STD_LOGIC:='0';
	signal addra_f_cnt : UNSIGNED(11 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_f_cnt, addrb_limit : UNSIGNED(10 DOWNTO 0):=(OTHERS=>'0');
	signal addra_fc1_b_cnt, addra_fc2_b_cnt, addrb_fc_b_cnt, addrb_fc2_b_cnt : UNSIGNED(10 DOWNTO 0):=(OTHERS=>'0');
    type state_f_type is (s_idle, s_1);
	signal state_f, state_b1, state_b2 : state_f_type := s_idle;
	-- FC 1 out
	signal wea_g : STD_LOGIC_VECTOR(0 DOWNTO 0):=(OTHERS=>'0');
	signal addra_g, addra_g_tmp : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal dina_g0, dina_g1 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal doutb_g0, doutb_g1 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_g : STD_LOGIC_VECTOR(9 DOWNTO 0):=(OTHERS=>'0');
	signal arm_enable_fc1_filter_reg, tt_fc_g_tvalid, t_fc_g_tvalid, tt_fc_g_tlast, t_fc_g_tlast, fc_sum_captured, sum_fc_enabled : STD_LOGIC:='0';
	signal arm_enable_fc2_filter_reg, fc1_or_fc2, fc_works_now : STD_LOGIC:='0';
	signal addra_g_cnt : UNSIGNED(10 DOWNTO 0):=(OTHERS=>'0');
    type state_g_type is (s_idle, s_1, s_2, s_3, s_4);
	signal state_g : state_g_type := s_idle;
	signal fc1_max, fc1_half_max, fc_half_max, fc2_max, fc2_half_max, fc_out_cnt : UNSIGNED(11 DOWNTO 0):=(OTHERS=>'0'); -- 10b
	signal fc1_in_max : UNSIGNED(11 DOWNTO 0):=(OTHERS=>'0'); -- 12b
	signal fc_dma0_w0, fc_dma0_d0, fc_dma0_w1, fc_dma0_d1, fc_dma1_w0, fc_dma1_d0, fc_dma1_w1, fc_dma1_d1 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
	signal cap_sum_fc_dma0, cap_sum_fc_dma1, prev_iter_fc_dma0, prev_iter_fc_dma1 : SIGNED(15 DOWNTO 0):=(others=>'0');
	-- signal fc_dma0, fc_dma1, sum_fc_dma0, sum_fc_dma1 : SIGNED(24 DOWNTO 0):=(others=>'0');
	signal fc_dma0, fc_dma1, sum_fc_dma0, sum_fc_dma1 : SIGNED(31 DOWNTO 0):=(others=>'0');
	signal b_zero : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	signal fc_dma0_out0, fc_dma0_out1, fc_dma1_out0, fc_dma1_out1 : STD_LOGIC_VECTOR(32 DOWNTO 0):=(others=>'0');
	signal doutb_f_ch10, doutb_f_ch32, doutb_f_ch54, doutb_f_ch76, doutb_f_ch3210, doutb_f_ch7654, doutb_f_ch76543210 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal ch_sel : UNSIGNED(2 DOWNTO 0):=(OTHERS=>'0'); -- 3b
	signal ch_sel_1, ch_sel_2, ch_sel_22, en_fc_bram_rd_back, arm_enable_fc_out_read_back_reg : STD_LOGIC:='0';
	signal t_fc_dma0_weight, tt_fc_dma0_weight, ttt_fc_dma0_weight, tttt_fc_dma0_weight, ttttt_fc_dma0_weight : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	signal t_fc_dma1_weight, tt_fc_dma1_weight, ttt_fc_dma1_weight, tttt_fc_dma1_weight, ttttt_fc_dma1_weight : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	signal flag_fc_shift_reg, switch_fc_in_ch_shift_reg, fc_wr_done_reg : STD_LOGIC_VECTOR(19 DOWNTO 0):=(others=>'0');
	signal op_done, LL_arm_ack_done, L_arm_ack_done, fc1_wr_input_data_done, fc1_wr_results_done : STD_LOGIC:='0';
	-- FC 2 out
	signal wea_h : STD_LOGIC_VECTOR(0 DOWNTO 0):=(OTHERS=>'0');
	signal addra_h, addra_h_tmp : STD_LOGIC_VECTOR(10 DOWNTO 0):=(OTHERS=>'0');
	signal dina_h0, dina_h1 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal doutb_h0, doutb_h1 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal addrb_h : STD_LOGIC_VECTOR(9 DOWNTO 0):=(OTHERS=>'0');
	signal fc2_wr_results_done : STD_LOGIC:='0';
	signal cnt_to_start_sum_fc : UNSIGNED(3 DOWNTO 0):=(OTHERS=>'0'); -- 4b
	-- FC 2 to DDR
	signal arm_fc2_to_ddr_reg, L_arm_fc2_to_ddr_reg, fc2_valid, fc2_last, t_fc2_valid, t_fc2_last, fc2_to_ddr_enabled : STD_LOGIC:='0';
	signal shift_reg_fc2_valid, shift_reg_fc2_last : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
	signal m00_axis_tdata_fc2, m01_axis_tdata_fc2 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
	signal fc2_to_ddr_addrb_cnt : UNSIGNED(9 DOWNTO 0):=(OTHERS=>'0'); -- 8b
	type state_fc2_to_ddr_type is (s_idle, s_stream_fc2);
	signal state_fc2_to_ddr : state_fc2_to_ddr_type := s_idle;
	-- conv/bn/relu/max pool
    signal c0, c1, c2, c3, c4, c5, c6, c7, c8 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
    signal x33, x32, x31, x23, x22, x21, x13, x12, x11 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
    -- signal e0, e1, e2, e3, e4, e5, e6, e7, e8 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
    -- signal dout_01, dout_02, dout_03, dout_04 : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
    signal reg0, reg1, reg2, reg3, reg4, reg5, reg6 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
	signal reg7, reg8, reg9, reg10, reg11 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0):=(OTHERS=>'0');
    -- signal reh0, reh1, reh2, reh3, reh4, reh5, reh6 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS=>'0');
    -- signal ce0,ce1,ce2,ce3,ce4,ce5,ce6,ce7,ce8 : UNSIGNED(15 DOWNTO 0):=(OTHERS=>'0');--UNSIGNED(16*2-1 DOWNTO 0):=(OTHERS=>'0');
    -- signal ee0,ee1,ee2,ee3,ee4,ee5,ee6,ee7,ee8 : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');--UNSIGNED(16*2-1 DOWNTO 0):=(OTHERS=>'0');
    signal sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8,sum9,sum10,sum11 : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
    signal zum1,zum2,zum3,zum4,zum5,zum6,zum7,zum8,zum9,zum10,zum11 : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
    signal bin1, bin2, bin3, bin4 : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
    signal B : STD_LOGIC_VECTOR( 8 downto 0):=(OTHERS=>'0');
    signal ka : STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
    signal be : STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
	signal B0_in, B1_in, B2_in, B3_in, B4_in, B5_in, B6_in, B7_in : STD_LOGIC_VECTOR(8 DOWNTO 0):=(OTHERS=>'0');
	signal ka0_in, ka1_in, ka2_in, ka3_in, ka4_in, ka5_in, ka6_in, ka7_in : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal be0_in, be1_in, be2_in, be3_in, be4_in, be5_in, be6_in, be7_in : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	type B_all_in_type is array (0 to NF-1) of STD_LOGIC_VECTOR(9*NF-1 DOWNTO 0);
	signal B_all_in  : B_all_in_type:=(OTHERS=>(OTHERS=>'0'));
	type ka_all_in_type is array (0 to NF-1) of STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0);
	signal ka_all_in : ka_all_in_type:=(OTHERS=>(OTHERS=>'0'));
	type be_all_in_type is array (0 to NF-1) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal be_all_in, xn, xn_relu, max_pool : be_all_in_type:=(OTHERS=>(OTHERS=>'0'));
	type dsp_xn_type is array (0 to NF-1) of STD_LOGIC_VECTOR(19 DOWNTO 0);
	signal dsp_xn : dsp_xn_type:=(OTHERS=>(OTHERS=>'0'));
	type Bx_type is array (8 downto 0) of signed(15 downto 0);
	signal Bx : Bx_type:=(others=>(others=>'0'));
	signal SumBx : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
	signal ka_SumBx : SIGNED(31 downto 0):=(others=>'0');
	signal xn0, dsp_xn0, xn0_relu, max_pool0 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn1, dsp_xn1, xn1_relu, max_pool1 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn2, dsp_xn2, xn2_relu, max_pool2 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn3, dsp_xn3, xn3_relu, max_pool3 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn4, dsp_xn4, xn4_relu, max_pool4 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn5, dsp_xn5, xn5_relu, max_pool5 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn6, dsp_xn6, xn6_relu, max_pool6 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal xn7, dsp_xn7, xn7_relu, max_pool7 : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	signal ben : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	signal m00_axis_tdata_relu, m01_axis_tdata_relu, m00_axis_tdata_pool, m01_axis_tdata_pool : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	signal m0, m1, m2, m3 : STD_LOGIC_VECTOR(16*NF-1 DOWNTO 0) := (others=>'0');
	-- conv control
	signal cnt512 : UNSIGNED(18 DOWNTO 0):=(OTHERS=>'0'); -- 1b+9b+9b
	signal x_cnt, x_max, rd_shift : UNSIGNED(9 DOWNTO 0):=(OTHERS=>'0'); -- 10b
	signal y_cnt, y_max : UNSIGNED(8 DOWNTO 0):=(OTHERS=>'0'); -- 9b
	signal y_is_min, y_is_max, x_is_min, x_is_max, max_pool_valid, t_max_pool_valid, max_pool_valid_to_dma, max_pool_last_to_dma : STD_LOGIC:='0';
	signal L_arm_merge_xn_reg, arm_merge_xn_reg, arm_merge_xn_wider : STD_LOGIC:='0';
	signal shift_reg_max_pool_valid : STD_LOGIC_VECTOR(35 downto 0):=(others=>'0');
	signal shift_reg_max_pool_last : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
	-- control
	type state_type is (s_idle, s_1, s_2, s_3);
	signal state0, state1 : state_type := s_idle;
	signal cnt0_start, cnt1_start, cnt0_done, cnt1_done, cnt0, cnt1, cntd, cntd_start : UNSIGNED(19 DOWNTO 0):=(OTHERS=>'0');
	signal m00_valid, m01_valid, m00_last, m01_last, even_tick, even_tick_to_max_pool, tmp_reg0, tmp_reg1, tmp_reg2, arm_enable_mm2s_tready_reg, btnu_reg, arm_enable_filter_reg : STD_LOGIC:='0';
	-- test synchronous s00 s01
	signal s00_valid_captured, s01_valid_captured, s00_s01_valid_is_synchronous, m00_axis_tvalid_t, m01_axis_tvalid_t, tic_toc_enabled, tic_toc_enabled_t, arm_prec : STD_LOGIC:='0';
	signal led : STD_LOGIC_VECTOR(15 DOWNTO 0):=(OTHERS=>'0');
	signal st0, st1 : STD_LOGIC_VECTOR(1 DOWNTO 0):=(OTHERS=>'0');
	signal freq_cnt, cnt1s, freq, sum_ticks, cap_ticks, init_ticks : UNSIGNED(31 DOWNTO 0):=(OTHERS=>'0');
	signal max_m00_cnt, max_m01_cnt, max_s00_cnt, max_s01_cnt, m00_cnt, m01_cnt, s00_cnt, s01_cnt : UNSIGNED(31 DOWNTO 0):=(OTHERS=>'0');
begin
-- map output ports for testbench
x_o <= "00000000" & sum_fc_enabled; -- std_logic_vector(x_cnt(9 downto 1));
y_o <= "00000000" & fc_sum_captured; -- std_logic_vector(y_cnt(8 downto 0));
x_is_min_o <= x_is_min;
x_is_max_o <= x_is_max;
y_is_min_o <= y_is_min;
y_is_max_o <= y_is_max;

max_m00_cnt_o <= std_logic_vector(max_m00_cnt);
max_m01_cnt_o <= std_logic_vector(max_m01_cnt);
max_s00_cnt_o <= std_logic_vector(max_s00_cnt);
max_s01_cnt_o <= std_logic_vector(max_s01_cnt);
freq_o <= std_logic_vector(freq);
led_o <= led(15 downto 8) when btnl = '1' else led(7 downto 0);
led(15 downto 8) <= m00_axis_tdata_fc2(15 downto 8) when btnu = '1' else s00_axis_aresetn & s01_axis_aresetn & m00_axis_aresetn & m01_axis_aresetn & st0 & st1;
led(7 downto 0) <=  m00_axis_tdata_fc2( 7 downto 0) when btnu = '1' else s00_axis_tvalid & s01_axis_tvalid & m00_axis_tready & m01_axis_tready & m00_valid & m01_valid & arm_enable_mm2s_tready_reg & s00_s01_valid_is_synchronous;

-- cell_0 <= x"000" & "000" & wea_f;
-- cell_1 <= "0000" & addra_f;
-- cell_2 <= dina_f_ch0(15 downto 0);
cell_0 <= x"0" & "000" & '0' & "000" & fc1_or_fc2 & "000" & switch_fc_in_ch;
cell_1 <= x"000" & '0' & std_logic_vector(ch_sel);
cell_2 <= x"000" & "000" & en_fc_bram_rd_back;
-- cell_3 <= "00000" & addrb_f;
cell_3 <= "000000" & addrb_h;
cell_4 <= doutb_f_ch0(15 downto 0);
cell_5 <= doutb_f_ch0(31 downto 16);
-- cell_3 <= dina_f_ch1(15 downto 0);
-- cell_4 <= dina_f_ch2(15 downto 0);
-- cell_5 <= dina_f_ch3(15 downto 0);
-- cell_5 <= dina_f_ch3(15 downto 0);
cell_6 <= x"000" & "000" & wea_h;
-- cell_7 <= "0000000" & addra_h;
-- cell_7 <= std_logic_vector(doutb_h0(15 downto 0));
-- cell_8 <= std_logic_vector(dina_h0);
-- cell_8 <= std_logic_vector(doutb_h0(31 downto 16));
cell_8 <= x"000" & dsp_xn(0)(19 downto 16);
-- cell_6 <= xn(0);
cell_7 <= dsp_xn(0)(15 downto  0);
-- cell_8 <= xn_relu(0);
-- eell_0 <= max_pool(0);
eell_0 <= std_logic_vector(fc_dma0(15 downto 0));
-- eell_1 <= x"000" & "000" & max_pool_last_to_dma;
-- eell_2 <= x"000" & "000" & even_tick;
-- eell_3 <= x"000" & "000" & max_pool_valid_to_dma;
-- eell_4 <= x"000" & "000" & max_pool_valid;
eell_1 <= x"000" & "000" & wea_g; -- fc_dma0_out0(23 downto 8);
eell_2 <= fc_dma0_out1(23 downto 8);
-- eell_3 <= fc_dma1_out0(23 downto 8);
eell_3 <= "00000" & std_logic_vector(addra_g);
-- eell_4 <= fc_dma1_out1(23 downto 8);
-- eell_4 <= "00000000" & addrb_g;
eell_4 <= x"000" & "000" & fc2_to_ddr_enabled;
-- eell_4 <= x"000" & "000" & sum_fc_enabled;
-- eell_5 <= m01_axis_tdata_pool(31 downto 16);
-- eell_6 <= m01_axis_tdata_pool(15 downto 0);
-- eell_7 <= m00_axis_tdata_pool(31 downto 16);
-- eell_8 <= m00_axis_tdata_pool(15 downto 0);
eell_5 <= fc_dma0_w0;
-- eell_6 <= fc_dma0_w1;
-- eell_6 <= fc_dma0_d0;
-- eell_5 <= "0000000" & std_logic_vector(addrb_b);
eell_6 <= std_logic_vector(prev_iter_fc_dma0);
-- eell_6 <= std_logic_vector(dina_b1_0);
eell_7 <= std_logic_vector(cap_sum_fc_dma0); -- fc_dma0_d1;
-- eell_7 <= doutb_g0(15 downto 0);
-- eell_7 <= x"00" & '0' & op_done & fc1_b_wr_done & fc2_b_wr_done & fc1_wr_input_data_done & fc1_wr_results_done & weights_assign_done & m00_last;
-- eell_7 <= "000000" & wea_b1 & addra_b1;
-- eell_7 <= x"000" & "000" & sum_fc_enabled;
eell_8 <= std_logic_vector(sum_fc_dma0(15 downto 0));
-- eell_8 <= doutb_g0(31 downto 16);
-- eell_8 <= std_logic_vector(doutb_b1_0);

process(clk_100) -- handshake
begin
	if rising_edge(clk_100) then
		arm_prec <= arm_precision(0);
		init_ticks <= unsigned('0' & arm_tic(30 downto 0));			-- initial timer value
		tic_toc_enabled <= arm_tic(31);								-- start/done timer flag
		tic_toc_enabled_t <= tic_toc_enabled;						-- 1 bit shift reg.
		if tic_toc_enabled_t = '0' and tic_toc_enabled = '1' then	-- rising edge
			sum_ticks <= init_ticks;								-- assign initial value
		elsif tic_toc_enabled_t = '1' and tic_toc_enabled = '0' then-- falling edge
			cap_ticks <= sum_ticks;									-- capture sum of ticks
		elsif tic_toc_enabled = '1' then
			sum_ticks <= sum_ticks + 1;								-- increment counter
		end if;
		arm_toc <= std_logic_vector(cap_ticks);						-- assign to output
	end if;
end process;

process(clk_100) -- tic toc
begin
	if rising_edge(clk_100) then
		LL_arm_ack_done <= L_arm_ack_done; L_arm_ack_done <= arm_ack_done;
		if LL_arm_ack_done = '0' and L_arm_ack_done = '1' then -- rising edge of arm_ack_done
			op_done <= '0';
		elsif (fc2_last = '1' or 								-- fc2 results are in ddr memory
			  fc1_b_wr_done = '1' or fc2_b_wr_done = '1' or		-- b is in FC1 and FC2 bram memory
			  fc1_wr_input_data_done = '1' or					-- pixels are in FC1 input bram memory
			  fc1_wr_results_done = '1' or						-- results are in FC1 output bram memory
			  fc2_wr_results_done = '1' or						-- results are in FC2 output bram memory
			  weights_assign_done = '1' or 						-- weights for conv/BN assigned from MM2S => BRAM and BRAM to Conv core. Or arm updated conv core config to 0-7 available from bram
			  m00_last = '1')									-- conv, bn, relu, maxpool done
			then
			op_done <= '1';
		end if;
		operation_done <= op_done;
	end if;
end process;

-- FC1 and FC2 write b to BRAM
fc1_b1_0 : blk_mem_gen_4 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_b1,
	addra	=> addra_b1,
	dina	=> dina_b1_0,
	clkb	=> clk_100,
	addrb	=> addrb_b,
	doutb	=> doutb_b1_0
);
-- addrb_b <= "000000010"; -- test
fc1_b1_1 : blk_mem_gen_4 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_b1,
	addra	=> addra_b1,
	dina	=> dina_b1_1,
	clkb	=> clk_100,
	addrb	=> addrb_b,
	doutb	=> doutb_b1_1
);
fc2_b2_0 : blk_mem_gen_4 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_b2,
	addra	=> addra_b2,
	dina	=> dina_b2_0,
	clkb	=> clk_100,
	addrb	=> addrb_b,
	doutb	=> doutb_b2_0
);
fc2_b2_1 : blk_mem_gen_4 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_b2,
	addra	=> addra_b2,
	dina	=> dina_b2_1,
	clkb	=> clk_100,
	addrb	=> addrb_b,
	doutb	=> doutb_b2_1
);
process(clk_100) -- dma b -> fc1 bram
begin
	if rising_edge(clk_100) then
		tt_fc1_b_tvalid <= t_fc1_b_tvalid; t_fc1_b_tvalid <= s00_axis_tvalid;
		tt_fc1_b_tlast <= t_fc1_b_tlast; t_fc1_b_tlast <= s00_axis_tlast;
		case state_b1 is
			when s_idle =>
				if s00_axis_tvalid = '1' and arm_enable_mm2s_tready_reg = '1' and arm_update_fc1_b_reg = '1' then	-- valid mm2s data
					state_b1 <= s_1;
				end if;
				addra_fc1_b_cnt <= (others=>'0');
				wea_b1 <= "0";
				fc1_b_wr_done <= '0';
			when s_1 =>
				dina_b1_0 <= CH3_CH2_reg(15 downto 0);
				dina_b1_1 <= CH3_CH2_reg(31 downto 16);
				if t_fc1_b_tvalid = '1' then
					wea_b1 <= "1";
				else
					wea_b1 <= "0";
				end if;
				addra_fc1_b_cnt <= addra_fc1_b_cnt + 1;
				addra_b1 <= std_logic_vector(addra_fc1_b_cnt); -- wr addr
				if t_fc1_b_tlast = '1' then
					fc1_b_wr_done <= '1';
					state_b1 <= s_idle;
				end if;
			when others =>
				state_b1 <= s_idle;
		end case;
	end if;
end process;
process(clk_100) -- dma b -> fc2 bram
begin
	if rising_edge(clk_100) then
		tt_fc2_b_tvalid <= t_fc2_b_tvalid; t_fc2_b_tvalid <= s00_axis_tvalid;
		tt_fc2_b_tlast <= t_fc2_b_tlast; t_fc2_b_tlast <= s00_axis_tlast;
		case state_b2 is
			when s_idle =>
				if s00_axis_tvalid = '1' and arm_enable_mm2s_tready_reg = '1' and arm_update_fc2_b_reg = '1' then	-- valid mm2s data
					state_b2 <= s_1;
				end if;
				addra_fc2_b_cnt <= (others=>'0');
				wea_b2 <= "0";
				fc2_b_wr_done <= '0';
			when s_1 =>
				dina_b2_0 <= CH3_CH2_reg(15 downto 0);
				dina_b2_1 <= CH3_CH2_reg(31 downto 16);
				if t_fc2_b_tvalid = '1' then
					wea_b2 <= "1";
				else
					wea_b2 <= "0";
				end if;
				addra_fc2_b_cnt <= addra_fc2_b_cnt + 1;
				addra_b2 <= std_logic_vector(addra_fc2_b_cnt); -- wr addr
				if t_fc2_b_tlast = '1' then
					fc2_b_wr_done <= '1';
					state_b2 <= s_idle;
				end if;
			when others =>
				state_b2 <= s_idle;
		end case;
	end if;
end process;

-- FC 1 (fully connected 1) data in
fc1_in_ch0 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch0,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch0
);
fc1_in_ch1 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch1,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch1
);
fc1_in_ch2 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch2,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch2
);
fc1_in_ch3 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch3,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch3
);
fc1_in_ch4 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch4,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch4
);
fc1_in_ch5 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch5,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch5
);
fc1_in_ch6 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch6,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch6
);
fc1_in_ch7 : blk_mem_gen_2 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_f,
	addra	=> addra_f,
	dina	=> dina_f_ch7,
	clkb	=> clk_100,
	addrb	=> addrb_f,
	doutb	=> doutb_f_ch7
);

process(clk_100) -- dma data pixels -> fc1 bram
begin
	if rising_edge(clk_100) then
		tt_fc_tvalid <= t_fc_tvalid; t_fc_tvalid <= s00_axis_tvalid;
		tt_fc_tlast <= t_fc_tlast; t_fc_tlast <= s00_axis_tlast;
		case state_f is
			when s_idle =>
				if s00_axis_tvalid = '1' and arm_enable_mm2s_tready_reg = '1' and arm_update_fc1_data_reg = '1' then	-- valid mm2s data
					state_f <= s_1;
					even_tick_f <= '1';
				else
					even_tick_f <= '0';
				end if;
				addra_f_cnt <= (others=>'0');
				wea_f <= "0";
				fc1_wr_input_data_done <= '0';
			-- when s_0 => -- papildyti irasyma i CH0 ir CH1 per atskirtas DMA0/1, kai skaiciuojame FC2 loadinant data is DDR, padaryti visus FC 4096 ir b taip pat
			when s_1 =>
				even_tick_f <= not even_tick_f;
				if even_tick_f = '0' then -- save 4xCH=4x32b @ 50MHz (stream of 2CH @ 100MHz)
					dina_f_ch0 <= CH1_CH0_reg(15 downto 0);
					dina_f_ch1 <= CH1_CH0_reg(31 downto 16);
					dina_f_ch2 <= CH3_CH2_reg(15 downto 0);
					dina_f_ch3 <= CH3_CH2_reg(31 downto 16);
					dina_f_ch4 <= CH5_CH4_reg(15 downto 0);
					dina_f_ch5 <= CH5_CH4_reg(31 downto 16);
					dina_f_ch6 <= CH7_CH6_reg(15 downto 0);
					dina_f_ch7 <= CH7_CH6_reg(31 downto 16);
					if tt_fc_tvalid = '1' then
						wea_f <= "1";
					else
						wea_f <= "0";
					end if;
					addra_f_cnt <= addra_f_cnt + 1;
					addra_f <= std_logic_vector(addra_f_cnt); -- wr addr
				else
					wea_f <= "0";
				end if;
				if t_fc_tlast = '1' then
					fc1_wr_input_data_done <= '1';
					state_f <= s_idle;
				end if;
			when others =>
				state_f <= s_idle;
		end case;
	end if;
end process;

-- fc 1 output mem, 0-511 in, 0-255 out max
fc1_out_0 : blk_mem_gen_3 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_g,
	addra	=> addra_g,
	dina	=> dina_g0,
	clkb	=> clk_100,
	addrb	=> addrb_g,
	doutb	=> doutb_g0
);
dina_g0 <= std_logic_vector(cap_sum_fc_dma0);
-- fc 1 output mem, 512-1023 in, 256-511 out max
fc1_out_1 : blk_mem_gen_3 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_g,
	addra	=> addra_g,
	dina	=> dina_g1,
	clkb	=> clk_100,
	addrb	=> addrb_g,
	doutb	=> doutb_g1
);
dina_g1 <= std_logic_vector(cap_sum_fc_dma1);

-- fc 2 output mem, 0-255 max
fc2_out_0 : blk_mem_gen_3 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_h,
	addra	=> addra_h, -- 512a
	dina	=> dina_h0, -- 16b
	clkb	=> clk_100,
	addrb	=> addrb_h,	-- 256a
	doutb	=> doutb_h0	-- 32b
);
dina_h0 <= std_logic_vector(cap_sum_fc_dma0); -- pakeisti cap_sum_fc_dma0
-- fc 2 output mem, 256-511 max
fc2_out_1 : blk_mem_gen_3 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_h,
	addra	=> addra_h,
	dina	=> dina_h1,
	clkb	=> clk_100,
	addrb	=> addrb_h,
	doutb	=> doutb_h1
);
dina_h1 <= std_logic_vector(cap_sum_fc_dma1); -- pakeisti cap_sum_fc_dma1

process(clk_100) -- dma fc1 weights x bram pixels
begin
	if rising_edge(clk_100) then
		fc1_max <= unsigned(arm_fc1_max(11 downto 0)); -- 1023 max, 10b
		fc1_half_max <= '0' & fc1_max(fc1_max'left downto 1); -- 511 max, 10b

		fc2_max <= unsigned(arm_fc2_max(11 downto 0)); -- 1023 max, 10b
		fc2_half_max <= '0' & fc2_max(fc2_max'left downto 1); -- 511 max, 10b
		
		fc1_in_max <= unsigned(arm_fc1_in_max(11 downto 0)); -- last conv-bn-relu-maxpool = 64*64-1 = 4095 max, 12b
		
		if arm_enable_fc1_filter_reg = '1' then
			fc1_or_fc2 <= '0';
		elsif arm_enable_fc2_filter_reg = '1' then
			fc1_or_fc2 <= '1';
		end if;
		
		if fc1_or_fc2 = '0' then -- FC1
			addrb_limit <= fc1_in_max(11 downto 1); -- 2047 max, 11b		-- half of input
			fc_half_max <= fc1_half_max;									-- half of output
		else					 -- FC2
			-- addrb_limit <= '0' & fc1_half_max; -- 2047 max, 11b
			addrb_limit <= fc1_half_max(fc1_half_max'left downto 1); -- 2047 max, 11b
			fc_half_max <= fc2_half_max;
		end if;
		
		tt_fc_g_tvalid <= t_fc_g_tvalid; t_fc_g_tvalid <= s00_axis_tvalid;
		tt_fc_g_tlast <= t_fc_g_tlast; t_fc_g_tlast <= s00_axis_tlast;
		case state_g is
			when s_idle =>
				if s00_axis_tvalid = '1' and arm_enable_mm2s_tready_reg = '1' and (arm_enable_fc1_filter_reg = '1' or arm_enable_fc2_filter_reg = '1') then	-- valid mm2s data
					state_g <= s_2;
					fc_works_now <= '1';
					ch_sel <= (others=>'0');
					-- switch_fc_in_ch <= '0';
					en_fc_bram_rd_back <= '0';
					cnt_to_start_sum_fc <= (others=>'0');
				end if;
				switch_fc_in_ch <= '0';
				addrb_f_cnt <= (others=>'0'); -- pixel mem rd addr
				fc_wr_done <= '0';
			when s_2 =>
				if addrb_f_cnt < addrb_limit then -- (16/2)*12-1 then -- praeina per visus konkretaus kanalo in
					addrb_f_cnt <= addrb_f_cnt + 1; -- max 2048 adresu, o skaito poromis [x1,x0] is atminties 64*64=4096
					switch_fc_in_ch <= '0';
				else
					addrb_f_cnt <= (others=>'0');
					if fc_out_cnt < fc_half_max then -- fc1_half_max then -- praeina per visus 1/2 out
						fc_out_cnt <= fc_out_cnt + 1;
					else
						fc_out_cnt <= (others=>'0');
						switch_fc_in_ch <= '1'; -- persimeta skaiciuoti fc outus pagal sekanti iejimo kanala
					end if;
				end if;
				if t_fc_g_tlast = '1' then
					fc_wr_done <= '1';
					state_g <= s_idle;
				end if;
				if cnt_to_start_sum_fc < 15 then
					cnt_to_start_sum_fc <= cnt_to_start_sum_fc + 1;
				end if;
			when others =>
				state_g <= s_idle;
		end case;
		fc_wr_done_reg(19 downto 1) <= fc_wr_done_reg(18 downto 1) & fc_wr_done;
		-- if addrb_f_cnt = x"000b" then
		if cnt_to_start_sum_fc = x"b" then			-- x"b"
			sum_fc_enabled <= '1';					-- kada disablinti?
		elsif fc_wr_done_reg(13) = '1' then			-- dabar 13, buvo 12
			sum_fc_enabled <= '0';
			addrb_fc_b_cnt <= (others=>'0');
			fc_works_now <= '0';
			if fc1_or_fc2='0' then
				fc1_wr_results_done <= '1';
			else
				fc2_wr_results_done <= '1';
			end if;
		else
			fc1_wr_results_done <= '0';
			fc2_wr_results_done <= '0';
		end if;
		addrb_f <= std_logic_vector(addrb_f_cnt);
		addra_g <= addra_g_tmp; addra_g_tmp <= std_logic_vector(addra_g_cnt); -- delay FC1 write address for 2 cycles
		if fc2_to_ddr_enabled = '1' then
			addrb_g <= std_logic_vector(fc2_to_ddr_addrb_cnt);				-- FC1 to DDR
		else
			if fc1_or_fc2 = '0' then	-- calc FC1
				addrb_g <= std_logic_vector(addra_g_cnt(addra_g_cnt'left downto 1)); -- 2x maziau adresu FC1 out mem [16+16] bit data
			else						-- calc FC2
				addrb_g <= std_logic_vector(addrb_f_cnt(9 downto 0));
			end if;
		end if;
		addra_h <= addra_h_tmp; addra_h_tmp <= std_logic_vector(addra_g_cnt); -- delay FC2 write address for 2 cycles
		if fc2_to_ddr_enabled = '1' then -- if arm_fc2_to_ddr_reg = '1' then -- FC2 to DDR
			addrb_h <= std_logic_vector(fc2_to_ddr_addrb_cnt);
		else
			addrb_h <= std_logic_vector(addra_g_cnt(addra_g_cnt'left downto 1)); -- 2x maziau adresu FC1 out mem [16+16] bit data
		end if;
		if fc_sum_captured = '1' then
			if fc1_or_fc2='0' then
				wea_g <= "1";	-- wr to FC1
			else
				wea_h <= "1";	-- wr to FC2
			end if;
			if addra_g_cnt < fc_half_max(10 downto 0) then -- fc1_half_max(8 downto 0) then -- loop half of FC1 neurons, because dma0 1/2, and dma1 2/2
				addra_g_cnt <= addra_g_cnt + 1;
			else
				addra_g_cnt <= (others=>'0');
				en_fc_bram_rd_back <= '1';
			end if;
		else
			wea_g <= "0";
			wea_h <= "0";
		end if;
		-- switch FC1 data in channel 0...7
		switch_fc_in_ch_shift_reg(19 downto 1) <= switch_fc_in_ch_shift_reg(18 downto 1) & switch_fc_in_ch;
		if switch_fc_in_ch_shift_reg(5-3) = '1' then
			if ch_sel < "111" then
				ch_sel <= ch_sel + 1;
			else
				ch_sel <= (others=>'0');
			end if;
		end if;
		-- 4 muxes
		if ch_sel(0) = '0' then
			if fc1_or_fc2='0' then
				doutb_f_ch10 <= doutb_f_ch0; 	-- FC1
			else
				doutb_f_ch10 <= doutb_g0;		-- FC2
			end if;
		else
			if fc1_or_fc2='0' then
				doutb_f_ch10 <= doutb_f_ch1;	-- FC1
			else
				doutb_f_ch10 <= doutb_g1;		-- FC2
			end if;
		end if;
		if ch_sel(0) = '0' then
			doutb_f_ch32 <= doutb_f_ch2;
		else
			doutb_f_ch32 <= doutb_f_ch3;
		end if;
		if ch_sel(0) = '0' then
			doutb_f_ch54 <= doutb_f_ch4;
		else
			doutb_f_ch54 <= doutb_f_ch5;
		end if;
		if ch_sel(0) = '0' then
			doutb_f_ch76 <= doutb_f_ch6;
		else
			doutb_f_ch76 <= doutb_f_ch7;
		end if;
		-- 2 muxes
		ch_sel_1 <= std_logic(ch_sel(1));
		if ch_sel_1 = '0' then
			doutb_f_ch3210 <= doutb_f_ch10;
		else
			doutb_f_ch3210 <= doutb_f_ch32;
		end if;
		if ch_sel_1 = '0' then
			doutb_f_ch7654 <= doutb_f_ch54;
		else
			doutb_f_ch7654 <= doutb_f_ch76;
		end if;
		-- 1 mux
		ch_sel_2 <= std_logic(ch_sel(2));
		ch_sel_22 <= ch_sel_2;
		if ch_sel_22 = '0' then
			doutb_f_ch76543210 <= doutb_f_ch3210;
		else
			doutb_f_ch76543210 <= doutb_f_ch7654;
		end if;
		-- fc 1 in data
		fc_dma0_d0 <= doutb_f_ch76543210(15 downto 0);
		fc_dma0_d1 <= doutb_f_ch76543210(31 downto 16);
		fc_dma1_d0 <= doutb_f_ch76543210(15 downto 0);
		fc_dma1_d1 <= doutb_f_ch76543210(31 downto 16);
		-- fc 1 in weights
		t_fc_dma0_weight <= CH1_CH0_reg;
		tt_fc_dma0_weight <= t_fc_dma0_weight;
		ttt_fc_dma0_weight <= tt_fc_dma0_weight;
		tttt_fc_dma0_weight <= ttt_fc_dma0_weight;
		ttttt_fc_dma0_weight <= tttt_fc_dma0_weight;
		t_fc_dma1_weight <= CH5_CH4_reg;
		tt_fc_dma1_weight <= t_fc_dma1_weight;
		ttt_fc_dma1_weight <= tt_fc_dma1_weight;
		tttt_fc_dma1_weight <= ttt_fc_dma1_weight;
		ttttt_fc_dma1_weight <= tttt_fc_dma1_weight;
		fc_dma0_w0 <= ttttt_fc_dma0_weight(15 downto 0);
		fc_dma0_w1 <= ttttt_fc_dma0_weight(31 downto 16);
		fc_dma1_w0 <= ttttt_fc_dma1_weight(15 downto 0);
		fc_dma1_w1 <= ttttt_fc_dma1_weight(31 downto 16);
		-- w*x output
		fc_dma0 <= signed(fc_dma0_out0(31 downto 0)) + signed(fc_dma0_out1(31 downto 0));
		fc_dma1 <= signed(fc_dma1_out0(31 downto 0)) + signed(fc_dma1_out1(31 downto 0));
		-- fc_dma0 <= signed(fc_dma0_out0(32 downto 8)) + signed(fc_dma0_out1(32 downto 8));--signed(fc_dma0_out0(23 downto 8)) + signed(fc_dma0_out1(23 downto 8));
		-- fc_dma1 <= signed(fc_dma1_out0(32 downto 8)) + signed(fc_dma1_out1(32 downto 8));--signed(fc_dma1_out0(23 downto 8)) + signed(fc_dma1_out1(23 downto 8));
		-- load accumulated output of neuron
		if addra_g(0)='0' then -- mux FC1 out 32b to 16b lo or 16b hi
			if fc1_or_fc2='0' then
				prev_iter_fc_dma0 <= signed(doutb_g0(15 downto 0));
				prev_iter_fc_dma1 <= signed(doutb_g1(15 downto 0));
			else
				prev_iter_fc_dma0 <= signed(doutb_h0(15 downto 0));
				prev_iter_fc_dma1 <= signed(doutb_h1(15 downto 0));
			end if;
		else
			if fc1_or_fc2='0' then
				prev_iter_fc_dma0 <= signed(doutb_g0(31 downto 16));
				prev_iter_fc_dma1 <= signed(doutb_g1(31 downto 16));
			else
				prev_iter_fc_dma0 <= signed(doutb_h0(31 downto 16));
				prev_iter_fc_dma1 <= signed(doutb_h1(31 downto 16));
			end if;
		end if;
		-- capture acc sum, add to prev val of neuron
		if addrb_f_cnt = addrb_limit and fc_works_now = '1' then -- (16/2)*12-1 then -- synchronize with end of CH in data
			flag_fc_shift_reg(0) <= '1';
		else
			flag_fc_shift_reg(0) <= '0';
		end if;
		flag_fc_shift_reg(19 downto 1) <= flag_fc_shift_reg(18 downto 0);
		if flag_fc_shift_reg(12) = '1' then -- buvo 12, end of samples in single CH
			fc_sum_captured <= '1';
			sum_fc_dma0 <= fc_dma0;
			sum_fc_dma1 <= fc_dma1;
			if arm_enable_fc_out_read_back_reg = '1' or en_fc_bram_rd_back = '1' then -- for CH8 and higher, arm_enable_fc_out_read_back_reg='1'
				-- if arm_prec = '0' then
					-- cap_sum_fc_dma0 <= signed(sum_fc_dma0(23 downto 8)) + prev_iter_fc_dma0;	-- sum of 1st pair for next CH out in FC dma0 + previous stored value -- goes to bram
					-- cap_sum_fc_dma1 <= signed(sum_fc_dma1(23 downto 8)) + prev_iter_fc_dma1;
				if arm_prec = '0' then
					cap_sum_fc_dma0 <= signed(sum_fc_dma0(23+4 downto 8+4)) + prev_iter_fc_dma0;	-- sum of 1st pair for next CH out in FC dma0 + previous stored value -- goes to bram
					cap_sum_fc_dma1 <= signed(sum_fc_dma1(23+4 downto 8+4)) + prev_iter_fc_dma1;
				else
					cap_sum_fc_dma0 <= signed(sum_fc_dma0(15+2+8 downto 0+2+8)) + prev_iter_fc_dma0;
					cap_sum_fc_dma1 <= signed(sum_fc_dma1(15+2+8 downto 0+2+8)) + prev_iter_fc_dma1;
				end if;
			else
				-- if arm_prec = '0' then
					-- cap_sum_fc_dma0 <= signed(sum_fc_dma0(23 downto 8)) + signed(doutb_b_0);	-- add b at beginning, when CH0-CH7 data in BRAM
					-- cap_sum_fc_dma1 <= signed(sum_fc_dma1(23 downto 8)) + signed(doutb_b_1);
				if arm_prec = '0' then
					cap_sum_fc_dma0 <= signed(sum_fc_dma0(23+4 downto 8+4)) + signed(doutb_b_0);	-- add b at beginning, when CH0-CH7 data in BRAM
					cap_sum_fc_dma1 <= signed(sum_fc_dma1(23+4 downto 8+4)) + signed(doutb_b_1);
				else
					cap_sum_fc_dma0 <= signed(sum_fc_dma0(15+2+8 downto 0+2+8)) + signed(doutb_b_0);
					cap_sum_fc_dma1 <= signed(sum_fc_dma1(15+2+8 downto 0+2+8)) + signed(doutb_b_1);
				end if;
			end if;
			if addrb_fc_b_cnt < fc_half_max(8 downto 0) then		-- go through half of neurons
				addrb_fc_b_cnt <= addrb_fc_b_cnt + 1;				-- read fc b
			end if;
		else
			-- sum w*x
			if sum_fc_enabled = '1' then
				sum_fc_dma0 <= signed(sum_fc_dma0) + signed(fc_dma0); -- accumulates
				sum_fc_dma1 <= signed(sum_fc_dma1) + signed(fc_dma1); -- accumulates
			else
				sum_fc_dma0 <= (others=>'0');
				sum_fc_dma1 <= (others=>'0');
			end if;
			fc_sum_captured <= '0';
		end if;
		addrb_b <= std_logic_vector(addrb_fc_b_cnt);
		if fc1_or_fc2='0' then 			-- FC1
			doutb_b_0 <= doutb_b1_0;	-- read b1
			doutb_b_1 <= doutb_b1_1;
		else							-- FC2
			doutb_b_0 <= doutb_b2_0;	-- read b2
			doutb_b_1 <= doutb_b2_1;
		end if;
	end if;
end process;

-- dsp fc1/fc2
b_zero <= x"00000000";
fc_dsp_dma0_out0 : dsp00 PORT MAP(-- even pixel
	clk	=> clk_100,
	a 	=> fc_dma0_w0,		-- weigth from dma
	b 	=> fc_dma0_d0,		-- data from bram
	c 	=> b_zero,			-- zero
	p 	=> fc_dma0_out0		-- output
);
fc_dsp_dma0_out1 : dsp00 PORT MAP(-- odd pixel
	clk	=> clk_100,
	a 	=> fc_dma0_w1,		-- weigth from dma
	b 	=> fc_dma0_d1,		-- data from bram
	c 	=> b_zero,			-- zero
	p 	=> fc_dma0_out1		-- output
);
fc_dsp_dma1_out0 : dsp00 PORT MAP(-- even pixel
	clk	=> clk_100,
	a 	=> fc_dma1_w0,		-- weigth from dma
	b 	=> fc_dma1_d0,		-- data from bram
	c 	=> b_zero,			-- zero
	p 	=> fc_dma1_out0		-- output
);
fc_dsp_dma1_out1 : dsp00 PORT MAP(-- odd pixel
	clk	=> clk_100,
	a 	=> fc_dma1_w1,		-- weigth from dma
	b 	=> fc_dma1_d1,		-- data from bram
	c 	=> b_zero,			-- zero
	p 	=> fc_dma1_out1		-- output
);


			
process(clk_100) -- fc2 to ddr
begin
	if rising_edge(clk_100) then
		L_arm_fc2_to_ddr_reg <= arm_fc2_to_ddr_reg;
		if fc1_or_fc2 = '1' then				-- stream FC2 to DDR
			m00_axis_tdata_fc2 <= doutb_h0;
			m01_axis_tdata_fc2 <= doutb_h1;
		else									-- stream FC1 to DDR
			m00_axis_tdata_fc2 <= doutb_g0;
			m01_axis_tdata_fc2 <= doutb_g1;
		end if;
		shift_reg_fc2_valid(7 downto 0) <= shift_reg_fc2_valid(6 downto 0) & t_fc2_valid;
		shift_reg_fc2_last(7 downto 0) <= shift_reg_fc2_last(6 downto 0) & t_fc2_last;
		fc2_valid <= shift_reg_fc2_valid(1);
		fc2_last <= shift_reg_fc2_last(1);
		case state_fc2_to_ddr is
			when s_idle =>
				if L_arm_fc2_to_ddr_reg = '0' and arm_fc2_to_ddr_reg = '1' then
					fc2_to_ddr_enabled <= '1';
					state_fc2_to_ddr <= s_stream_fc2;
				end if;
				if fc2_last = '1' then
					fc2_to_ddr_enabled <= '0';
				end if;
				fc2_to_ddr_addrb_cnt <= (others=>'0');
				t_fc2_valid <= '0';
				t_fc2_last <= '0';
			when s_stream_fc2 =>
				t_fc2_valid <= '1';
				if fc2_to_ddr_addrb_cnt < '0' & fc2_half_max(fc2_half_max'left downto 1) then -- count through 32/2/2 = 8a; max 256a 32b of fc2 mem
					fc2_to_ddr_addrb_cnt <= fc2_to_ddr_addrb_cnt + 1;
				else
					fc2_to_ddr_addrb_cnt <= (others=>'0');
					state_fc2_to_ddr <= s_idle;
					t_fc2_last <= '1';
				end if;
			when others =>
				state_fc2_to_ddr <= s_idle;
		end case;
	end if;
end process;

process(clk_100) -- dma 0 -> bram weights for conv
begin
	if rising_edge(clk_100) then
		t_arm_update_weights <= arm_update_weights;
		t_s00_axis_tdata <= s00_axis_tdata;
		tt_s00_axis_tvalid <= t_s00_axis_tvalid; t_s00_axis_tvalid <= s00_axis_tvalid;
		case state_w is
			when s_idle =>
				if t_arm_update_weights = '0' and arm_update_weights = '1' then
					state_w <= s_dma_wr;
				end if;
				addra_w_cnt <= (others=>'0');
				weights_wr_done <= '0';
				wea_w <= "0";
			when s_dma_wr =>
				if t_s00_axis_tvalid = '1' then -- dma data comming
					wea_w <= "1";
					dina_w <= t_s00_axis_tdata;
					addra_w_cnt <= addra_w_cnt + 1;
					addra_w <= std_logic_vector(addra_w_cnt); -- wr addr
				elsif tt_s00_axis_tvalid = '1' and t_s00_axis_tvalid = '0' then
					state_w <= s_idle;
					weights_wr_done <= '1';
					wea_w <= "0";
				else
					wea_w <= "0";
				end if;
			when others =>
				state_w <= s_idle;
		end case;
	end if;
end process;

-- assign conv B ka be weights
net_weights : blk_mem_gen_1 PORT MAP(
	clka	=> clk_100,
	wea		=> wea_w,
	addra	=> addra_w,
	dina	=> dina_w,
	clkb	=> clk_100,
	addrb	=> addrb_w,
	doutb	=> doutb_w
);

process(clk_100) -- bram -> filter weights
begin
	if rising_edge(clk_100) then
		t_weights_wr_done <= weights_wr_done;
		t_arm_update_conv_core_config <= arm_update_conv_core_config;
		-- addrb_w_shift <= (others=>'0'); -- 512 addr, shift by 64 positions for next conv core config.
		conv_core_config_4b <= unsigned(arm_select_conv_core_config(3 downto 0));
		addrb_w_shift <= conv_core_config_4b & "00000";
		case state_wa is
			when s_idle =>
				if (t_weights_wr_done = '0' and weights_wr_done = '1') or (t_arm_update_conv_core_config = '0' and arm_update_conv_core_config = '1') then
					state_wa <= s_incr_addr;
				end if;
				addrb_w_cnt <= (others=>'0');
				addrb_w <= (others=>'0');
				weights_assign_done <= '0';
				filter_idx <= 0;
				cnt_w <= (others=>'0');
			when s_incr_addr =>
				addrb_w_cnt <= addrb_w_cnt + 1;
				addrb_w <= std_logic_vector(addrb_w_cnt + addrb_w_shift);
				filter_idx <= to_integer(unsigned(addrb_w_cnt(4 downto 2)));
				cnt_w <= (others=>'0');
				weight_type <= addrb_w_cnt(1 downto 0);
				state_wa <= s_assign_weights;
			when s_assign_weights =>
				if cnt_w < 2 then
					cnt_w <= cnt_w + 1;
				else
					cnt_w <= (others=>'0');
					if weight_type = "00" then 		-- read B
						B_all_in(filter_idx) <= doutb_w(8+7*16 downto 7*16) & -- 9 b * 8 subfilters
												doutb_w(8+6*16 downto 6*16) &
												doutb_w(8+5*16 downto 5*16) &
												doutb_w(8+4*16 downto 4*16) &
												doutb_w(8+3*16 downto 3*16) &
												doutb_w(8+2*16 downto 2*16) &
												doutb_w(8+1*16 downto 1*16) &
												doutb_w(8+0*16 downto 0*16);
					elsif weight_type = "01" then 	-- read ka
						ka_all_in(filter_idx)<= doutb_w(15+7*16 downto 7*16) & -- 16 b * 8 subfilters
												doutb_w(15+6*16 downto 6*16) &
												doutb_w(15+5*16 downto 5*16) &
												doutb_w(15+4*16 downto 4*16) &
												doutb_w(15+3*16 downto 3*16) &
												doutb_w(15+2*16 downto 2*16) &
												doutb_w(15+1*16 downto 1*16) &
												doutb_w(15+0*16 downto 0*16);
					elsif weight_type = "10" then 	-- read be
						be_all_in(filter_idx) <=doutb_w(15 downto 0);			-- 16 b * 8 subfilters
					end if;
					if addrb_w_cnt(4 downto 0)="11111" then 		-- done
						weights_assign_done <= '1';
						state_wa <= s_idle;
					else
						state_wa <= s_incr_addr; 	-- increase index of next filter
					end if;
				end if;
			when others =>
				state_wa <= s_idle;
		end case;
	end if;
end process;
-- 8 x 8 in 1 filters
-- B_all_in <= B7_in & B6_in & B5_in & B4_in & B3_in & B2_in & B1_in & B0_in;
-- ka_all_in <= ka7_in & ka6_in & ka5_in & ka4_in & ka3_in & ka2_in & ka1_in & ka0_in;
GEN_filter: for i in 0 to NF-1 generate
	-- B_all_in(i) <= B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0) & B_in(8 downto 0);
	-- ka_all_in(i) <= ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0) & ka_in(15 downto 0);
	-- be_all_in(i) <= be_in(15 downto 0);
	REGX : filter_block_8in_1out port map(
		clk_100		=> clk_100,
		arm_prec	=> arm_prec,
		arm_needs_xn=> arm_xn_or_relu_or_pool_reg(1),
		arm_merge_xn=> arm_merge_xn_reg,--arm_merge_xn_wider,
		even_tick 	=> even_tick,
		B_all_in  	=> B_all_in(i),
		ka_all_in 	=> ka_all_in(i),
		be_in 		=> be_all_in(i),
		x33			=> x33,
		x32			=> x32,
		x31			=> x31,
		x23			=> x23,
		x22			=> x22,
		x21			=> x21,
		x13			=> x13,
		x12			=> x12,
		x11			=> x11,
		--
		m0			=> m0((16-1)+16*i downto 16*i),
		m1			=> m1((16-1)+16*i downto 16*i),
		m2			=> m2((16-1)+16*i downto 16*i),
		m3			=> m3((16-1)+16*i downto 16*i),
		--
		xn_o		=> xn(i),
		dsp_xn_o	=> dsp_xn(i),
		xn_relu_o	=> xn_relu(i),
		max_pool_o	=> max_pool(i)
	);
end generate GEN_filter;

-- 3x3 conv and 2x2 max pool windows
process(clk_100)
begin
    if rising_edge(clk_100) then
		if even_tick = '0' then -- if even_tick = btnu_reg then
		-- if s00_axis_tvalid = '1' then		
			-- trimmed border/corner pixels on y=0, x=0, y=383/511, x=511
			if y_is_min = '1' or x_is_min = '1' then 	-- if y=0 or x=0
				x11 <= (others=>'0');
			else
				x11 <= c8;
			end if;
			if y_is_min = '1' then 						-- if y=0
				x12 <= (others=>'0');
			else
				x12 <= c7;
			end if;
			if y_is_min = '1' or x_is_max = '1' then 	-- if y=0 or x=511
				x13 <= (others=>'0');
			else
				x13 <= c6;
			end if;
			if x_is_min = '1' then 						-- if x=0
				x21 <= (others=>'0');
			else
				x21 <= c5;
			end if;
			x22 <= c4;
			if x_is_max = '1' then 						-- if x=511
				x23 <= (others=>'0');
			else
				x23 <= c3;
			end if;
			if y_is_max = '1' or x_is_min = '1' then 	-- if y=511 or x=0
				x31 <= (others=>'0');
			else
				x31 <= c2;
			end if;
			if y_is_max = '1' then 						-- if y=511
				x32 <= (others=>'0');
			else
				x32 <= c1;
			end if;
			if y_is_max = '1' or x_is_max = '1' then 	-- if y=511 or x=511
				x33 <= (others=>'0');
			else
				x33 <= c0;
			end if;
			-- conv
			reg0 <= CH7_CH6_reg & CH5_CH4_reg & CH3_CH2_reg & CH1_CH0_reg;--din;--
			reg1 <= reg0;
			reg2 <= reg1;
			c0 <= reg2;
			c1 <= c0;
			c2 <= c1;
			--
			reg3 <= doutb00_CH76543210;--doutb00_CH2_CH1;
			reg4 <= reg3;
			c3 <= reg4;
			c4 <= c3;
			c5 <= c4;
			--
			reg5 <= doutb01_CH76543210;--doutb01_CH2_CH1;
			reg6 <= reg5;
			c6 <= reg6;
			c7 <= c6;
			c8 <= c7;
			-- max pool
			reg7 <= xn_relu(7) & xn_relu(6) & xn_relu(5) & xn_relu(4) & xn_relu(3) & xn_relu(2) & xn_relu(1) & xn_relu(0);
			reg8 <= reg7;
			reg9 <= reg8;
			m0 <= reg9;
			m1 <= m0;
			--
			reg10 <= doutb_xn_relu;
			reg11 <= reg10;
			m2 <= reg11;
			m3 <= m2;
		end if;
    end if;
end process;
-- shift reg 32b
process(clk_100)
begin
    if rising_edge(clk_100) then
		CH1_CH0_reg <= CH3_CH2_reg;
		CH3_CH2_reg <= s00_axis_tdata;
		CH5_CH4_reg <= CH7_CH6_reg;
		CH7_CH6_reg <= s01_axis_tdata;
    end if;
end process;
-- conv two brams 128b, CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0
fifo_conv0 : blk_mem_gen_0 PORT MAP(
	clka	=> clk_100,
	wea		=> wea00,
	addra	=> addra00,
	dina	=> dina_CH76543210,
	clkb	=> clk_100,
	addrb	=> addrb00,
	doutb	=> doutb00_CH76543210
);
fifo_conv1 : blk_mem_gen_0 PORT MAP(
	clka	=> clk_100,
	wea		=> wea00,
	addra	=> addra00,
	dina	=> doutb00_CH76543210,
	clkb	=> clk_100,
	addrb	=> addrb00,
	doutb	=> doutb01_CH76543210
);
-- max pool one bram CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0
fifo_max_pool : blk_mem_gen_0 PORT MAP(
	clka	=> clk_100,
	wea		=> wea00,
	addra	=> addra00,
	dina	=> dina_xn_relu,
	clkb	=> clk_100,
	addrb	=> addrb00,
	doutb	=> doutb_xn_relu
);
-- bram address and data
process(clk_100)
begin
    if rising_edge(clk_100) then
		if even_tick = '0' then
			-- conv
			wea00 <= "1";
			dina_CH76543210 <= CH7_CH6_reg & CH5_CH4_reg & CH3_CH2_reg & CH1_CH0_reg;
			cnt00 <= cnt00 + 1;
			addra00 <= std_logic_vector(cnt00);							-- wr addr
			rd_shift <= "1000000000" - ('0' & x_max(9 downto 1));		-- 512-511 | 512-255 | 512-127 | 512-127
			addrb00 <= std_logic_vector(cnt00+rd_shift(8 downto 0));	-- rd addr, std_logic_vector(cnt00+1)
			-- max pool
			dina_xn_relu <= xn_relu(7) & xn_relu(6) & xn_relu(5) & xn_relu(4) & xn_relu(3) & xn_relu(2) & xn_relu(1) & xn_relu(0);
		end if;
    end if;
end process;
-- test bram signals
wea00_o <= '1' when wea00="1" else '0';
addra00_o <= addra00;
addrb00_o <= addrb00;
dina00dma0_o <= dina_CH1_CH0(15 downto  0);
dina00dma1_o <= dina_CH1_CH0(31 downto 16);
doutb00dma0_o <= doutb00_CH1_CH0(31 downto 16);
doutb00dma1_o <= doutb01_CH1_CH0(31 downto 16);
-- capture arm_enable_mm2s_tready
process(clk_100) -- synchronize mm2s with 100MHz clk domain
begin
    if rising_edge(clk_100) then
		-- arm enable mm2s tready
		tmp_reg0 <= arm_enable_mm2s_tready;
		tmp_reg1 <= tmp_reg0;
		arm_enable_mm2s_tready_reg <= tmp_reg1;
		-- arm enable conv filter
		arm_enable_filter_reg <= arm_enable_filter;
		-- capture btnu
		tmp_reg2 <= btnu;
		btnu_reg <= tmp_reg2;
		-- xn or relu or pool transfer
		arm_xn_or_relu_or_pool_reg <= arm_xn_or_relu_or_pool;
		-- dma0 xn + dma1 xn to fpga, then merged xn, relu, pool to ddr
		arm_merge_xn_reg <= arm_merge_xn;
		-- fc2 transfer
		arm_fc2_to_ddr_reg <= arm_fc2_to_ddr;
		-- arm update fc 1 b
		arm_update_fc1_b_reg <= arm_update_fc1_b;
		-- arm update fc 2 b
		arm_update_fc2_b_reg <= arm_update_fc2_b;
		-- arm update fc 1 input data
		arm_update_fc1_data_reg <= arm_update_fc1_data;
		-- arm enable fc 1 filter
		arm_enable_fc1_filter_reg <= arm_enable_fc1_filter;
		-- arm enable fc 2 filter
		arm_enable_fc2_filter_reg <= arm_enable_fc2_filter;
		-- arm enable fc memory read back to accumumate neurons inputs
		arm_enable_fc_out_read_back_reg <= arm_enable_fc_out_read_back;
    end if;
end process;
-- mux dma signals
s00_axis_tready <= arm_enable_mm2s_tready_reg; -- veliau palikti visada ijungta '1'
s01_axis_tready <= arm_enable_mm2s_tready_reg;
process(clk_100)
begin
	if rising_edge(clk_100) then
		if arm_xn_or_relu_or_pool_reg(0)='0' or arm_xn_or_relu_or_pool_reg(1)='1' then 	-- relu data or xn data
			L_m00_axis_tvalid <= m00_valid;
			L_m00_axis_tlast <= m00_last;
			L_m01_axis_tvalid <= m00_valid;
			L_m01_axis_tlast <= m00_last;
			L_m00_axis_tdata <= m00_axis_tdata_relu;
			L_m01_axis_tdata <= m01_axis_tdata_relu;
		else										-- pool data
			L_m00_axis_tvalid <= max_pool_valid_to_dma;
			L_m00_axis_tlast <= max_pool_last_to_dma;
			L_m01_axis_tvalid <= max_pool_valid_to_dma;
			L_m01_axis_tlast <= max_pool_last_to_dma;
			L_m00_axis_tdata <= m00_axis_tdata_pool;
			L_m01_axis_tdata <= m01_axis_tdata_pool;
		end if;
		if fc2_to_ddr_enabled='1' then -- if arm_fc2_to_ddr = '1' then		-- fc2 data
			m00_axis_tvalid <= fc2_valid;
			m00_axis_tlast <= fc2_last;
			m01_axis_tvalid <= fc2_valid;
			m01_axis_tlast <= fc2_last;
			m00_axis_tdata <= m00_axis_tdata_fc2;
			m01_axis_tdata <= m01_axis_tdata_fc2;
			-- test sync
			m00_axis_tvalid_t <= fc2_valid;
			m01_axis_tvalid_t <= fc2_valid;
		else
			m00_axis_tvalid <= L_m00_axis_tvalid;
			m00_axis_tlast <= L_m00_axis_tlast;
			if arm_merge_xn_reg = '1' then -- if sum then m01 idle
				m01_axis_tvalid <= '0';		
				m01_axis_tlast <= '0';
			else
				m01_axis_tvalid <= L_m01_axis_tvalid;
				m01_axis_tlast <= L_m01_axis_tlast;
			end if;
			m00_axis_tdata <= L_m00_axis_tdata;
			m01_axis_tdata <= L_m01_axis_tdata;
			-- test sync
			m00_axis_tvalid_t <= L_m00_axis_tvalid;
			if arm_merge_xn_reg = '1' then -- if sum then m01 idle
				m01_axis_tvalid_t <= '0';
			else
				m01_axis_tvalid_t <= L_m01_axis_tvalid;
			end if;
		end if;
	end if;
end process;
-- main fsm, valid/last for conv,
process(clk_100)
begin 
	if rising_edge(clk_100) then
		x_max <= unsigned(arm_x_max(8 downto 0)) & '1'; -- 2x+1 = 511*2+1=1023
		y_max <= unsigned(arm_y_max(8 downto 0)); -- 511
		cnt0_start <= unsigned(arm_delay_conv_valid0_start(19 downto 0));
		cnt0_done <= unsigned(arm_delay_conv_valid0_done(19 downto 0));
		cntd_start <= unsigned(arm_delay_border_pix_deny_start(19 downto 0));
		case state0 is
			when s_idle =>
				if s00_axis_tvalid = '1' and arm_enable_mm2s_tready_reg = '1' and arm_enable_filter_reg = '1' then	-- valid mm2s data
					state0 <= s_1;
					s00_valid_captured <= '1';
					even_tick <= '1';
				else
					even_tick <= '0';
				end if;
				cnt0 <= (others=>'0');
				m00_valid <= '0';
				m00_last <= '0';
				st0 <= "00";
			when s_1 =>
				s00_valid_captured <= '0';
				even_tick <= not even_tick;
				if s00_axis_tlast = '1' then
					state0 <= s_2;
					cnt0 <= (others=>'0');
				elsif cnt0 < cnt0_start then
					cnt0 <= cnt0 + 1;
				else
					m00_valid <= '1';			-- set m_valid
				end if;
				st0 <= "01";
			when s_2 =>
				even_tick <= not even_tick;
				if cnt0 < cnt0_done then
					cnt0 <= cnt0 + 1;
				else
					m00_valid <= '0';			-- reset m_valid
					cnt0 <= (others=>'0');
					state0 <= s_3;
				end if;
				if cnt0 = cnt0_done-1 then
					m00_last <= '1';			-- set m_last
				else
					m00_last <= '0';			-- reset tlast
				end if;
				st0 <= "10";
			when s_3 =>
				even_tick <= not even_tick;
				if cnt0 < 12 then
					cnt0 <= cnt0 + 1;
				else
					state0 <= s_idle;
				end if;
				st0 <= "11";
			when others =>
				state0 <= s_idle;
				st0 <= "00";
		end case;
		-- run resolution counter 512x512, 512x384 pix
		if state0 = s_1 or state0 = s_2 then
			if cntd < cntd_start then 
				cntd <= cntd + 1;
				x_cnt <= (others=>'0');
				y_cnt <= (others=>'0');
			else
				-- if cnt512 < 2*512*512-1 then
					-- cnt512 <= cnt512 + 1;
				-- end if;
				if x_cnt < x_max then
					x_cnt <= x_cnt + 1;
				else
					x_cnt <= (others=>'0');
					if y_cnt < y_max then
						y_cnt <= y_cnt + 1;
					else
						y_cnt <= (others=>'0');
					end if;
				end if;
			end if;
		else
			-- cnt512 <= (others=>'0');
			x_cnt <= (others=>'0');
			y_cnt <= (others=>'0');
			cntd <= (others=>'0');
		end if;
		-- y min/max flags
		-- if cnt512(17+1 downto 9+1) = "000000000" then -- +1 kad 2x leciau skaiciuotu, nes ateina @100MHz 32b, o apdorojama @50MHz 4x16b
		if y_cnt = "000000000" then
			y_is_min <= '1';
		else
			y_is_min <= '0';
		end if;
		-- if cnt512(17+1 downto 9+1) = "111111111" then
		if y_cnt = y_max then
			y_is_max <= '1';
		else
			y_is_max <= '0';
		end if;
		-- x min/max flags
		-- if cnt512(8+1 downto 0+1) = "000000000" then
		if x_cnt(9 downto 1) = "000000000" then
			x_is_min <= '1';
		else
			x_is_min <= '0';
		end if;
		-- if cnt512(8+1 downto 0+1) = "111111111" then
		if x_cnt(9 downto 1) = x_max(9 downto 1) then
			x_is_max <= '1';
		else
			x_is_max <= '0';
		end if;
		--
		if (x_cnt(1) = '1' and y_cnt(0) = '1' and even_tick = '0') then
			max_pool_valid <= '1';
		else
			max_pool_valid <= '0';
		end if;
		t_max_pool_valid <= max_pool_valid;
		-- shift pool valid
		shift_reg_max_pool_valid <= shift_reg_max_pool_valid(34 downto 0) & (max_pool_valid or t_max_pool_valid); -- 32bits
		max_pool_valid_to_dma <= shift_reg_max_pool_valid(29+6);
		-- shift pool last
		shift_reg_max_pool_last <= shift_reg_max_pool_last(11 downto 0) & m00_last; -- 32bits
		max_pool_last_to_dma <= shift_reg_max_pool_last(12);
		--
		-- L_arm_merge_xn_reg <= arm_merge_xn_reg;
		-- if L_arm_merge_xn_reg = '0' and arm_merge_xn_reg = '1' then
			-- arm_merge_xn_wider <= '1'; -- set 
		-- elsif m00_last = '1' then
			-- arm_merge_xn_wider <= '0'; -- reset
		-- end if;
	end if;
end process;
-- m00 data
process(clk_100)
begin
    if rising_edge(clk_100) then
		if m00_axis_tready = '1' then
			if x_cnt(0)='0' then--if cnt512(0)='0' then
				-- m00_axis_tdata_relu	<= xn(1) & xn(0); -- wr CH1 & CH0
				-- m00_axis_tdata_relu	<= dsp_xn(1) & dsp_xn(0); -- wr CH1 & CH0
				m00_axis_tdata_relu	<= xn_relu(1) & xn_relu(0); -- wr CH1 & CH0
				-- m00_axis_tdata	<= max_pool(1) & max_pool(0); -- wr CH1 & CH0
				-- m00_axis_tdata	<= x"0000" & std_logic_vector(SumBx);
			else
				-- m00_axis_tdata_relu	<= xn(3) & xn(2); -- wr CH3 & CH2
				-- m00_axis_tdata_relu	<= dsp_xn(3) & dsp_xn(2); -- wr CH3 & CH2
				m00_axis_tdata_relu	<= xn_relu(3) & xn_relu(2); -- wr CH3 & CH2
				-- m00_axis_tdata	<= max_pool3 & max_pool2; -- wr CH3 & CH2
				-- m00_axis_tdata	<= x"0F0F0f0f";
			end if;
			if even_tick = '1' then
				m00_axis_tdata_pool	<= max_pool(1) & max_pool(0); -- wr CH1 & CH0
			else
				m00_axis_tdata_pool	<= max_pool(3) & max_pool(2); -- wr CH3 & CH2
			end if;
		else
			m00_axis_tdata_relu	<= x"F0F0F0F0";
		end if;
		m00_axis_tstrb	<= "1111";
    end if;
end process;
-- m01 data
process(clk_100)
begin
    if rising_edge(clk_100) then
		if m01_axis_tready = '1' then
			if x_cnt(0)='0' then--if cnt512(0)='0' then
				-- m01_axis_tdata_relu	<= dsp_xn(5) & dsp_xn(4); -- wr CH5 & CH4
				m01_axis_tdata_relu	<= xn_relu(5) & xn_relu(4); -- wr CH5 & CH4
				-- m01_axis_tdata	<= max_pool(5) & max_pool(4); -- wr CH5 & CH4
				-- m01_axis_tdata	<= x"0000" & std_logic_vector(zum11);
			else
				-- m01_axis_tdata_relu	<= dsp_xn(7) & dsp_xn(6); -- wr CH7 & CH6
				m01_axis_tdata_relu	<= xn_relu(7) & xn_relu(6); -- wr CH7 & CH6
				-- m01_axis_tdata	<= max_pool(7) & max_pool(6); -- wr CH7 & CH6
				-- m01_axis_tdata	<= x"0E0E" & x"0E0E";
			end if;
			if even_tick = '1' then
				m01_axis_tdata_pool	<= max_pool(5) & max_pool(4); -- wr CH5 & CH4
			else
				m01_axis_tdata_pool	<= max_pool(7) & max_pool(6); -- wr CH7 & CH6
			end if;
		else
			m01_axis_tdata_relu	<= x"E0E0E0E0";
		end if;
		m01_axis_tstrb	<= "1111";
    end if;
end process;

-- s00 and s01 valid synchronous?
process(clk_100)
begin
    if rising_edge(clk_100) then
		if s00_valid_captured = '1' and s01_valid_captured = '1' then
			s00_s01_valid_is_synchronous <= not s00_s01_valid_is_synchronous;
			freq_cnt <= freq_cnt + 1;
		end if;
		if cnt1s < 99999999 then
			cnt1s <= cnt1s + 1;
		else
			cnt1s <= (others=>'0');
			freq <= freq_cnt;
			freq_cnt <= (others=>'0');
		end if;
		-- FPGA->DDR, m00_ready and m00_valid is continuous?
		if btnl = '1' then -- reset m00 max
			max_m00_cnt <= (others=>'0');
		else
			if m00_axis_tready = '1' and m00_axis_tvalid_t = '1' then
				m00_cnt <= m00_cnt + 1;
			else
				m00_cnt <= (others=>'0');
				if max_m00_cnt < m00_cnt then
					max_m00_cnt <= m00_cnt;
				end if;
			end if;
		end if;
		-- FPGA->DDR, m01_ready and m01_valid is continuous?
		if btnl = '1' then -- reset s01 max
			max_m01_cnt <= (others=>'0');
		else
			if m01_axis_tready = '1' and m01_axis_tvalid_t = '1' then
				m01_cnt <= m01_cnt + 1;
			else
				m01_cnt <= (others=>'0');
				if max_m01_cnt < m01_cnt then
					max_m01_cnt <= m01_cnt;
				end if;
			end if;
		end if;
		-- DDR->FPGA, arm_enable_mm2s_tready and s00_axis_tvalid is continuous?
		if btnl = '1' then -- reset s00 max
			max_s00_cnt <= (others=>'0');
		else
			if arm_enable_mm2s_tready_reg = '1' and s00_axis_tvalid = '1' then
				s00_cnt <= s00_cnt + 1;
			else
				s00_cnt <= (others=>'0');
				if max_s00_cnt < s00_cnt then
					max_s00_cnt <= s00_cnt;
				end if;
			end if;
		end if;
		-- DDR->FPGA, arm_enable_mm2s_tready and s01_axis_tvalid is continuous?
		if btnl = '1' then -- reset s01 max
			max_s01_cnt <= (others=>'0');
		else
			if arm_enable_mm2s_tready_reg = '1' and s01_axis_tvalid = '1' then
				s01_cnt <= s01_cnt + 1;
			else
				s01_cnt <= (others=>'0');
				if max_s01_cnt < s01_cnt then
					max_s01_cnt <= s01_cnt;
				end if;
			end if;
		end if;
    end if;
end process;

end arch_imp;
