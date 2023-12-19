import array as arr
import math
import operator

NOP = 232   # NumberOfParameters    # NOP = "global"

def init_param(length):
    param = [0]*(length+1)
    param[0] = 0            # nesiunciamas, ARM pats pasiskaiciuoja len pagal gautus param o i param[0] iraso len
    param[1] = 2            # 2-all param | 8-SnM param only and to ddr/bram only
    param[2] = 1            # if param[2] = 0-to ddr/bram/qspi | 1-to ddr/bram
    # print(len(param))
    return param

 
def marge_param():
    param = init_param(NOP)                             # initial param, NOP = 232
    # Parameters from User Interface
    adc_oversampling = [1, 1, 1, 1, 1, 1, 1, 1]         # ADC oversampling, butinai 2^N = 1..2048, Tik Signed
    adc_timing = [0, 0, 0, 0, 0, 0, 0, 0]               # ADC timing, us. Tik Unsigned
    adc_offset = [0, 0, 0, 0, 0, 0, 0, 0]               # ADC amplitude offset, mV. Signed arba unsigned
    sh1 = [0, 0, 0, 0, 0]                              # 1 SH open delay, ms | 1on1 close delay, ms | Invert 0/1 | 1on1 open delay | Enable 1on1 delays
    sh2 = [0, 0, 0, 0, 0]                              # 2 SH open delay, ms | 1on1 close delay, ms | Invert 0/1 | 1on1 open delay | Enable 1on1 delays
    sh3 = [0, 0, 0, 0, 0]                              # 3 SH open delay, ms | 1on1 close delay, ms | Invert 0/1 | 1on1 open delay | Enable 1on1 delays
    sh4 = [0, 0, 0, 0, 0]                              # 4 SH open delay, ms | 1on1 close delay, ms | Invert 0/1 | 1on1 open delay | Enable 1on1 delays
    sh5 = [0, 0, 0, 0, 0]                              # 5 SH open delay, ms | 1on1 close delay, ms | Invert 0/1 | 1on1 open delay | Enable 1on1 delays
    pp = [0.0001, 0.0001, 1, 0, 0]                     # PP delay, ms | PP pulse width, ms | PP divider | Invert 0/1 | Enable PP
    ccd1 = [0, 0, 0, 0, 0]                           # 1 CCD delay, ms | CCD pulse width, ms | CCD divider | Invert 0/1 | CCD mode
    ccd2 = [0, 0, 0, 0, 0]                           # 2 CCD delay, ms | CCD pulse width, ms | CCD divider | Invert 0/1 | CCD mode
    ccd3 = [0, 0, 0, 0, 0]                           # 3 CCD delay, ms | CCD pulse width, ms | CCD divider | Invert 0/1 | CCD mode
    ccd4 = [0, 0, 0, 0, 0]                           # 4 CCD delay, ms | CCD pulse width, ms | CCD divider | Invert 0/1 | CCD mode
    ccd5 = [0, 0, 0, 0, 0]                           # 5 CCD delay, ms | CCD pulse width, ms | CCD divider | Invert 0/1 | CCD mode
    ccd = [ccd1, ccd2, ccd3, ccd4, ccd5]
    at12 = [0.9, 0.9]                                # Debouncer duration AT1, us | AT2, us
    sh_close_delay = [0, 0, 0, 0, 0]                    # S-on-1 SH close delay, ms | 2 | 3 | 4 | 5
    Bad_pulses = 2                                      # Bad pulses 32b
    Shot_pulses = 100                                # Shot pulses 64b
    Last_pulses = 0                                     # Last pulses (close sh before)
    After_pulses = 0                                    # Add pulses
    Initial_delay = [0]*8                               # Initial delay after trigger in calibr mode, us
    # Energy parameters
    Erange = [0, 0, 0]                                  # Energija, Voltais, pvz: [0.05, 0.5, 2.5]; unsigned
    Energy_k = [0, 0, 0]                                # 64b unsigned
    Energy_b = [0, 0, 0]                                # 64b signed
    # Scattering parameters
    Total_detection_points = 100000000                   # Riba surinktu tasku, kada laikome kad pasizeide ir stabdome matavima
    Detection_points = [0, 0, 0, 0, 0]                  # Penkiu fotodiodu taskai uz pazeidima
    Scatt_OverThresh = [0, 0, 0, 0, 0]                  # mV, Overvoltage, kai fotodiodo itampa didesne nei Scatt_OverThresh, tai pridedam tasku
    Scatt_b = [0, 0, 0, 0, 0]
    Scatt_k = [0, 0, 0, 0, 0]
    First_adapt_multiplier = [0, 0, 0, 0, 0]
    First_adapt_adder = [0, 0, 0, 0, 0]
    First_adapt_multiplier_2 = [0, 0, 0, 0, 0]
    First_adapt_adder_2 = [0, 0, 0, 0, 0]
    AntiDust = [1, 1, 1, 2, 2]                          # kiek kartu turi buti detektuotas pazeidimas arba overvoltage, kad pridetu tasku.
    Lowest_det_threshold = [0, 0, 0, 0, 0]              # bits
    Detection_limit = [0, 0, 0, 0, 0]                   # [1 Detection limit, 2 Detection limit, 3 Detection limit, 4 Detection limit, 5 Detection limit]
    Before_pulses = 0                                   # 32b
    Timing_calibration_step = 0.1                       # us, 32b, maziausias: 0.01, 0.02, 0.03, ...
    Fit_to_zero_negative_voltage = 0                    # 0/1

    # save in param vector
    param[16] = ccd_sel_seq_addr(ccd)                   # CCD delay index max
    param[17:24+1] = [0, 0, 0, 0, 0, 0, 0, 0]           # ADC input voltage, 0/1 = 4V/10V, parodo kokia max itampa ateina is fotodiodo
    param[25:32+1] = adc_oversampling                   # ADC oversampling, butinai 2^N = 1..2048
    param[33:40+1] = us_to_10ns(adc_timing)             # ADC timing, us -> 10ns
    param[41:48+1] = mV_to_bin_code(adc_offset)         # ADC amplitude offset, mV -> code

    param[49:53+1] = [ms_to_10ns([sh1[0]])[0], ms_to_10ns([sh1[1]])[0], sh1[2], ms_to_10ns([sh1[3]])[0], sh1[4]]
    param[54:58+1] = [ms_to_10ns([sh2[0]])[0], ms_to_10ns([sh2[1]])[0], sh2[2], ms_to_10ns([sh2[3]])[0], sh2[4]]
    param[59:63+1] = [ms_to_10ns([sh3[0]])[0], ms_to_10ns([sh3[1]])[0], sh3[2], ms_to_10ns([sh3[3]])[0], sh3[4]]
    param[64:68+1] = [ms_to_10ns([sh4[0]])[0], ms_to_10ns([sh4[1]])[0], sh4[2], ms_to_10ns([sh4[3]])[0], sh4[4]]
    param[69:73+1] = [ms_to_10ns([sh5[0]])[0], ms_to_10ns([sh5[1]])[0], sh5[2], ms_to_10ns([sh5[3]])[0], sh5[4]]

    param[74:78+1] = [ms_to_10ns([pp[0]])[0], ms_to_10ns([pp[1]])[0], pp[2], pp[3], pp[4]]
    param[79:83+1] = [ms_to_10ns([ccd1[0]])[0], ms_to_10ns([ccd1[1]])[0], ccd1[2], ccd1[3], ccd1[4]]
    param[84:88+1] = [ms_to_10ns([ccd2[0]])[0], ms_to_10ns([ccd2[1]])[0], ccd2[2], ccd2[3], ccd2[4]]
    param[89:93+1] = [ms_to_10ns([ccd3[0]])[0], ms_to_10ns([ccd3[1]])[0], ccd3[2], ccd3[3], ccd3[4]]
    param[94:98+1] = [ms_to_10ns([ccd4[0]])[0], ms_to_10ns([ccd4[1]])[0], ccd4[2], ccd4[3], ccd4[4]]
    param[99:103+1] = [ms_to_10ns([ccd5[0]])[0], ms_to_10ns([ccd5[1]])[0], ccd5[2], ccd5[3], ccd5[4]]
    param[104:105+1] = us_to_10ns(at12)                 # Debouncer AT1, us | AT2, us
    param[106:111+1] = [0, 1, 2, 4, 1, 0]               # Pultelis: Key A Shutter [0..4] | Key B [0..4] | Key C 0..4 | Key D 0..4 | Key A 0..4 | Enable | Key A for Damage; 
    param[112] = 0                                      # AT input select: 0/1 = AT1 arba AT2 trigerio pasirinkimas
    param[113:117+1] = ms_to_10ns(sh_close_delay)       # Shutter 1 close delay, ms | 2 | 3 | 4 | 5
    param[118] = Bad_pulses                             # Bad pulses
    param[119:120+1] = conv_64b_to_2x32b(Shot_pulses)   # Shot pulses [Lo 32b, Hi 32b]
    param[121:123+1] = [Last_pulses, After_pulses, 0]     # Last pulses (close sh before) | Add pulses | Bsize-not used
    param[124:131+1] = us_to_10ns(Initial_delay)        # Initial delay after trigger in calibr mode, us
    param[132] = at_delay_to_snm(0, adc_oversampling, adc_timing)
    volt2bin = 8000 # Voltage to binary
    param[133] = int(round(Erange[0]*volt2bin))         # Energy 1 range 16b, *65535/8.192
    param[134:135+1] = conv_64b_to_2x32b(Energy_k[0])   # Energy 1 k 64b [Lo, Hi]
    param[136:137+1] = conv_64b_to_2x32b(Energy_b[0])   # Energy 1 b 64b [Lo, Hi]
    param[138] = int(round(Erange[1]*volt2bin))         # Energy 2 range 16b, *65535/8.192
    param[139:140+1] = conv_64b_to_2x32b(Energy_k[1])   # Energy 2 k 64b [Lo, Hi]
    param[141:142+1] = conv_64b_to_2x32b(Energy_b[1])   # Energy 2 b 64b [Lo, Hi]
    param[143] = int(round(Erange[2]*volt2bin))         # Energy 3 range 16b, *65535/8.192
    param[144:145+1] = conv_64b_to_2x32b(Energy_k[2])   # Energy 3 k 64b [Lo, Hi]
    param[146:147+1] = conv_64b_to_2x32b(Energy_b[2])   # Energy 3 b 64b [Lo, Hi]
    param[148] = Total_detection_points                             # Total detection points 32b
    # Scattering 1
    mV2bin = 2**3
    mult_scale_factor = 2**10 # daugybos rezultatu suvienodinimui FPGA
    param[149] = Detection_points[0]                                # 1 Detection points 32b
    param[150] = int(round(mV2bin*Scatt_OverThresh[0]))             # 1 Scatt_OverThresh 32b
    param[151:152+1] = conv_64b_to_2x32b(Scatt_b[0])                # 1 Scatt_b 64b [Lo, Hi]
    param[153:154+1] = conv_64b_to_2x32b(Scatt_k[0])                # 1 Scatt_k 64b [Lo, Hi]
    param[155] = int(round(mult_scale_factor*First_adapt_multiplier[0]))         # 1 First_adapt_multiplier 32b
    param[156:157+1] = conv_64b_to_2x32b(First_adapt_adder[0])      # 1 First_adapt_adder 64b
    param[158] = int(round(mult_scale_factor*First_adapt_multiplier_2[0]))       # 1 First_adapt_multiplier 32b
    param[159:160+1] = conv_64b_to_2x32b(First_adapt_adder_2[0])    # 1 First_adapt_adder 64b
    param[161] = AntiDust[0]                                        # 1 AntiDust 32b
    param[162:163+1] = conv_64b_to_2x32b(Lowest_det_threshold[0])   # 1 Lowest_det_threshold 64b
    # Scattering 2
    param[164] = Detection_points[1]                                # 2 Detection points 32b
    param[165] = int(round(mV2bin*Scatt_OverThresh[1]))                  # 2 Scatt_OverThresh 32b
    param[166:167+1] = conv_64b_to_2x32b(Scatt_b[1])                # 2 Scatt_b 64b [Lo, Hi]
    param[168:169+1] = conv_64b_to_2x32b(Scatt_k[1])                # 2 Scatt_k 64b [Lo, Hi]
    param[170] = int(round(mult_scale_factor*First_adapt_multiplier[1]))         # 2 First_adapt_multiplier 32b
    param[171:172+1] = conv_64b_to_2x32b(First_adapt_adder[1])      # 2 First_adapt_adder 64b
    param[173] = int(round(mult_scale_factor*First_adapt_multiplier_2[1]))       # 2 First_adapt_multiplier 32b
    param[174:175+1] = conv_64b_to_2x32b(First_adapt_adder_2[1])    # 2 First_adapt_adder 64b
    param[176] = AntiDust[1]                                        # 2 AntiDust 32b
    param[177:178+1] = conv_64b_to_2x32b(Lowest_det_threshold[1])   # 2 Lowest_det_threshold 64b
    # Scattering 3
    param[179] = Detection_points[2]                                # 3 Detection points 32b
    param[180] = int(round(mV2bin*Scatt_OverThresh[2]))                  # 3 Scatt_OverThresh 32b
    param[181:182+1] = conv_64b_to_2x32b(Scatt_b[2])                # 3 Scatt_b 64b [Lo, Hi]
    param[183:184+1] = conv_64b_to_2x32b(Scatt_k[2])                # 3 Scatt_k 64b [Lo, Hi]
    param[185] = int(round(mult_scale_factor*First_adapt_multiplier[2]))         # 3 First_adapt_multiplier 32b
    param[186:187+1] = conv_64b_to_2x32b(First_adapt_adder[2])      # 3 First_adapt_adder 64b
    param[188] = int(round(mult_scale_factor*First_adapt_multiplier_2[2]))       # 3 First_adapt_multiplier 32b
    param[189:190+1] = conv_64b_to_2x32b(First_adapt_adder_2[2])    # 3 First_adapt_adder 64b
    param[191] = AntiDust[2]                                        # 3 AntiDust 32b
    param[192:193+1] = conv_64b_to_2x32b(Lowest_det_threshold[2])   # 3 Lowest_det_threshold 64b
    # Scattering 4
    param[194] = Detection_points[3]                                # 4 Detection points 32b
    param[195] = int(round(mV2bin*Scatt_OverThresh[3]))                  # 4 Scatt_OverThresh 32b
    param[196:197+1] = conv_64b_to_2x32b(Scatt_b[3])                # 4 Scatt_b 64b [Lo, Hi]
    param[198:199+1] = conv_64b_to_2x32b(Scatt_k[3])                # 4 Scatt_k 64b [Lo, Hi]
    param[200] = int(round(mult_scale_factor*First_adapt_multiplier[3]))         # 4 First_adapt_multiplier 32b
    param[201:202+1] = conv_64b_to_2x32b(First_adapt_adder[3])      # 4 First_adapt_adder 64b
    param[203] = int(round(mult_scale_factor*First_adapt_multiplier_2[3]))       # 4 First_adapt_multiplier 32b
    param[204:205+1] = conv_64b_to_2x32b(First_adapt_adder_2[3])    # 4 First_adapt_adder 64b
    param[206] = AntiDust[3]                                        # 4 AntiDust 32b
    param[207:208+1] = conv_64b_to_2x32b(Lowest_det_threshold[3])   # 4 Lowest_det_threshold 64b
    # Scattering 5
    param[209] = Detection_points[4]                                # 5 Detection points 32b
    param[210] = int(round(mV2bin*Scatt_OverThresh[4]))                  # 5 Scatt_OverThresh 32b
    param[211:212+1] = conv_64b_to_2x32b(Scatt_b[4])                # 5 Scatt_b 64b [Lo, Hi]
    param[213:214+1] = conv_64b_to_2x32b(Scatt_k[4])                # 5 Scatt_k 64b [Lo, Hi]
    param[215] = int(round(mult_scale_factor*First_adapt_multiplier[4]))         # 5 First_adapt_multiplier 32b
    param[216:217+1] = conv_64b_to_2x32b(First_adapt_adder[4])      # 5 First_adapt_adder 64b
    param[218] = int(round(mult_scale_factor*First_adapt_multiplier_2[4]))       # 5 First_adapt_multiplier 32b
    param[219:220+1] = conv_64b_to_2x32b(First_adapt_adder_2[4])    # 5 First_adapt_adder 64b
    param[221] = AntiDust[4]                                        # 5 AntiDust 32b
    param[222:223+1] = conv_64b_to_2x32b(Lowest_det_threshold[4])   # 5 Lowest_det_threshold 64b
    param[224] = Detection_limit[0]*16 + Detection_limit[1]*8 + Detection_limit[2]*4 + Detection_limit[3]*2 + Detection_limit[4]*1
    # other param
    voltage_const = 14073963587174 # SnM metu skaicius naudojamas pastumti binary itampos vertei
    param[225:226+1] = conv_64b_to_2x32b(14073963587174)            # 14073963587174 64b
    param[227] = Before_pulses                                      # Before_pulses
    param[228] = us_to_10ns([Timing_calibration_step])[0]           # Timing_calibration_step 32b
    param[229] = Fit_to_zero_negative_voltage                       # 0/1
    param[230] = 0                                                  # not used
    param[231] = 0                                                  # not used
    param[232] = 0                                                  # not used

    # print(param)
    # print(len(param))
    return param


