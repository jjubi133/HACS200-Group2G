#!/bin/bash

#grep with argument that should be logfile ex APLL.log
attackIp= `grep "Auto Access" /home/student/personalContainer.log| tail -n 4 | head -n 1 | cut -d" " -f8 | cut -d"," -f1`
#add iptable that blocks everything
iptables --insert FORWARD --source 0.0.0.0 --destination 10.0.3.1 --protocol tcp --destination-port 6901 --jump DROP
# add iptable that allows traffic from one ip
iptables --insert FORWARD --source $attackIP --destination 10.0.3.1 --protocol tcp --destination-port 6901 --jump ACCEPT
