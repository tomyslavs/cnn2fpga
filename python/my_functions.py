import socket
import array as arr
import math
import csv
import time
import numpy as np

prec = 12 # 12/10 bits for floating part

# ------------------------ Declarations --------------------------------- %
'''Butina nustatyti eth IP 192.168.3.99, nes sis IP visose kontroleriuose'''
kontrolerio_ip = "192.168.3.99"     # IP
kontrolerio_port = 99               # PORT


# ------------------------ read csv data --------------------------------------- %
def read_csv(path_to_csv, columns):
	with open(path_to_csv) as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		line_count = 0
		csv_data = []
		for row in csv_reader:
			line_count += 1
			for col in range(0,columns):
				csv_data.append(float(row[col]))
	print(f'Processed {line_count} lines.')
	# print(csv_data)
	return csv_data


# ------------------------ float to int list ----------------------------------- %
def float_to_int_list(float_list):
	int_list = []
	for item in float_list:
		int_list.append(int(item))
	return int_list
	
	
# ------------------------ decode net layers ---------------------------------- %
def decode_net_layers(net_as_list, print_layer_name):
	int_list = []
	col=0
	conv_idx=0
	bn_idx=0
	relu_idx=0
	pool_idx=0
	fc_idx=0
	layers = [0]*6
	input_resolution=[]
	in_res=[]
	out_res=[]
	input_resolution=[]
	fname_conv=[]
	fname_fc_w=[]
	fname_fc_b=[]
	ch_in_conv=[]
	ch_out_conv=[]
	ch_in_fc=[]
	ch_out_fc=[]
	conv_type=[]
	y_lim=[]
	x_lim=[]
	for i in range(len(net_as_list)):
		# int_list.append(int(item))
		if col == 0:
			if net_as_list[i] == 0:
				if print_layer_name:
					print('Input image')
				Y=net_as_list[i+1]
				X=net_as_list[i+2]
				input_resolution.append(net_as_list[i+1])
				input_resolution.append(net_as_list[i+2])
				input_resolution.append(net_as_list[i+3])
			elif net_as_list[i] == 1:
				if print_layer_name:
					print('Conv')
				conv_idx = conv_idx + 1
				fname = 'net-' + str(conv_idx) + 'Bkabe.csv'
				fname_conv.append(fname)
				ch_in_conv.append(net_as_list[i+1])
				ch_out_conv.append(net_as_list[i+2])
				y_lim.append(int(Y))
				x_lim.append(int(X))
				in_res.append(int(Y*X))
				out_res.append(int(Y*X))
				conv_type.append(1)
				# print(fname)
			elif net_as_list[i] == 2:
				if print_layer_name:
					print('Conv+BN')
				bn_idx = bn_idx + 1
				conv_idx = conv_idx + 1
				fname = 'net-' + str(conv_idx) + 'Bkabe.csv'
				fname_conv.append(fname)
				ch_in_conv.append(net_as_list[i+1])
				ch_out_conv.append(net_as_list[i+2])
				y_lim.append(int(Y))
				x_lim.append(int(X))
				in_res.append(int(Y*X))
				out_res.append(int(Y*X))
				conv_type.append(2)
			elif net_as_list[i] == 3:
				if print_layer_name:
					print('Conv+BN+ReLU')
				relu_idx = relu_idx + 1
				bn_idx = bn_idx + 1
				conv_idx = conv_idx + 1
				fname = 'net-' + str(conv_idx) + 'Bkabe.csv'
				fname_conv.append(fname)
				ch_in_conv.append(net_as_list[i+1])
				ch_out_conv.append(net_as_list[i+2])
				y_lim.append(int(Y))
				x_lim.append(int(X))
				in_res.append(int(Y*X))
				out_res.append(int(Y*X))
				conv_type.append(3)
			elif net_as_list[i] == 4:
				if print_layer_name:
					print('Conv+BN+ReLU+MaxPool')
				pool_idx = pool_idx + 1
				relu_idx = relu_idx + 1
				bn_idx = bn_idx + 1
				conv_idx = conv_idx + 1
				fname = 'net-' + str(conv_idx) + 'Bkabe.csv'
				fname_conv.append(fname)
				ch_in_conv.append(net_as_list[i+1])
				ch_out_conv.append(net_as_list[i+2])
				y_lim.append(int(Y))
				x_lim.append(int(X))
				in_res.append(int(Y*X))
				Y=int(Y/2)
				X=int(X/2)
				out_res.append(int(Y*X))
				conv_type.append(4)
			elif net_as_list[i] == 5:
				if print_layer_name:
					print('FC')
				fc_idx = fc_idx + 1
				fname = 'net-' + str(fc_idx) + 'fc_w.csv'
				fname_fc_w.append(fname)
				fname = 'net-' + str(fc_idx) + 'fc_b.csv'
				fname_fc_b.append(fname)
				ch_in_fc.append(net_as_list[i+1])
				ch_out_fc.append(net_as_list[i+2])
				# print(fname)
			else:
				print('Warning: wrong layer' + net_as_list[i])
		if col < 3:
			col=col+1
		else:
			col=0
	# print(fname_conv)
	layers[0]=1 # num of input layers
	layers[1]=conv_idx # conv layers
	layers[2]=bn_idx # BN layers
	layers[3]=relu_idx # ReLU layers
	layers[4]=pool_idx # Max Pool layers
	layers[5]=fc_idx # FC layers
	return layers, conv_type, input_resolution, in_res, out_res, ch_in_conv, ch_out_conv, ch_in_fc, ch_out_fc, fname_conv, fname_fc_w, fname_fc_b, y_lim, x_lim


