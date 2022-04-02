import serial
import struct

def enviar_instruccion(addr, memory, fpgaData):
    for i in range(8):
        if(i==0):
            fpgaData.write(b'\x01')
        elif(i==1):
            fpgaData.write(bytearray(memory[addr][3]))
        elif(i==2):
            fpgaData.write(b'\x02')
        elif(i==3):
            fpgaData.write(bytearray(memory[addr][2]))
        elif(i==4):
            fpgaData.write(b'\x03')
        elif(i==5):
            fpgaData.write(bytearray(memory[addr][1]))
        elif(i==6):
            fpgaData.write(b'\x04')
        elif(i==7):
            fpgaData.write(bytearray(memory[addr][0]))

f = open("D:/GitHub/usm_microcontroller_v1/Hex_programs/io_test.txt","rb")
fpgaData = serial.Serial('COM4', 9600)
fpgaData.timeout = 0.001

memory = {}

for j in range(20):
    array=[]
    for i in range(4):
        array.append(f.read(1))
    memory[j*4] = array

print(memory)
print(memory[0])

running_state = 0
running = 0

while True:
    if fpgaData.in_waiting:
        if(running==1 & running_state == 0):
            print("Running...")
            running_state = 1
        addr = int.from_bytes(fpgaData.read(4)[:4], byteorder='little', signed=False)
        fpgaData.reset_input_buffer()
        #print("instr: " , addr)
        enviar_instruccion(addr, memory, fpgaData)
        #print('env: ',memory[addr])
        running = 1
        
        
