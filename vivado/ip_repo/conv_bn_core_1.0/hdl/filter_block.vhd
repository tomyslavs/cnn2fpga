library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity filter_block is
    Port ( 	clk_100 	: in STD_LOGIC;
			even_tick 	: in STD_LOGIC;
			B_in  		: in STD_LOGIC_VECTOR(8 DOWNTO 0);
			ka_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
			be_in 		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
			x33, x32, x31, x23, x22, x21, x13, x12, x11 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			m3, m2, m1, m0 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			xn_o : out STD_LOGIC_VECTOR(15 DOWNTO 0);
			dsp_xn_o : out STD_LOGIC_VECTOR(15 DOWNTO 0);
			xn_relu_o : out STD_LOGIC_VECTOR(15 DOWNTO 0);
			max_pool_o : out STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
end filter_block;

architecture Behavioral of filter_block is
	-- dsp macro
	component dsp00 IS PORT (
		CLK : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		P : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
	);
	END component dsp00;
	signal B : STD_LOGIC_VECTOR( 8 downto 0):=(OTHERS=>'0');
    signal ka : STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
    signal be : STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
	type Bx_type is array (8 downto 0) of signed(15 downto 0);
	signal Bx : Bx_type:=(others=>(others=>'0'));
	signal SumBx : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
	signal ka_SumBx : SIGNED(31 downto 0):=(others=>'0');
	signal xn, xn_relu, max_pool, pool01, pool23 : SIGNED(15 downto 0):=(others=>'0');
	signal ben : STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
	signal dsp_xn : STD_LOGIC_VECTOR(32 downto 0):=(others=>'0');
	signal sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8,sum9,sum10 : SIGNED(15 DOWNTO 0):=(OTHERS=>'0');
	type pool_type is array (0 to 3) of signed(15 downto 0);
	signal pool : pool_type:=(others=>(others=>'0'));
begin
-- port map
xn_o <= STD_LOGIC_VECTOR(xn);
dsp_xn_o <= dsp_xn(23 downto 8);
xn_relu_o <= STD_LOGIC_VECTOR(xn_relu);
max_pool_o <= STD_LOGIC_VECTOR(max_pool);
-- dsp
ben <= x"00" & be & x"00";
dsp_inst : dsp00 PORT MAP(
	clk	=> clk_100,
	a 	=> STD_LOGIC_VECTOR(SumBx),						-- bin conv
	b 	=> ka,											-- A*gamma/(sqrt(sigma^2+epsilon))
	c 	=> ben,											-- beta-mu*gamma/(sqrt(sigma^2+epsilon))
	p 	=> dsp_xn										-- output
);
-- conv 3x3
-- B <= "000000000";
-- ka <= "00000001" & "10000000";
-- be <= "00000001" & "10000000";
process(clk_100)
begin
    if rising_edge(clk_100) then
		B <= B_in(8 downto 0);
		ka <= ka_in(15 downto 0);
		be <= be_in(15 downto 0);
		if even_tick = '0' then -- if even_tick = btnu_reg then
			-- z8
			if B(8)='0' then Bx(8) <= signed(x11); else Bx(8) <= signed(unsigned(not(x11))+1); end if;
			if B(7)='0' then Bx(7) <= signed(x12); else Bx(7) <= signed(unsigned(not(x12))+1); end if;
			if B(6)='0' then Bx(6) <= signed(x13); else Bx(6) <= signed(unsigned(not(x13))+1); end if;
			if B(5)='0' then Bx(5) <= signed(x21); else Bx(5) <= signed(unsigned(not(x21))+1); end if;
			if B(4)='0' then Bx(4) <= signed(x22); else Bx(4) <= signed(unsigned(not(x22))+1); end if;
			if B(3)='0' then Bx(3) <= signed(x23); else Bx(3) <= signed(unsigned(not(x23))+1); end if;
			if B(2)='0' then Bx(2) <= signed(x31); else Bx(2) <= signed(unsigned(not(x31))+1); end if;
			if B(1)='0' then Bx(1) <= signed(x32); else Bx(1) <= signed(unsigned(not(x32))+1); end if;
			if B(0)='0' then Bx(0) <= signed(x33); else Bx(0) <= signed(unsigned(not(x33))+1); end if;
			-- z9
			sum1 <= Bx(8) + Bx(7); sum2 <= Bx(6) + Bx(5); sum3 <= Bx(4) + Bx(3); sum4 <= Bx(2) + Bx(1); sum5 <= Bx(0);
			-- +10
			sum6 <= sum1 + sum2; sum7 <= sum3 + sum4; sum8 <= sum5;
			-- +11
			sum9 <= sum6 + sum7; sum10<= sum8;
			-- +12
			SumBx <= sum9 + sum10; -- sum11<= sum9 + sum10; -- ed=0, +12
			-- BN
			-- 1+12
			ka_SumBx <= signed(ka) * SumBx;
			-- 2+12
			xn <= ka_SumBx(23 downto 8) + signed(be);
			-- ReLU
			-- 3+12
			if signed(dsp_xn(23 downto 8)) > 0 then
				xn_relu <= signed(dsp_xn(23 downto 8));
			else
				xn_relu <= (OTHERS=>'0');
			end if;
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
