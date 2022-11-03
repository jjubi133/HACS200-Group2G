#!/bin/bash

#grep with argument that should be logfile ex APLL.log
attackIp= `tail -n 1 /home/student/MITM/logs/logins/$1 | colrm 1 24 | cut -d ';' -f1`
#add iptable that blocks everything
iptables --insert FORWARD --source 0.0.0.0 --destination 10.0.3.1 --protocol tcp --destination-port 6900 --jump DROP
# add iptable that allows traffic from one ip
iptables --insert FORWARD --source $attackIP --destination 10.0.3.1 --protocol tcp --destination-port 6900 --jump ACCEPT
