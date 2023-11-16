import sys
import glob
import serial
import tkinter as tk
from tkinter import scrolledtext
from tkinter import END, ttk
from tkinter import  DISABLED, messagebox
from tkinter.font import NORMAL
from tkinter import filedialog as fd
import threading
from bitstring import BitArray

CPU_READY = b'\x01'

class serial_debug:
    def __init__(self):
        self.started = False
        self.filename = ""
        self.memory = {}
        self.running = False

    def conectar(self):
        self.started = True
        if self.filename == "":
            messagebox.showerror(message="Primero debes seleccionar un archivo.", title="Selecciona un archivo")
            return
        f = open(self.filename, "rb")
        for j in range(100):
            array=[]
            for _ in range(4):
                array.append(f.read(1))
            self.memory[j*4] = array
        print_gui(str(self.memory))
        print_gui(str(self.memory[0]))
        threading.Thread(target=self.run).start()

    def stop(self):
        self.started = False

    def run(self):
        self.ser = serial.Serial(input_puerto.get(), input_baud.get())
        if not self.ser.is_open:
            self.ser.open()
        print_gui("Esperando cpu_ready")
        label_estado.config(text= "Esperando cpu_ready")
        self.ser.write(b'\x01')
        self.wait_cpu_ready()
    

    def step_debug(self):
        boton_step.configure(state=DISABLED)
        print_gui("StEEEP")
        self.ser.write(b'\x02')
        if self.started:
            addr = int.from_bytes(self.ser.read(5)[:4], byteorder='little', signed=False)
        #enviar_instruccion(addr, self.memory, self.ser)
        print_gui("Se recibe la direccion: "+ str(addr))
        print_gui("Se envia la instruccion: " + str(self.memory[addr]))
        self.ser.write(b'\x00')
        self.ser.write(self.memory[addr][3])
        self.ser.write(self.memory[addr][2])
        self.ser.write(self.memory[addr][1])
        self.ser.write(self.memory[addr][0])
        print_gui("Instruccion enviada, esperando cpu ready")
        self.wait_cpu_response()

    def run_debug(self):
        boton_run.configure(state=DISABLED)
        boton_pause.configure(state=NORMAL)
        self.running = True
        threading.Thread(target=self._run_debug).start()

    def _run_debug(self):
        while self.running:
            self.step_debug()

    def pause_debug(self):
        boton_run.configure(state=NORMAL)
        boton_pause.configure(state=DISABLED)
        self.running = False
        
    def wait_cpu_response(self):

        while self.started:
            resp_byte_1 = self.ser.read(1)
            if  resp_byte_1 == CPU_READY:
                boton_step.configure(state=NORMAL)
                boton_run.configure(state=NORMAL)
                print_gui("Ready recieved")
                break
            else:
                resp_byte_2_4 = self.ser.read(3)
                print_gui("Recieved addres: "+str(resp_byte_1+resp_byte_2_4))
                write_read_address = int.from_bytes(resp_byte_1+resp_byte_2_4, byteorder='little', signed=False)
                print_gui(write_read_address)
                comand = self.ser.read(1)
                print_gui(str(BitArray(comand)))
                type = BitArray(comand)[:2]
                if type == '0b01':
                    comand = BitArray(comand)[4:]
                    print_gui("instruccion de guardado")
                    write_data = self.ser.read(4)
                    print_gui("la data: " + str(int.from_bytes(write_data, byteorder='little', signed=False)))
                
                elif type == '0b10':
                    comand = BitArray(comand)[4:]
                    print_gui("instruccion de carga")
                    self.ser.write(b'\x07')
                    self.ser.write(b'\x00')
                    self.ser.write(b'\x00')
                    self.ser.write(b'\x00')
                
                if self.ser.read(1) == CPU_READY:
                        boton_step.configure(state=NORMAL)
                        boton_run.configure(state=NORMAL)
                        print_gui("Ready recieved")
                        break

                    

    def wait_cpu_ready(self):
        while self.started:
            if self.ser.read(1) == CPU_READY:
                boton_step.configure(state=NORMAL)
                boton_run.configure(state=NORMAL)
                break
        print_gui("Ready recieved")


    def select_file(self):
        self.filename = fd.askopenfilename(
        title='Abrir archivo',
        initialdir='/',
        filetypes=(
            ('All files', '*.*'),
            ('text files', '*.txt')
        ))
        label_file.config(text= "Archivo: " + self.filename)
    

sd = serial_debug()

