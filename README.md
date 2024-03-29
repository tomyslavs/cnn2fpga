# CNN to FPGA

## Introduction
This project was created to test different configuration of CNN on ZynQ platform. Image (color or gray) and net configuration are transmitted to ZedBoard, stored in DDR and processed on the chip (with processing system - PS and programmable logic - PL). The classification results are transmitted back to PC.

## Tools used in this project

* Matlab + Neural Network Toolbox
* Python + Jupyter Notebook
* Vivado 2017.2 + SDK
* ZedBoard (xc7z020 chip)

Matlab script was used to train CNN and store net configuration in csv files. Python script used to load csv and stream net configuration to ZynQ chip on ZedBoard through IP/TCP packets. The IP core of CNN was written with VHDL, simulated with testbenches and implemented in Vivado. The standalone application (written in C) for ARM processor was developed in Xilinx SDK. The application handles lwIP (light-weight IP stack), DMA (direct memory access), and other function responsible for CNN core reconfiguration and data exchange between PS and PL. 

## Convolution-BN-ReLU-MaxPool Core

<img width="500" height="250" src="https://github.com/tomyslavs/cnn2fpga/blob/master/conv-core.png" />

Related papers:
* [Paper 1](https://ieeexplore.ieee.org/document/8732160) - Adaptation of convolution and batch normalization layer
* [Paper 2](https://ieeexplore.ieee.org/document/8592464) - CNN training and image classification on PC
* [Paper 3](https://www.mdpi.com/2079-9292/9/11/1823) - mNet2FPGA: A Design Flow for Mapping a Fixed-Point CNN to Zynq SoC FPGA
* [Paper 4](https://www.mdpi.com/2077-0472/12/11/1849) - FPGA Implementation of a Convolutional Neural Network and Its Application for Pollen Detection upon Entrance to the Beehive