def at_delay_to_snm(offset, nover, delay):              # Kontroleris pats perskaiciuoja at_delay_to_snm (Arme), offset cia nenaudojamas, tik calibracijoje
    val = [0] * 8
    ticks_per_oversample = 6
    us2ns = 100
    for i in range(0, 8):
        val[i] = 70+nover[i]*ticks_per_oversample+delay[i]*us2ns # kiekvienam is adc kanalu paskaiciuoja, kada ateis samplas
    [max_index, max_value] = max_idx_val(val)
    return max_value                                    # grazina didziausia delay, kada startuoti SnM


def ccd_sel_seq_addr(ccd):  # find index of ccd channel with max delay
    tmp = []
    for i in range(0, 5):
        if ccd[i][4] == 2:      # if ccd_mode==2
            val = ccd[i][0]     # ccd_delay, ms
        else:
            val = 0
        tmp.append(val)
    [max_index, max_value] = max_idx_val(tmp)
    return max_index+1


def us_to_10ns(val):  # microseconds to 10ns pulses, kiek i val mikrosekundziu telpa impulsu po 10ns
    num32 = []
    us2ns = 100
    for i in range(0, len(val)):
        tmp = int(round(val[i]*us2ns))
        num32.append(tmp)
    return num32


def ms_to_10ns(val):  # milliseconds to 10ns pulses, kiek i val milisekundziu telpa impulsu po 10ns
    num32 = []
    ms2ns = 100000   #
    for i in range(0, len(val)):
        tmp = int(round(val[i]*ms2ns)) 
        num32.append(tmp)
    return num32


def mV_to_bin_code(val):  # millivolts to binarinis code
    num32 = []
    mV2bin = 2**3 # 8 = (2**13)/1024)
    for i in range(0, len(val)):
        tmp = int(round(val[i]*(2**13)/1024))
        num32.append(tmp)
    return num32


def conv_64b_to_2x32b(val):
    lo = val % 2**32
    hi = math.floor(val/2**32)
    return [lo, hi]


def max_idx_val(values):
    max_index, max_value = max(enumerate(values), key=operator.itemgetter(1))
    return [max_index, max_value]


def min_idx_val(values):
    min_index, min_value = min(enumerate(values), key=operator.itemgetter(1))
    return [min_index, min_value]



