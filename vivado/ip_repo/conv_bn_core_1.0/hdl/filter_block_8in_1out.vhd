library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity filter_block_8in_1out is
    Port ( 	clk_100 	: in STD_LOGIC;
			arm_prec	: in STD_LOGIC;
			arm_needs_xn: in STD_LOGIC;
			arm_merge_xn: in STD_LOGIC;
			even_tick 	: in STD_LOGIC;
			B_all_in  	: in STD_LOGIC_VECTOR(9*8-1 DOWNTO 0);
			ka_all_in 	: in STD_LOGIC_VECTOR(16*8-1 DOWNTO 0);
			be_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
			x33, x32, x31, x23, x22, x21, x13, x12, x11 : in STD_LOGIC_VECTOR(16*8-1 DOWNTO 0);
			m3, m2, m1, m0 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			--
			xn_o : out STD_LOGIC_VECTOR(15 DOWNTO 0);
			dsp_xn_o : out STD_LOGIC_VECTOR(19 DOWNTO 0);
			xn_relu_o : out STD_LOGIC_VECTOR(15 DOWNTO 0);
			max_pool_o : out STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
end filter_block_8in_1out;

architecture Behavioral of filter_block_8in_1out is
	-- dsp macro
	component dsp00 IS PORT (
		CLK : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		P : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
	);
	END component dsp00;
	type B_type is array (0 to 7) of STD_LOGIC_VECTOR(8 downto 0);
	signal B : B_type:=(others=>(others=>'0'));
	type ka_type is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
    signal ka : ka_type:=(others=>(others=>'0'));
    signal be : STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
	type Bx_type is array (0 to 7, 0 to 8) of signed(15 downto 0);
	signal Bx : Bx_type;
	type sum_type is array (0 to 7) of SIGNED(15 DOWNTO 0);
	signal sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8,sum9,sum10,SumBx, L_Bx4,LL_Bx4,LLL_Bx4 : sum_type:=(others=>(others=>'0'));
	type ka_SumBx_type is array (0 to 7) of SIGNED(31 DOWNTO 0);
	signal ka_SumBx : ka_SumBx_type:=(others=>(others=>'0'));
	signal ka_SumBx0, ka_SumBx1, ka_SumBx2, ka_SumBx3, ka_SumBx01, ka_SumBx23, ka_SumBx0123, dsp_xn0123_t : SIGNED(15 downto 0):=(others=>'0');
	signal dsp_xn0, dsp_xn1, dsp_xn2, dsp_xn3, dsp_xn01, dsp_xn23, dsp_xn0123 : SIGNED(19+8 downto 0):=(others=>'0');
	signal xn, xn_relu, max_pool, pool01, pool23 : SIGNED(15 downto 0):=(others=>'0');
	signal ben : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	type dsp_xn_type is array (0 to 7) of STD_LOGIC_VECTOR(32 DOWNTO 0);
	signal dsp_xn : dsp_xn_type:=(others=>(others=>'0'));
	constant be0 : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	type pool_type is array (0 to 3) of signed(15 downto 0);
	signal pool : pool_type:=(others=>(others=>'0'));
begin
-- port map
xn_o <= STD_LOGIC_VECTOR(xn);
-- dsp_xn_o <= STD_LOGIC_VECTOR(dsp_xn0123(15 downto 0));--dsp_xn(7)(23 downto 8) & dsp_xn(6)(23 downto 8) & dsp_xn(5)(23 downto 8) & dsp_xn(4)(23 downto 8) & dsp_xn(3)(23 downto 8) & dsp_xn(2)(23 downto 8) & dsp_xn(1)(23 downto 8) & dsp_xn(0)(23 downto 8);
dsp_xn_o <= STD_LOGIC_VECTOR(dsp_xn0123(19+8 downto 0+8));
xn_relu_o <= STD_LOGIC_VECTOR(xn_relu);
max_pool_o <= STD_LOGIC_VECTOR(max_pool);

process(clk_100)
begin
    if rising_edge(clk_100) then
		-- if arm_prec='0' then	-- 8.8b
			-- if be(15)='0' then
				-- ben <= x"00" & be & x"00";	-- pos b
			-- else
				-- ben <= x"FF" & be & x"00";	-- neg b
			-- end if;
		if arm_prec='0' then	-- 4.12b
			if be(15)='0' then
				ben <= x"0" & be & x"000";	-- pos b
			else
				ben <= x"F" & be & x"000";	-- neg b
			end if;
		else					-- 6.10b
			if be(15)='0' then
				ben <= x"0" & "00" & be & "00" & x"00";	-- pos b
			else
				ben <= x"F" & "11" & be & "00" & x"00";	-- neg b
			end if;
		end if;
	end if;
end process;

-- dsp_inst_0 : dsp00 PORT MAP(
	-- clk	=> clk_100,
	-- a 	=> STD_LOGIC_VECTOR(SumBx(i)),					-- bin conv
	-- b 	=> ka(i),										-- A*gamma/(sqrt(sigma^2+epsilon))
	-- c 	=> be0,											-- beta-mu*gamma/(sqrt(sigma^2+epsilon))
	-- p 	=> dsp_xn(i)									-- output
-- );
-- dsp, cia ideti generate 8 times
	U0: dsp00 port map(
		clk	=> clk_100,
		a 	=> STD_LOGIC_VECTOR(SumBx(0)),
		b 	=> ka(0),
		c 	=> ben,
		p 	=> dsp_xn(0)
	);
GEN_DSP: for i in 1 to 7 generate
	-- with_be: if i=0 generate
	-- U0: dsp00 port map(
		-- clk	=> clk_100,
		-- a 	=> STD_LOGIC_VECTOR(SumBx(i)),
		-- b 	=> ka(i),
		-- c 	=> ben,
		-- p 	=> dsp_xn(i)
	-- );
	-- end generate with_be;

	-- no_be: if i>0 generate
	UX: dsp00 port map(
		clk	=> clk_100,
		a 	=> STD_LOGIC_VECTOR(SumBx(i)),
		b 	=> ka(i),
		c 	=> be0,
		p 	=> dsp_xn(i)
	);
	-- end generate no_be;
end generate GEN_DSP;
  
-- conv 3x3
-- B <= "000000000";
-- ka <= "00000001" & "10000000";
-- be <= "00000001" & "10000000";
process(clk_100)
begin
    if rising_edge(clk_100) then
		for i in 0 to 7 loop
			B(i) <= B_all_in((9-1)+9*i downto 9*i);
			ka(i) <= ka_all_in((16-1)+16*i downto 16*i);
		end loop;
		be <= be_in;
		if even_tick = '0' then -- if even_tick = btnu_reg then
			-- z8
			for i in 0 to 7 loop	-- B(filter)(cell)
				if B(i)(8)='0' then Bx(i,8) <= signed(x11((16-1)+16*i downto 16*i)); else Bx(i,8) <= signed(unsigned(not(x11((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(7)='0' then Bx(i,7) <= signed(x12((16-1)+16*i downto 16*i)); else Bx(i,7) <= signed(unsigned(not(x12((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(6)='0' then Bx(i,6) <= signed(x13((16-1)+16*i downto 16*i)); else Bx(i,6) <= signed(unsigned(not(x13((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(5)='0' then Bx(i,5) <= signed(x21((16-1)+16*i downto 16*i)); else Bx(i,5) <= signed(unsigned(not(x21((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(4)='0' then Bx(i,4) <= signed(x22((16-1)+16*i downto 16*i)); else Bx(i,4) <= signed(unsigned(not(x22((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(3)='0' then Bx(i,3) <= signed(x23((16-1)+16*i downto 16*i)); else Bx(i,3) <= signed(unsigned(not(x23((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(2)='0' then Bx(i,2) <= signed(x31((16-1)+16*i downto 16*i)); else Bx(i,2) <= signed(unsigned(not(x31((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(1)='0' then Bx(i,1) <= signed(x32((16-1)+16*i downto 16*i)); else Bx(i,1) <= signed(unsigned(not(x32((16-1)+16*i downto 16*i)))+1); end if;
				if B(i)(0)='0' then Bx(i,0) <= signed(x33((16-1)+16*i downto 16*i)); else Bx(i,0) <= signed(unsigned(not(x33((16-1)+16*i downto 16*i)))+1); end if;
				-- z9
				sum1(i) <= Bx(i,8) + Bx(i,7); sum2(i) <= Bx(i,6) + Bx(i,5); sum3(i) <= Bx(i,4) + Bx(i,3); sum4(i) <= Bx(i,2) + Bx(i,1); sum5(i) <= Bx(i,0); L_Bx4(i) <= Bx(i,4);
				-- +10
				sum6(i) <= sum1(i) + sum2(i); sum7(i) <= sum3(i) + sum4(i); sum8(i) <= sum5(i); LL_Bx4(i) <= L_Bx4(i);
				-- +11
				sum9(i) <= sum6(i) + sum7(i); sum10(i) <= sum8(i); LLL_Bx4(i) <= LL_Bx4(i);
				-- +12
				if arm_merge_xn = '1' then
					SumBx(i) <= LLL_Bx4(i);
				else
					SumBx(i) <= sum9(i) + sum10(i);
				end if;
				-- BN
				-- 1+12
				ka_SumBx(i) <= signed(ka(i)) * SumBx(i); -- 8x
			end loop;
			-- ----------------------------------------------------------
			-- start extra delay since 2019-09-01, +3 not inserted in SDK!!!
			-- +1
			ka_SumBx0 <= ka_SumBx(0)(23 downto 8) + ka_SumBx(1)(23 downto 8);
			ka_SumBx1 <= ka_SumBx(2)(23 downto 8) + ka_SumBx(3)(23 downto 8);
			ka_SumBx2 <= ka_SumBx(4)(23 downto 8) + ka_SumBx(5)(23 downto 8);
			ka_SumBx3 <= ka_SumBx(6)(23 downto 8) + ka_SumBx(7)(23 downto 8);
			--
			-- if arm_prec='0' then
				-- dsp_xn0 <= SIGNED(dsp_xn(0)(23+4 downto 8-8)) + SIGNED(dsp_xn(1)(23+4 downto 8-8));
				-- dsp_xn1 <= SIGNED(dsp_xn(2)(23+4 downto 8-8)) + SIGNED(dsp_xn(3)(23+4 downto 8-8));
				-- dsp_xn2 <= SIGNED(dsp_xn(4)(23+4 downto 8-8)) + SIGNED(dsp_xn(5)(23+4 downto 8-8));
				-- dsp_xn3 <= SIGNED(dsp_xn(6)(23+4 downto 8-8)) + SIGNED(dsp_xn(7)(23+4 downto 8-8));
			if arm_prec='0' then
				dsp_xn0 <= SIGNED(dsp_xn(0)(23+4+4 downto 8-8+4)) + SIGNED(dsp_xn(1)(23+4+4 downto 8-8+4));
				dsp_xn1 <= SIGNED(dsp_xn(2)(23+4+4 downto 8-8+4)) + SIGNED(dsp_xn(3)(23+4+4 downto 8-8+4));
				dsp_xn2 <= SIGNED(dsp_xn(4)(23+4+4 downto 8-8+4)) + SIGNED(dsp_xn(5)(23+4+4 downto 8-8+4));
				dsp_xn3 <= SIGNED(dsp_xn(6)(23+4+4 downto 8-8+4)) + SIGNED(dsp_xn(7)(23+4+4 downto 8-8+4));
			else
				dsp_xn0 <= SIGNED(dsp_xn(0)(23+4+2 downto 8-8+2)) + SIGNED(dsp_xn(1)(23+4+2 downto 8-8+2));
				dsp_xn1 <= SIGNED(dsp_xn(2)(23+4+2 downto 8-8+2)) + SIGNED(dsp_xn(3)(23+4+2 downto 8-8+2));
				dsp_xn2 <= SIGNED(dsp_xn(4)(23+4+2 downto 8-8+2)) + SIGNED(dsp_xn(5)(23+4+2 downto 8-8+2));
				dsp_xn3 <= SIGNED(dsp_xn(6)(23+4+2 downto 8-8+2)) + SIGNED(dsp_xn(7)(23+4+2 downto 8-8+2));
			end if;
			-- +2
			ka_SumBx01 <= ka_SumBx0 + ka_SumBx1;
			ka_SumBx23 <= ka_SumBx2 + ka_SumBx3;
			--
			dsp_xn01 <= dsp_xn0 + dsp_xn1;
			dsp_xn23 <= dsp_xn2 + dsp_xn3;
			-- +3
			ka_SumBx0123 <= ka_SumBx01 + ka_SumBx23;
			--
			dsp_xn0123 <= dsp_xn01 + dsp_xn23;
			-- end extra delay, add +3 cycles!!!
			-- ----------------------------------------------------------
			-- 2+12
			xn <= ka_SumBx0123 + signed(be);
			-- xn <= ka_SumBx(7)(23 downto 8);
			-- ReLU
			-- 3+12
			-- saturation control + relu start
			if dsp_xn0123(19+8 downto 15+8)=0 then -- positive, no overflow
				xn_relu <= dsp_xn0123(15+8 downto 0+8);
			elsif dsp_xn0123(19+8)='0' and unsigned(dsp_xn0123(18+8 downto 15+8))>"0000" then -- positive, with overflow
				xn_relu <= x"7FFF";
			elsif dsp_xn0123(19+8 downto 15+8)="11111" and arm_needs_xn='1' then -- negative, no overflow
				xn_relu <= dsp_xn0123(15+8 downto 0+8);
			elsif dsp_xn0123(19+8)='1' and unsigned(dsp_xn0123(18+8 downto 15+8))<"1111" and arm_needs_xn='1' then -- negative, with overflow
				xn_relu <= x"8000";
			else
				xn_relu <= (OTHERS=>'0');
			end if;
			-- saturation control end
			-- if dsp_xn0123(15)='0' or arm_needs_xn='1' then -- dsp_xn goes to DDR through xn_relu
				-- xn_relu <= dsp_xn0123; -- iki 2020-02-04
			-- else
				-- xn_relu <= (OTHERS=>'0');
			-- end if;
			-- Max Pooling
			pool(0) <= signed(m0);
			pool(1) <= signed(m1);
			pool(2) <= signed(m2);
			pool(3) <= signed(m3);
			--
			if pool(0) >= pool(1) then pool01 <= pool(0); else pool01 <= pool(1); end if;
			if pool(2) >= pool(3) then pool23 <= pool(2); else pool23 <= pool(3); end if;
			--
			if pool01 >= pool23 then max_pool <= pool01; else max_pool <= pool23; end if;
		end if;
    end if;
end process;

end Behavioral;
