echo "installing wifi led service..."

touch /etc/systemd/system/wifi-led.service
cat > /etc/systemd/system/wifi-led.service <<EOL
[Unit]
Description=Service to LED and flash LED on GPIO 23
After=multi-user.target
[Service]
Type=idle
ExecStart=/usr/bin/python /etc/wifi-led/wifi-led.py
[Install]
WantedBy=multi-user.target
EOL

chmod +x /etc/systemd/system/wifi-led.service

sudo systemctl enable wifi-led.service

echo "installing wifi led service Script..."

mkdir /etc/wifi-led/
touch /etc/wifi-led/wifi-led.py
cat > /etc/wifi-led/wifi-led.py <<EOL
#WIFI Led Service for Raspberry PI
#Switch on GPIO 23 if google is contactable, off if not
import RPi.GPIO as GPIO
import urllib2
import time

def getBytesRec():
        lines = open("/proc/net/dev", "r").readlines()

        columnLine = lines[1]
        _, receiveCols , transmitCols = columnLine.split("|")
        receiveCols = map(lambda a:"recv_"+a, receiveCols.split())
        transmitCols = map(lambda a:"trans_"+a, transmitCols.split())

        cols = receiveCols+transmitCols

        faces = {}
        for line in lines[2:]:
                if line.find(":") < 0: continue
                face, data = line.split(":")
                faceData = dict(zip(cols, data.split()))
                faces[face] = faceData

        return faces[' wlan0']['recv_packets']


def run():

        GPIO.setmode(GPIO.BCM)
        bytesLast = 0

        try:
            while True:

                bytesRec = getBytesRec()

                int(bytesRec) - int(bytesLast)

                if(int(bytesRec) - int(bytesLast) < 2):
                        GPIO.output(23,GPIO.LOW)
                else:
                        GPIO.setup(23,GPIO.OUT)
                        GPIO.output(23,GPIO.HIGH)
                        bytesLast = bytesRec
                time.sleep(0.1)

        finally:
            GPIO.cleanup()


run()

EOL

service wifi-led start

echo "Done, Service Setup and started, your LED should be on providing you have internet access"
