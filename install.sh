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

def internet_on():
    try:
        urllib2.urlopen('http://216.58.192.142', timeout=1)
        return True
    except urllib2.URLError as err:
        return False

GPIO.setmode(GPIO.BCM)

try:
    while True:
        if internet_on() is not True:
                GPIO.output(23,GPIO.LOW)
        else:
                GPIO.setup(23,GPIO.OUT)
                GPIO.output(23,GPIO.HIGH)
        time.sleep(10)

finally:
    GPIO.cleanup()
EOL

service wifi-led start

echo "Done, Service Setup and started, your LED should be on providing you have internet access"