# ------------------------ 16b+16b merge to 32b layers ------------------------ %
def restructure_conv_bn_layer(layer, ch_in, ch_out):
	new_layer = []
	j=0
	for i in range(len(layer)):
		if i%2==0: # scan through each second record and merge two neighbour numbers to single 32b pair 
			if j >= 0 and j <= 7: # merge B
				new_layer.append(int((layer[i+1]*2**16) + layer[i])) # [B1<<16 + B0]
			elif j >= 8 and j <= 23: # merge k, b
				lo16 = int(fix(layer[i+0]*2**prec))
				hi16 = int(fix(layer[i+1]*2**prec))
				if lo16 < 0:
					lo16 = 2**16 + lo16
				if hi16 < 0:
					hi16 = 2**16 + hi16
				hi16lo16 = int(hi16*2**16+lo16)
				new_layer.append(hi16lo16) # [k1<<16 + k0] or [zeros + b0]
			elif j >= 24 and j <= 31: # merge zeros
				new_layer.append(0) # [0<<16 + 0]
		if j < 31:
			j = j + 1
		else:
			j = 0
		# print('j=' + str(j))
	return new_layer

def fix(num):
	# return int(num)
	# return round(num)
	return ((num > 0) - (num < 0)) * int(abs(num) + 0.5) # 0.5 up
	# if num >= 0:
		# return math.ceil(num)
	# else:
		# return math.floor(num)

# ------------------------ insert summation core ------------------------------ %
def insert_summation_core(all_conv_layers,sum_conv):
	num_of_cores = int(len(all_conv_layers)/512*4)
	if num_of_cores < 15: # then fill with zeros
		for j in range(num_of_cores,15): # until 15th
			for i in range(0,128):
				all_conv_layers.extend([0])
		# all_conv_layers = insert_15th_summation_core(all_conv_layers) # insert summation core at end
		all_conv_layers.extend(sum_conv) # insert summation core at end
	elif num_of_cores == 15:
		# all_conv_layers = insert_15th_summation_core(all_conv_layers) # insert summation core at end
		all_conv_layers.extend(sum_conv) # insert summation core at end
	else:
		# tmp = insert_15th_summation_core(all_conv_layers[0:int(512/4)*15]) # insert summation core between cores 15-sum-16
		tmp = all_conv_layers[0:int(512/4)*15] # insert summation core between cores 15-sum-16
		tmp.extend(sum_conv) # insert summation core
		tmp.extend(all_conv_layers[int(512/4)*15::]) 
		all_conv_layers = tmp
	return all_conv_layers
	

# def insert_15th_summation_core(all_conv_layers):
	# for k in range(0,8): # insert summation core at 16th address.
		# all_conv_layers.extend([0,0,0,0]) # insert B=0
		# if k==0:
			# all_conv_layers.extend([0*2**16+256,0*2**16+0,0*2**16+256,0*2**16+0]) # in CH0+CH4 => CH0 out
		# elif k==1:
			# all_conv_layers.extend([256*2**16+0,0*2**16+0,256*2**16+0,0*2**16+0]) # in CH1+CH5 => CH1 out
		# elif k==2:
			# all_conv_layers.extend([0*2**16+0,0*2**16+256,0*2**16+0,0*2**16+256]) # in CH2+CH6 => CH2 out
		# elif k==3:
			# all_conv_layers.extend([0*2**16+0,256*2**16+0,0*2**16+0,256*2**16+0]) # in CH3+CH7 => CH3 out
		# else:
			# all_conv_layers.extend([0,0,0,0]) # do not sum, 0 => CH4-7 out
		# all_conv_layers.extend([0,0,0,0]) # insert b=0
		# all_conv_layers.extend([0,0,0,0]) # insert zeros
	# return all_conv_layers

# ------------------------ Marge layer y, x input resolution to 32b number ------ % 
def get_yx_lim(y_lim, x_lim):
	yx_lim = int(y_lim*2**16+x_lim)
	return yx_lim


# ------------------------ how much cores in each batch? ------------------------ % 
def get_conv_core_batch_vctr(total_conv_cores):
	conv_core_batch_vctr=[16] # first batch always at least 16 cores
	rem = total_conv_cores-16 # remaining cores
	while(rem>0):
		if(rem>=15):
			batch_size = 15
		else:
			batch_size = rem
		conv_core_batch_vctr.extend([batch_size])
		rem = rem - batch_size
	return conv_core_batch_vctr


# ------------------------ how much core configs each layer? -------------------- % 
def get_conv_cfgs(ch_in_conv, ch_out_conv):
	core_cfgs = []
	inout_core_cfgs = []
	# inout_core_cfgs[0] = ch_in_conv[0]
	for i in range(0,len(ch_in_conv)):
		core_cfgs.append(math.ceil(ch_in_conv[i]/8)*math.ceil(ch_out_conv[i]/8))
		inout_core_cfgs.append(math.ceil(ch_in_conv[i]/8))
	inout_core_cfgs.append(math.ceil(ch_out_conv[i]/8))
	return core_cfgs, inout_core_cfgs
	
	
# ------------------------ how much dst0 configs on layer output? --------------- %
def get_dst0_Lout_cfgs(ch_in_conv, ch_out_conv):
	dst0_Lout_cfgs = []
	sum_on_Lout = []
	for i in range(0,len(ch_in_conv)):
		if ch_in_conv[i] > 8:
			dst0_Lout_cfgs.append(math.ceil(ch_out_conv[i]/4))
			sum_on_Lout.append(1)
		else:
			dst0_Lout_cfgs.append(math.ceil(ch_in_conv[i]/8)*math.ceil(ch_out_conv[i]/8))
			sum_on_Lout.append(0)
	return dst0_Lout_cfgs, sum_on_Lout
	
# ------------------------ Rearrange addresses with a 4096 step ----------------- %
def shift_step_4096(num,N4096):
    tmp = num/N4096
    if num%N4096==0:
        tmp = int(tmp)*N4096
    else:
        tmp = int(tmp+1)*4096
    return tmp


# ------------------------ increment core index until [0-14] and reset ---------- %
def increment_core_index(ci): # [0-14] BRAM blocks reserved to store conv+bn weights, [15th] BRAM used to store summation core and never write to 15th address after initial config!
	if ci<14:
		return ci+1
	else:
		return 0