def serial_ports():
    """ 
        https://stackoverflow.com/questions/12090503/listing-available-com-ports-with-python
        Lists serial port names

        :raises EnvironmentError:
            On unsupported or unknown platforms
        :returns:
            A list of the serial ports available on the system
    """
    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        ports = glob.glob('/dev/tty.*')
    else:
        raise EnvironmentError('Unsupported platform')

    result = []
    for port in ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    return result

def rescan():
    puertos = serial_ports()
    input_puerto.configure(values=puertos)
    if puertos:
        input_puerto.current(0)


def print_gui(text, new_line = True):
    out_text.configure(state=NORMAL)
    out_text.insert(tk.END, text)
    if new_line:
        out_text.insert(tk.END, "\n")
    out_text.configure(state=DISABLED)
    out_text.see("end")

def clear():
    out_text.configure(state=NORMAL)
    out_text.delete("1.0", tk.END)
    out_text.configure(state=DISABLED)

def enviar_instruccion(addr, memory, fpgaData):
    for i in range(4):
        fpgaData.write(i+1)
        fpgaData.write(bytearray(memory[addr][i-3]))


puertos = serial_ports()
root = tk.Tk()
root.title("Serial debugger")
#root.iconbitmap("logo.ico")
root.geometry("750x550")

frame_conf = tk.LabelFrame(root, relief=tk.GROOVE, padx=10, pady=10, text="Configuración")
frame_conf.grid(row=0, column=0)

label_puerto = tk.Label(frame_conf, text="Puerto: ")
label_puerto.grid(row=0, column=0)

input_puerto = ttk.Combobox(frame_conf, state="readonly", values=puertos)
input_puerto.grid(row = 0, column = 1)
if puertos:
    input_puerto.current(0)

boton_rescan = tk.Button(frame_conf, text="Reescanear", command=rescan)
boton_rescan.grid(row=0, column=2)

boton_open = tk.Button(frame_conf, text='Abrir archivo', command=sd.select_file)
boton_open.grid(row=0, column=3, padx=20, pady=10)

label_baud = tk.Label(frame_conf, text="Baudrate: ")
label_baud.grid(row = 0, column = 4)

input_baud = ttk.Combobox(frame_conf, state="readonly", values=["9600",
                                                               "115200"])
input_baud.grid(row=0, column=5)
input_baud.current(0)

boton_conectar = tk.Button(frame_conf, text="Conectar", command=sd.conectar)
boton_conectar.grid(row=0, column=6)

label_file = tk.Label(frame_conf, text="Archivo: *Debes elegir un archivo*")
label_file.grid(row = 1, column = 0, columnspan=5)

boton_stop = tk.Button(frame_conf, text="Detener", command=sd.stop)
boton_stop.grid(row=1, column=6)


frame_steps = tk.LabelFrame(root, padx=10, pady=10, text="Steps")
frame_steps.grid(row=2, column=0)



boton_step = tk.Button(frame_steps, padx=10, text="Step", state=DISABLED, command=sd.step_debug)
boton_step.grid(row=0, padx=10, column=0)

boton_run = tk.Button(frame_steps, padx=10, text="Run", state=DISABLED, command=sd.run_debug)
boton_run.grid(row=0, padx=50, column=1)

boton_pause = tk.Button(frame_steps, padx=10, text="Pause", state=DISABLED, command=sd.pause_debug)
boton_pause.grid(row=0, padx=10, column=2)

frame_estado = tk.LabelFrame(frame_steps, relief=tk.GROOVE, text="Estado")
frame_estado.grid(row=3, column=0, sticky="WE", columnspan=3, pady=(20,0))

label_estado = tk.Label(frame_estado, text="No iniciado")
label_estado.grid(row = 0, column = 0, padx=20, pady=20)


frame_out = tk.LabelFrame(root, relief=tk.GROOVE, text="Consola")
frame_out.grid(row=4, column=0)

boton_clear = tk.Button(frame_out, text="Limpiar", command=clear)
boton_clear.grid(row=0, column=0)

out_text = scrolledtext.ScrolledText(frame_out,
                                     yscrollcommand=True,
                                     state=DISABLED, 
                                     font= ("Consolas", 10),
                                     width=100,
                                     height=15)
out_text.grid(row=1,column=0)



def on_closing():
    if messagebox.askokcancel("Cerrar", "¿Realmente quieres salir?"):
        root.destroy()
        

root.protocol("WM_DELETE_WINDOW", on_closing)
root.mainloop()