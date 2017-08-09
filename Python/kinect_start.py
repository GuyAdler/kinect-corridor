import rpyc

nuc1 = rpyc.connect("localhost",18863)
nuc2 = rpyc.connect("192.168.1.145", 18863)
nuc3 = rpyc.connect("192.168.1.124", 18863)
input("Press button to start kinecting!\n")
nuc2.root.StartKinect()
nuc3.root.StartKinect()
nuc1.root.StartKinect()

input("Kinects working. Press a button to stop recording.\n")
meta2 = nuc2.root.StopKinect()
meta3 = nuc3.root.StopKinect()
meta1 = nuc1.root.StopKinect()

if meta2 == 0:
	print("Kinect 2 has no meta.txt")
if meta1 == 0:
	print("Kinect 1 has no meta.txt")
if meta3 == 0:
	print("Kinect 3 has no meta.txt")

input("Mission accomplished.\n");