# ------------------------ insert conv core config update instruction ----------- %
def insert_core_cfg_update_instr(k,j,CCBS,CCS,ccbi,conv_core_batch_vctr,CORE_BASE,instrlist,l,layerlist,total_conv_cores):
	if j%CCBS==0 and (j==0 or j<total_conv_cores-1):
		print('update core config, j',j)
		size_TX = conv_core_batch_vctr[ccbi]*CCS
		size_RX = 0
		if ccbi>0: # for all next core updates
			src_0 = CORE_BASE + CCS*(CCBS*ccbi+1) # base+15*n+1
		else: # for first core cfgs
			src_0 = CORE_BASE + CCS*(CCBS*ccbi) # base+15*n # 2020-01-06
		src_1 = 0
		dst_0 = 0
		dst_1 = 0
		instr = [0x10,conv_core_batch_vctr[ccbi],size_TX,size_RX,src_0,src_1,dst_0,dst_1] # next 15 conv cores cfg
		instrlist.append(instr)
		layerlist.append(l)
		k=k+1
		ccbi=ccbi+1 # conv batch idx
	return instrlist, ccbi, k, layerlist


# ------------------------ insert instruction to list --------------------------- %
def insert_instr_to_list(k,cmd0,cmd1,sizeTX,sizeRX,src_0,src_1,dst_0,dst_1,instrlist,l,layerlist):
	instr = [cmd0,cmd1,sizeTX,sizeRX,src_0,src_1,dst_0,dst_1]
	instrlist.append(instr)
	layerlist.append(l)
	k=k+1
	return instrlist, k, layerlist


# ------------------------ Source addresses on layer input ---------------------- %
def get_source_addresses_on_layer_input(layers,inout_core_cfgs,IMG_BASE,IMG_ZERO,sum_on_Lout,dst0_Lout,dst1_Lout):
	src0_Lin = []
	src1_Lin = []
	for l in range(layers[1]): # loop over all conv layers
	#     print('In layer',l)
		src0 = []
		src1 = []
		for co in range(0,inout_core_cfgs[l+1]): # loop over all out conv configs
			for ci in range(0,inout_core_cfgs[l]): # loop over all in conv configs
	#             print('Core',co,ci)
				if l==0: # image on input layer
					src0.append(IMG_BASE)
					src1.append(IMG_ZERO)
				else:
					if sum_on_Lout[l-1]==1: # summation cores appear in l-th layer
						src0.append(dst0_Lout[l-1][2*ci+0])
						src1.append(dst0_Lout[l-1][2*ci+1])
					else:
						src0.append(dst0_Lout[l-1][ci])
						src1.append(dst1_Lout[l-1][ci])
	#     print(src0)
	#     print(src1)
		src0_Lin.append(src0)
		src1_Lin.append(src1)
	print('src0_Lin',src0_Lin)
	print('src1_Lin',src1_Lin)
	return src0_Lin, src1_Lin


# ------------------------ split FC w to 8CH of DMA0 and 8CH of DMA1 ---------- %
def reorder_fc_w(raw_fc_w, ch_in, CH):
	CHsize = int(len(raw_fc_w)/ch_in)
	HalfOfCHsize = int(CHsize/2)
	w = []
	fc_in_mem_updates = int(math.ceil(ch_in/CH))
	for i in range(fc_in_mem_updates):
		base = i*CHsize*CH
		for j in range(0,CH): # DMA0 weights
			addr = base + j*CHsize
			block = raw_fc_w[addr:addr+HalfOfCHsize]
			w.extend(block)
		for j in range(0,CH): # DMA1 weights
			addr = base + j*CHsize + HalfOfCHsize
			block = raw_fc_w[addr:addr+HalfOfCHsize]
			w.extend(block)
	return w
	

# ------------------------ 16b+16b merge to 32b layers ------------------------ %
def restructure_fc_w(layer, ch_in, ch_out):
	new_layer = []
	for i in range(len(layer)):
		if i%2==0: # scan through each second record and merge two neighbour numbers to single 32b pair 
			lo16 = int(fix(layer[i+0]*2**prec))
			hi16 = int(fix(layer[i+1]*2**prec))
			if lo16 < 0:
				lo16 = 2**16 + lo16
			if hi16 < 0:
				hi16 = 2**16 + hi16
			hi16lo16 = int(hi16*2**16+lo16)
			new_layer.append(hi16lo16) # [w1<<16 + w0]
	return new_layer
	

# ------------------------ 16b+16b merge to 32b layers ------------------------ %
def restructure_fc_b(layer, ch_in, ch_out, mul):
	new_layer = []
	half_len = int(math.ceil(len(layer)/2))
	for i in range(0, half_len):
		# if i%2==0: # scan through each second record and merge two neighbour numbers to single 32b pair 
		lo16 = int(fix(layer[i+0]*2**prec))
		hi16 = int(fix(layer[i+half_len]*2**prec))
		if lo16 < 0:
			lo16 = 2**16 + lo16
		if hi16 < 0:
			hi16 = 2**16 + hi16
		hi16lo16 = int(hi16*2**16+lo16)
		new_layer.append(hi16lo16) # [w1<<16 + w0]
	return new_layer


