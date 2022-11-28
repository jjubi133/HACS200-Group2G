#!/bin/bash

date=`/usr/bin/date`
/usr/bin/touch /home/student/"healthLog$date"
#Checking RAM
echo ">>>RAM<<<" >> /home/student/"healthLog$date"
/usr/bin/free -m >> /home/student/"healthLog$date"
#Checking Disk Space
echo ">>>Disk Space<<<" >> /home/student/"healthLog$date"
/usr/bin/df >> /home/student/"healthLog$date"
#Checking Average System Load
echo ">>>Average System Load<<<" >> /home/student/"healthLog$date"
echo `/usr/bin/uptime` >> /home/student/"healthLog$date"
#Checking Network Traffic
echo ">>>Network Traffic<<<" >> /home/student/"healthLog$date"
/usr/bin/netstat -altn >> /home/student/"healthLog$date"
