#!/bin/bash

shuf /home/student/HACS200-Group2G/ipAdresses > /home/student/HACS200-Group2G/shuffledIpAddresses
emptyMachine=`head -n 1 /home/student/HACS200-Group2G/shuffledIpAddresses`
personalMachine=`head -n 2 /home/student/HACS200-Group2G/shuffledIpAddresses | tail -n 1`
corporateMachine=`head -n 3 /home/student/HACS200-Group2G/shuffledIpAddresses | tail -n 1`
hostIP='10.0.3.1'
date=`/usr/bin/date`



if [ $# -ne 3 ]
then
  echo "Argument needs to be container names in this order: <empty container> <personal container> <corporate container>"
  exit 1
else

	emptyContainerIP=`sudo lxc-ls -f | grep -w  $1 | awk '{print $5}'`
	personalContainerIP=`sudo lxc-ls -f | grep -w  $2 | awk '{print $5}'`
	corporateContainerIP=`sudo lxc-ls -f | grep -w  $3 | awk '{print $5}'`
  /usr/bin/touch /home/student/emptyLogs/"emptyContainerLog$date.log"
  sleep 1
  /usr/bin/touch /home/student/personalLogs/"personalContainer$date.log"
  sleep 1
  /usr/bin/touch /home/student/corporateLogs/"corporateContainer$date.log"
  sleep 1

  sleep 3

	sudo sysctl -w net.ipv4.conf.all.route_localnet=1
  sleep 5
	sudo forever -l /home/student/emptyLogs/"emptyContainerLog$date.log" -a start /home/student/MITM/mitm.js -n $1 -i $emptyContainerIP -p 6900 --auto-access --auto-access-fixed 1 --debug --mitm-ip $hostIP
	sleep 5
  sudo ip link set dev enp4s2 up
	sudo ip addr add $emptyMachine/24 brd + dev "enp4s2"

	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --jump DNAT --to-destination $emptyContainerIP
	sudo iptables --table nat --insert POSTROUTING --source $emptyContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $emptyMachine
	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6900
  sudo iptables --table nat --insert POSTROUTING --source $emptyMachine --destination 0.0.0.0/0 --jump SNAT --to-source $emptyContainerIP

	sudo sysctl -w net.ipv4.conf.all.route_localnet=1
	sleep 5
  sudo forever -l /home/student/personalLogs/"personalContainer$date.log" -a start /home/student/MITM/mitm.js -n $2 -i $personalContainerIP -p 6901 --auto-access --auto-access-fixed 1 --debug --mitm-ip $hostIP
	sleep 5
  sudo ip addr add $personalMachine/24 brd + dev "enp4s2"

	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $personalMachine --jump DNAT --to-destination $personalContainerIP
	sudo iptables --table nat --insert POSTROUTING --source $personalContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $personalMachine
	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $personalMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6901
  sudo iptables --table nat --insert POSTROUTING --source $personalMachine --destination 0.0.0.0/0 --jump SNAT --to-source $personalContainerIP

	sudo sysctl -w net.ipv4.conf.all.route_localnet=1
	sleep 5
  sudo forever -l /home/student/corporateLogs/"corporateContainer$date.log" -a start /home/student/MITM/mitm.js -n $3 -i $corporateContainerIP -p 6903 --auto-access --auto-access-fixed 1 --debug --mitm-ip $hostIP
	sleep 5
  sudo ip addr add $corporateMachine/24 brd + dev "enp4s2"

	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --jump DNAT --to-destination $corporateContainerIP
	sudo iptables --table nat --insert POSTROUTING --source $corporateContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $corporateMachine
	sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6903
  sudo iptables --table nat --insert POSTROUTING --source $corporateMachine --destination 0.0.0.0/0 --jump SNAT --to-source $corporateContainerIP

fi

exit 0