# ------------------------ 16b+16b merge to 32b layers ------------------------ %
def restructure_img(img, yxz):
	# img - 8 bit RGB or Gray image
	# yxz - image resolution
	new_img = []
	for y in range(0, yxz[0]): # iki Feb 11 buvo y
		for x in range(0, yxz[1]): # iki Feb 11 buvo x
			if yxz[2]==3: # 3 Channels
				CH1CH0 = int(img[y,x,1]*(2**16)*(2**(prec-8)) + img[y,x,0]*(2**(prec-8)))	# G-CH1 & R-CH0 = 16b & 16b = 32b
				CH3CH2 = int(img[y,x,2]*(2**(prec-8))) 						# 0-CH3 & B-CH2 = 16b & 16b = 32b
				# CH1CH0 = int(1*2**16 + 1)	# G-CH1 & R-CH0 = 16b & 16b = 32b
				# CH3CH2 = int(1) 			# 0-CH3 & B-CH2 = 16b & 16b = 32b
			elif yxz[2]==1: # 1 Channel
				CH1CH0 = int(img[y,x])*(2**(prec-8))  	# 0-CH1 & Gray-CH0 = 8b
				# CH1CH0 = int(1)  			# 0-CH1 & Gray-CH0 = 8b
				CH3CH2 = 0 					# 0-CH3 & 0-CH2
			new_img.append(CH1CH0)
			new_img.append(CH3CH2)
	return new_img


# ------------------------ Insert spaces between 32b data --------------------- %
def format_before_send(cmd0, param):
	send_data = str(cmd0) + ' ' + str(len(param)) + ' '
	for i in range(0, len(param)):
		send_data = send_data + str(param[i]) + ' '     # atskirt tarpais visus parametrus
	return send_data


# ------------------------ Insert spaces between 32b data and send ------------ %
def format_and_send(client, param, cmd0, wait_time):
	send_data=""
	for i in range(0,64):	# 64 Bytes of 0xFF
		send_data+=chr(255)
	send_data+=chr(cmd0)	# cmd0 = Byte[64]
	send_data+=chr(0)		# Byte[65]
	send_data+=chr(0)		# Byte[66]
	send_data+=chr(0)		# Byte[67]
	
	a = len(param)			# length 32 bits
	a0=(a>> 0) & 0x000000FF
	a1=(a>> 8) & 0x000000FF
	a2=(a>>16) & 0x000000FF
	a3=(a>>24) & 0x000000FF
	send_data+=chr(a0)		# Byte[68]
	send_data+=chr(a1)		# Byte[69]
	send_data+=chr(a2)		# Byte[70]
	send_data+=chr(a3)		# Byte[71]
	for i in range(0, len(param)):
		a = param[i]
		a0=(a>> 0) & 0x000000FF
		a1=(a>> 8) & 0x000000FF
		a2=(a>>16) & 0x000000FF
		a3=(a>>24) & 0x000000FF
		send_data+=chr(a0)
		send_data+=chr(a1)
		send_data+=chr(a2)
		send_data+=chr(a3)
	client.sendall(send_data.encode('latin-1')) # send packets
	time.sleep(wait_time)
	# return send_data


# ------------------------ 2x8b to 16b (osci1/2, timing) ---------------- %
def two_bytes_to_sample(recvdata, kiek):  # for osci1, osci2, timming
    '''recvdata - 8b IP/TCP paketo duomenys
    kiek - kiek samplu ateina i PC is kontrolerio.
    osci1, osci2, timming rezimuose kontroleris i PC siuncia 4B samplui.
    Si f-ja sulipdo tikra sampla is 2B.
    Teigiamam skaiciui - pirmi 2 baitai nuliai.
    Neigiamam skaiciui - 255 255'''
    # lenB = utf8len(str(recvdata))
    # print(lenB)
    num32 = []
    for i in range(0, kiek):
        # print(num32)
        j = 2*i
        # tmp = (recvdata[3+j] << 24)+(recvdata[2+j] << 16)+(recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        tmp = (recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        if recvdata[1+j] >= 128:   # is negative?
            tmp = tmp - 256*256
        # tmp = tmp / 8000    # code to voltage, V
        num32.append(tmp)
    return num32


# ------------------------ Get 3D array of frames ----------------------- %
def raw2images(raw_vector, RES):
    image = np.zeros((RES,RES),dtype=np.uint16)
    line = np.array(bytearray(raw_vector), dtype=np.uint16)
    image = np.reshape(line,(RES,RES)) # 1D to 2D array
    return image
	
def rgb2gray(rgb):
    return np.dot(rgb[...,:3], [0.2989, 0.5870, 0.1140])
	
	
# # ------------------------ Insert spaces between 32b data and send ------------ %
# def format_and_send(client, po128, cmd0, param, wait_sec):
	# new_param = [cmd0, len(param)]
	# new_param.extend(param)
	# paketu = int(math.ceil(len(new_param)/po128))
	# samplu_paskutiniame_pakete = len(new_param) % po128
	# print('Viso', paketu, 'paketai')
	# for j in range(0, paketu):
		# print('Paketas:', j)
		# send_data = str(new_param[po128*j]) + ' '
		# if (j==paketu-1) and samplu_paskutiniame_pakete > 0: # jei paskutinis paketas yra nepilnas
			# for i in range(1+po128*j, po128*j+samplu_paskutiniame_pakete):
				# send_data = send_data + str(new_param[i]) + ' '
		# else:
			# for i in range(1+po128*j, po128*(j+1)):
				# send_data = send_data + str(new_param[i]) + ' '
		# client.sendall(send_data.encode('utf-8'))
		# time.sleep(wait_sec)
	# return send_data


# # ------------------------ 4x8b to 32b (osci1/2, timing) ---------------- %
# def four_bytes_to_sample(recvdata, kiek):  # for osci1, osci2, timming
    # '''recvdata - 8b IP/TCP paketo duomenys
    # kiek - kiek samplu ateina i PC is kontrolerio.
    # osci1, osci2, timming rezimuose kontroleris i PC siuncia 4B samplui.
    # Si f-ja sulipdo tikra sampla is 4B.
    # Teigiamam skaiciui - pirmi 2 baitai nuliai.
    # Neigiamam skaiciui - 255 255'''
    # # lenB = utf8len(str(recvdata))
    # # print(lenB)
    # num32 = []
    # for i in range(0, kiek):
        # # print(num32)
        # j = 4*i
        # # tmp = (recvdata[3+j] << 24)+(recvdata[2+j] << 16)+(recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        # tmp = (recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        # if recvdata[2+j] == 255:   # is negative?
            # tmp = tmp - 256*256
        # tmp = tmp / 8000    # code to voltage, V
        # num32.append(tmp)
    # return num32


