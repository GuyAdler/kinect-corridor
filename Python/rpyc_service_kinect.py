import rpyc
import time
import win32com.client
from subprocess import Popen, PIPE
import pythoncom
import os

class MyService(rpyc.Service):
    def on_connect(self):
        # code that runs when a connection is created
        # (to init the serivce, if needed)
        pass

    def on_disconnect(self):
        pass
		
    def exposed_StartKinect(self):
        print("Start recording...\n")
        self.kinect_process = Popen("corridor-recorder.exe", stdin=PIPE)
        self.start_time = time.time()
        self.before_list = os.listdir("C:\kinect-corridor-videos")

    def exposed_StopKinect(self):
        pythoncom.CoInitialize()
        shell = win32com.client.Dispatch("WScript.Shell")
        shell.SendKeys("Q")
        time.sleep(0.1)
        shell.SendKeys("Q")
        time.sleep(0.1)
        shell.SendKeys("Q")
        time.sleep(0.1)
        shell.SendKeys("Q")
        time.sleep(0.1)
        self.kinect_process.kill()
        elapsed_time = time.time() - self.start_time
        diff = list(set(os.listdir("C:\kinect-corridor-videos")) - set(self.before_list))
        new_folder = "C:\kinect-corridor-videos" + "\\" + diff[0] + "\\"
        content = os.listdir(new_folder)
        if content[-1] != 'meta.txt':
            print(new_folder + " does not contain meta.txt")
            return 0;
        print("Finished recording. Recorded for %d seconds.\n\n" % (elapsed_time))
        return 1;

if __name__ == "__main__":
    from rpyc.utils.server import ThreadedServer
    t = ThreadedServer(MyService, port = 18863)
    print("Connection received!\n")
    t.start()