# Introduction
This project was created to test different configuration of CNN on embedded system. Image (color or gray) and configuration of CNN are transmitted to ZedBoard, stored in DDR and processed on the chip (with processing system - PS and programmable logic - PL). The classification results are transmitted back to PC.

## Software tools:
Vivado 2017.2 + SDK
Matlab script to train CNN and store net configuration in csv files.
Python script to load csv and stream net configuration to ZynQ chip on ZedBoard through IP/TCP packets