# # ------------------------ Osci 1 --------------------------------------- %
# def osci1(nover):
    # '''nover - samplu skaicius, kuriuos kontrolerius atsius i PC'''
    # num8 = []   # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = 4 x nsamples
    # num32 = []  # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = nsamples
    # cmd0 = '32 0 2 1 ' + str(nover) + ' 0 0 0 '    # '32 '=str(32) - run osci 1
    # print("cmd0: " + cmd0)
    # data = send_receive_8ch(cmd0, nover*4)  # kodel tik 4B ateina, turi buti 4B x 8, nes Py priima po send_single_buffer, t.y. kiekvienam CH atskirai
    # # print('raw data: ' + str(data))
    # # print('conversion 4B to sample')
    # for i in range(0, 8):
# #         print('kanalas: ' + str(i))
        # kanalo_samplai = four_bytes_to_sample(data[i], nover)             # 4B x 8 x Nsamples
        # num32.append(kanalo_samplai)
    # return num32


# # ------------------------ Osci 2 --------------------------------------- %
# def osci2(nsamples):
    # '''nsamples - samplu skaicius, kuriuos kontrolerius atsius i PC'''
    # num8 = []   # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = 4 x nsamples
    # num32 = []  # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = nsamples
    # cmd0 = '48 1 2 ' + str(nsamples) + ' 4 0 0 0 '    # '48 '=str(48) - run osci 2
    # print("cmd0: " + cmd0)
    # data = send_receive_8ch(cmd0, nsamples*4)
    # # print('raw data: ' + str(data))
    # # print('conversion 4B to sample')
    # for i in range(0, 8):
# #         print('kanalas: ' + str(i))
        # kanalo_samplai = four_bytes_to_sample(data[i], nsamples)             # 4B x 8 x Nsamples
        # num32.append(kanalo_samplai)
    # return num32


# # ------------------------ Timing --------------------------------------- %
# def timing_calibration(nsamples, nover):
    # '''nsamples - samplu skaicius, kuriuos kontrolerius atsius i PC.
    # nover - oversampling rate, gali buti tik nover=2^N: 1,2,4,8,...,2048 - 
    # tai tasku skaicius, kuriuos suvidurkinus gaunamas vienas samplas'''
    # num8 = []   # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = 4 x nsamples
    # num32 = []  # cia saugosim visu kanalu vektorius nuosekliai [CH1[...], ... , CH8[...]], length = nsamples
    # cmd0 = '128 1 2 ' + str(nsamples) + ' ' + str(nover) + ' 0 0 0 '    # '128 '=str(128) - run timing calibration
    # print("cmd0: " + cmd0)
    # data = send_receive_8ch(cmd0, nsamples*4)
    # # print('raw data: ' + str(data))
    # # print('conversion 4B to sample')
    # for i in range(0, 8):
# #         print('kanalas: ' + str(i))
        # kanalo_samplai = four_bytes_to_sample(data[i], nsamples)             # 4B x 8 x Nsamples
        # num32.append(kanalo_samplai)
    # return num32


# ------------------------ Send and receive IP/TCP packet Osci 1/2/Timing %
def send_receive_8ch(send_data, recv_len_in_B):
    '''Sia komandos siuntimo ir paketu is kontrolerio gavimo f-ja naudoja 
    osci1, osci2 ir timing rezimai
    send_data - tai cmd0 komanda siunciama i kontroleri
    recv_len_in_B - kiek baitu PC priims is kontrolerio'''
    # import socket
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    address = (kontrolerio_ip, kontrolerio_port)
    client.connect(address)
    client.sendall(send_data.encode('utf-8'))
    num8 = []
    for i in range(0, 8):
        # print('kanalas: ' + str(i))
        # received_data = client.recv(recv_len_in_B)  # ARM send low byte first, ne visus data priima, kai ilgas buferis
        received_data = recvall(client, recv_len_in_B)  # ARM send low byte first
        # print(received_data)
        num8.append(received_data)
    return num8


# ------------------------ Receive All IP/TCP Data ---------------------- %
def recvall(sock, count):
    '''super-duper f-ja, kuri is kontrolerio laukia lygiai count baitu
    sock - jau sujungto socketo struktura'''
    buf = b''
    while count:
        newbuf = sock.recv(count)
        if not newbuf:
            return None
        buf += newbuf
        count -= len(newbuf)
    return buf


# # ------------------------ Get Info ------------------------------------- %
# def get_info():
    # '''Si f-ja kvieciama po Shot and Measure ir grazina 4 skaicius:
    # ivykusios/neivykusios pazaidos priezasti,
    # detekcijos statusus,
    # autorange diodo indeksa, prie kurio buvo prisirista,
    # kiek issauta impulsu'''
    # cmd0 = '6 '                         # '6 '=str(6) - Get info after SnM done
    # data = send_receive_packet(cmd0, 5*4)
    # info = decode_param(data, 5)        # 5x4B = Priezastis & Detect Status & Impulses(Hi32) & Impulses (Lo32) & Test
    # info64b = arr.array('d', [0, 0, 0, 0])
    # info64b[0] = info[0]                                # Priezastis
    # info64b[1] = info[1] & 65535                        # Detect Status
    # info64b[2] = info[1] >> 16                          # Autorange diodas
    # info64b[3] = (info[2] << 32) + info[3]              # Num of Impulses
    # # info64b[4] = info[4]                              # Test, unused
    # return info64b


# # ------------------------ Send CCD sequence ---------------------------- %
# def set_ccd_sequence(sequence):   # cmd0='5 len 0 0 0 0 0 0 sequence[0] sequence[1] ... '
    # '''I kontoleri siuncia sequence vektoriu su skaiciais nusakanciais, kada atidavineti
    # CCD trigerius kontrolerio CCD isejimuose'''
    # send_data = '5 ' + str(len(sequence)) + ' 0 0 0 0 0 0 '
    # for i in range(0, len(sequence)):
        # send_data = send_data + str(sequence[i]) + ' '     # atskirt tarpais visus ccd sequence[i]
    # print(send_data)
    # send_packet(send_data)


# # ------------------------ Send param ----------------------------------- %
# def send_param(param, snm_param, dis_wr_qspi): # cmd0='2 0 '-param to ddr/bram/qspi (wait a bit to finish wr to qspi) | cmd0='2 1 '-param to ddr/bram only | cmd0='8 X '-SnM param to ddr, bram only
    # '''Siuncia param parametrus i kontroleri,
    # jei snm_param = True, tai kontroleris supras, kad ateina Shot and Measure parametrai
    # jei snm_param = False, tai visi i kontroleri atkeliauja visi parametrai
    # jei dis_wr_qspi = True, tai kontroleris neirasynes parametru i flash atminti ZedBoarde
    # jei dis_wr_qspi = False - irasys i atminti
    # Irasius i flash kontroleris po restarto uzkraus paskutinius irasytus parametrus'''
    # if snm_param:
        # param[1] = 8    # cmd0 = 8 - SnM param only to FPGA, neiraso i QSPI nepriklausomai nuo param[2] leidimo
    # else:
        # param[1] = 2    # cmd0 = 2 - All param
    # if dis_wr_qspi:
        # param[2] = 1    # Disable WR to QSPI
    # else:
        # param[2] = 0    # Enable WR to QSPI
    # send_data = str(param[1]) + ' ' + str(param[2]) + ' '
    # for i in range(3, len(param)):
        # # param[i] = i
        # send_data = send_data + str(param[i]) + ' '     # atskirt tarpais visus parametrus
    # print(send_data)
    # send_packet(send_data) # cmd0 + ' ' + param[2] + kiti param


# # ------------------------ Receive param -------------------------------- %
# def recv_param(kiek_param):
    # '''Pasiima is kontrolerio kiek_param parametru'''
    # cmd0 = '1 '                                 # '1 '=str(1) - AT freq uzklausa
    # data = send_receive_packet(cmd0, kiek_param*4)
    # param = decode_param(data, kiek_param)      # 4B each = po 32b
    # return param                                # [32b, ...]


# # ------------------------ Get Temperature Humidity --------------------- %
# def get_temp_hum():
    # '''Is kontrolerio nuskaito temperatura ir dregme
    # Jei is sensoriau atejo neteisingas header, tai temperatura -1 ir dregme -1'''
    # cmd0 = '16 '                        # '16 '=str(16) - Temperature/Humidity
    # data = send_receive_packet(cmd0, 2*4)
    # temp_hum = arr.array('f', [-1.0, -1.0])
    # head = (data[7] << 24)+(data[6] << 16)+(data[5] << 8)+(data[4] << 0)
    # if head == 772:                     # correct header from sensor
        # temp_hum[0] = ((data[1] << 8) + (data[0] << 0))/10  # 16b Temperature
        # temp_hum[1] = ((data[3] << 8) + (data[2] << 0))/10  # 16b Humidity
        # return temp_hum                 # [32b, 32b]
    # else:
        # return [-1, -1]                 # [32b, 32b]


# # ------------------------ Get soft version ----------------------------- %
# def get_version():
    # '''Kontroleris atsius softo versija: metai, menuo, diena, dienos versija'''
    # cmd0 = '18 '                        # '18 '=str(18) - Versijos uzklausa
    # data = send_receive_packet(cmd0, 4*4)
    # vers = decode_param(data, 4)        # 4x4B = 2x32b = 4 po 32b
    # return vers                         # [32b, 32b, 32b, 32b]


# # ------------------------ Get AT Frequency ----------------------------- %
# def get_freq():
    # '''Nuskaitome AT trigerio dazni'''
    # cmd0 = '17 '                        # '17 '=str(17) - AT freq uzklausa
    # data = send_receive_packet(cmd0, 2*4)
    # freq = decode_param(data, 2)        # 2x4B = 2x32b = AT1 & AT2 po 32b
    # return freq                         # [32b, 32b]


# ------------------------ Decode 4x8b to 32b --------------------------- %
def decode_param(recvdata, kiek):  # for revc_freq, recv_param, get_info, get_version
    '''Sulipdo is 4 baitu viena 32b skaiciu'''
    # lenB = utf8len(str(recvdata))
    # print(lenB)
    num32 = []
    for i in range(0, kiek):
        # print(num32)
        j = 4*i
        tmp = (recvdata[3+j] << 24)+(recvdata[2+j] << 16)+(recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        num32.append(tmp)
    return num32


# ------------------------ Send and receive IP/TCP packet --------------- %
def send_receive_packet(send_data, recv_len_in_B):
    '''I kontroleri siuncia send_data,
    is kontrolerio gauna recv_len_in_B ilgio received_data duomenis'''
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    address = (kontrolerio_ip, kontrolerio_port)
    client.connect(address)
    client.sendall(send_data.encode('utf-8'))
    # received_data = client.recv(recv_len_in_B)  # ARM send low byte first
    received_data = recvall(client, recv_len_in_B)
    return received_data


# ------------------------ Send IP/TCP packet --------------------------- %
def send_packet(send_data):
    '''I kontroleri siuncia send_data'''
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    address = (kontrolerio_ip, kontrolerio_port)
    client.connect(address)
    client.sendall(send_data.encode('utf-8'))


def send_packet_c(send_data): # and returns client
    '''I kontroleri siuncia send_data ir grazina client struktura'''
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    address = (kontrolerio_ip, kontrolerio_port)
    client.connect(address)
    client.sendall(send_data.encode('utf-8'))
    return client


# ------------------------ Receive IP/TCP packet ------------------------ %
def receive_packet():   # recv_len_in_B
    '''Kolkas niekur netaikoma. Priima duomenis is kontrolerio'''
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    address = (kontrolerio_ip, kontrolerio_port)
    client.connect(address)
    received_data = client.recv(65536)  # ARM send low byte first
    # received_data = recvall(client, recv_len_in_B)
    return received_data


# # ------------------------ Set Shutters --------------------------------- %
# def set_shutters(sh):   # set shutters: 1 2 3 4 5
    # '''Nustato shutteriu isejimus'''
    # send_data = '3 ' + str(sh[0]) + ' ' + str(sh[1]) + ' ' + str(sh[2]) + ' ' + str(sh[3]) + ' ' + str(sh[4]) + " 0 0 "     # "3 1 1 0 1 1 0 0 "
    # send_packet(send_data)


# # ------------------------ Set Pulse Picker ----------------------------- %
# def set_pp(pp):   # set pulse picker
    # '''Nustato pulse pickerio isejima. Turi buti enablintas pp isejimas param[78]'''
    # send_data = '4 ' + str(pp) + " 0 0 0 0 0 0 "     # "3 pp 0 0 0 0 0 0 "
    # send_packet(send_data)


# # ------------------------ Set soft AT ---------------------------------- %
# def set_soft_at(freq):   # set soft AT frequency
    # '''Rankiniu budu nustatome soft trigerio dazni,
    # jei freq = 0, tai naudojame trigerio signala prijungta prie AT1 ar AT2'''
    # if freq > 0:
        # enable = '1'
        # num_of_pulses = int(round(100000000/freq))
    # else:
        # enable = '0'
        # num_of_pulses = 100000000
    # send_data = '9 ' + enable + ' ' + str(num_of_pulses) + " 0 0 0 0 0 "     # "9 enable num 0 0 0 0 0 "
    # send_packet(send_data)


# # ------------------------ String lenght in Bytes ----------------------- %
# def utf8len(s):
    # return len(s.encode('utf-8'))


# # ------------------------ Stop Session --------------------------------- %
# def stop_snm_session():   # set stop session while SnM
    # '''Stabdome IP/TCP sesija tarp kontrolerio ir PC.
    # Naudojama SnM metu, kai is PC puses norime stabdyti matavima'''
    # send_data = '15 ' + "0 0 0 0 0 0 0 "     # "15 0 0 0 0 0 0 0 "
    # send_packet(send_data)


# # ------------------------ Shot and Measure ----------------------------- %
# def snm(Before_pulses, Shot_pulses, After_pulses, AT1freq, AT2freq):
    # '''SnM - Shot and Measure routine. I kontroleri siunciame:
    # Before_pulses - kiek before impulsu issaugoti,
    # Shot_pulses - kiek impulsu issauti,
    # After_pulses - kiek after impulsu issaugoti,
    # AT1freq - trigerio daznis AT1 iejime, 
    # AT2freq - trigerio daznis AT2 iejime.'''
    # snm_done = 0    # snm done flag
    # samples = [] 
    # Bsize = set_Bsize(AT1freq, AT2freq) # kokio dydzio blokais priiminesim samplus is kontrolerio
    # print('Bsize', Bsize)
    # Sum_pulses = Before_pulses + Shot_pulses + After_pulses # suma ateinanciu samplu is vieno kanalo
    # print('Sum_pulses', Sum_pulses)
    # Nkartu = Sum_pulses/Bsize # kiek turi ateiti bloku, kad visus samplus atsiustu 
    # print('Nkartu', Nkartu)
    # Nkartu_up = math.ceil(Nkartu)
    # print('Nkartu_up', Nkartu_up)
    # Nkartu32hi = math.floor(Nkartu_up/4294967296)   # IQ
    # print('Nkartu32hi', Nkartu32hi)
    # Nkartu32lo = Nkartu_up % 4294967296             # Rem
    # print('Nkartu32lo', Nkartu32lo)
    # Nkartu_down = math.floor(Nkartu)
    # print('Nkartu_down', Nkartu_down)
    # Last_buffer_size = Sum_pulses - Bsize * Nkartu_down # paskutinio bloko dydis
    # print('Last_buffer_size', Last_buffer_size)
    # send_data = '64 1 2 ' + str(Bsize) + ' 2 0 ' + str(Nkartu32lo) + ' ' + str(Nkartu32hi) + ' ' + str(Last_buffer_size) + " 0 0 0 0 0 0 0 "    # "64 ... " - SnM
    # print('send_data', send_data)
    # bytes_to_read = snm_bytes_to_read(Bsize, Last_buffer_size, Nkartu_up - 1, 0)
    # print('bytes_to_read', bytes_to_read)
    # klient = send_packet_c(send_data)
    # while snm_done == 0:
        # recv_data = recvall(klient, bytes_to_read)
        # snm_done, recv_data, bytes_to_read = get_end(recv_data, bytes_to_read)       # if last samples come in full batch, then in next full batch CRC + 00..
        # if bytes_to_read > 0:
            # samples = four_bytes_to_snm_graph(recv_data, int(bytes_to_read/2))
            # for i in range(0, 8):
                # print('samples[', i, ']', samples[i*(bytes_to_read>>4):(i+1)*(bytes_to_read>>4)])


# # ------------------------ SnM pulses init, send to ARM ----------------------------- %
# def snm1(Before_pulses, Shot_pulses, After_pulses, AT1freq, AT2freq, Bsize):
    # '''SnM pirma dalis - nusiuncia paketu dydzio nustatymus ir grazina:
    # klient - klienta,
    # bytes_to_read - po kiek baitu priimineti duomenis'''
# #     Bsize = set_Bsize(AT1freq, AT2freq) # kokio dydzio blokais priiminesim samplus is kontrolerio
    # print('Bsize', Bsize)
    # Sum_pulses = Before_pulses + Shot_pulses + After_pulses # suma ateinanciu samplu is vieno kanalo
    # print('Sum_pulses', Sum_pulses)
    # Nkartu = Sum_pulses/Bsize # kiek turi ateiti bloku, kad visus samplus atsiustu 
    # print('Nkartu', Nkartu)
    # Nkartu_up = math.ceil(Nkartu)
    # print('Nkartu_up', Nkartu_up)
    # Nkartu32hi = math.floor(Nkartu_up/4294967296)   # IQ
    # print('Nkartu32hi', Nkartu32hi)
    # Nkartu32lo = Nkartu_up % 4294967296             # Rem
    # print('Nkartu32lo', Nkartu32lo)
    # Nkartu_down = math.floor(Nkartu)
    # print('Nkartu_down', Nkartu_down)
    # Last_buffer_size = Sum_pulses - Bsize * Nkartu_down # paskutinio bloko dydis
    # print('Last_buffer_size', Last_buffer_size)
    # send_data = '64 1 2 ' + str(Bsize) + ' 2 0 ' + str(Nkartu32lo) + ' ' + str(Nkartu32hi) + ' ' + str(Last_buffer_size) + " 0 0 0 0 0 0 0 "    # "64 ... " - SnM
    # print('send_data', send_data)
    # bytes_to_read = snm_bytes_to_read(Bsize, Last_buffer_size, Nkartu_up - 1, 0)
    # print('bytes_to_read', bytes_to_read)
    # klient = send_packet_c(send_data)
    # return klient, bytes_to_read


# # ------------------------ SnM recv samples from ARM ----------------------------- %
# def snm2(klient, bytes_to_read):
    # '''SnM antra dalis - is kontrolerio skaito samplus (bytes_to_read baitu).
    # Sia f-ja reikia sukti while snm_done == 0 loope, nes kontroleris sius sampus kol nera pazeidimo'''
    # samples = []
    # recv_data = recvall(klient, bytes_to_read)
    # snm_done, recv_data, bytes_to_read = get_end(recv_data, bytes_to_read)       # if last samples come in full batch, then in next full batch CRC + 00..
    # if bytes_to_read > 0:
        # samples = four_bytes_to_snm_graph(recv_data, int(bytes_to_read/2))       # ant mano kompo konvertavimas letina IP/TCP paketu priemima
    # return snm_done, recv_data, samples, bytes_to_read


# # ------------------------ Shot and Measure ----------------------------- %
# def snm_bytes_to_read(Bsize, Last_buffer_size, Num_of_batches, Batch_iteration):   #
    # '''Kiek baitu saudaro viena priimama bloka SnM metu'''
    # if Last_buffer_size > 0 and Num_of_batches == Batch_iteration: # if last batch, tai naudok Last_buffer_size
        # num = Last_buffer_size
    # else:
        # num = Bsize
    # bytes_to_read = 16 * num
    # return bytes_to_read


# # ------------------------ Read flag of SnM end ------------------------- %
# def get_end(recvdata, bytes_to_read):   #
    # '''Si f-ja tikrina ar pasibaige SnM procedura, kai visi impulsas issauti arba detektuota pazaida.
    # Grazina snm_done flaga;
    # recvdata_n - ateje samplai;
    # bytes_to_read - kiek tai baitu.'''
    # if b'\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa' in recvdata:  # SnM done flag detected
        # snm_done = 1
        # indx = recvdata.find(b'\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa')
        # recvdata_n = recvdata[0:indx]
    # else:
        # snm_done = 0
        # recvdata_n = recvdata
        # indx = bytes_to_read
    # return snm_done, recvdata_n, indx


# # ------------------------ 2x8b to 16b/sample (snm) ---------------- %
# def four_bytes_to_snm_graph(recvdata, kiek):  # for SnM, kiek=suma samplu is visu ch.
    # '''Is dvieju baitu sulipdo viena sampla.
    # recvdata - samplai;
    # kiek - suma samplu is visu kanalu'''
    # kiek_pulses = kiek >> 3
    # ch1 = []
    # ch2 = []
    # ch3 = []
    # ch4 = []
    # ch5 = []
    # ch6 = []
    # ch7 = []
    # ch8 = []
    # for i in range(0, kiek):
        # j = 2*i
        # tmp = (recvdata[1+j] << 8)+(recvdata[0+j] << 0)   # bitwise shift
        # if recvdata[j+1] > 127:   # is negative?
            # tmp = tmp - 256*256
        # tmp = tmp / 8000    # code to voltage, V
        # ch_idx = 2*math.floor(i/(kiek_pulses*2)) + i % 2
        # if ch_idx == 0:
            # ch1.append(tmp)
        # elif ch_idx == 1:
            # ch2.append(tmp)
        # elif ch_idx == 2:
            # ch3.append(tmp)
        # elif ch_idx == 3:
            # ch4.append(tmp)
        # elif ch_idx == 4:
            # ch5.append(tmp)
        # elif ch_idx == 5:
            # ch6.append(tmp)
        # elif ch_idx == 6:
            # ch7.append(tmp)
        # else:
            # ch8.append(tmp)
    # ch_all = [ch1] + [ch2] + [ch3] + [ch4] + [ch5] + [ch6] + [ch7] + [ch8]
    # # ch_all = ch1 + ch2 + ch3 + ch4 + ch5 + ch6 + ch7 + ch8
    # return ch_all


# # ------------------------ calc batch size (Bsize) for ARM -------------- %
# def set_Bsize(AT1freq, AT2freq):
    # '''Pagal trigerio dazni pasirenkam batch size Bsize'''
    # if AT1freq >= AT2freq:
        # ATmax = AT1freq
    # else:
        # ATmax = AT2freq
    # if ATmax > 160000: # kaip paskutineje LabView versijoje
        # Bsize = 16380
    # else:
        # Bsize = 100
    # # if ATmax > 160000:
        # # Bsize = 16380
    # # else:
        # # Bsize = 16
    # # if ATmax > 16000:
        # # Bsize = 200
    # # else:
        # # Bsize = 100
    # return Bsize
