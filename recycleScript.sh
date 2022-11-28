#!/bin/bash

emptyMachine=`head -n 1 /home/student/HACS200-Group2G/shuffledIpAddresses`
personalMachine=`head -n 2 /home/student/HACS200-Group2G/shuffledIpAddresses | tail -n 1`
corporateMachine=`head -n 3 /home/student/HACS200-Group2G/shuffledIpAddresses | tail -n 1`
hostIP='10.0.3.1'


#Containers should already be made before deployment so that we can recycle the containers by jest redeploying their snapshots before the attacker has entered.
if [ $# -ne 3 ]
then
  echo "Argument needs to be container names in this order: <empty container> <personal container> <corporate container>"
  exit 1
else
  containerExist1=`sudo lxc-ls -f | grep -w $1 | cut -d' ' -f1`
  containerExist2=`sudo lxc-ls -f | grep -w $2 | cut -d' ' -f1`
  containerExist3=`sudo lxc-ls -f | grep -w $3 | cut -d' ' -f1`
  if [[ $containerExist1 = $1 && $containerExist2 = $2 && $containerExist3 = $3 ]]
  then
    sudo forever stopall
    sleep 2

    emptyContainerIP=`sudo lxc-ls -f | grep -w  $1 | awk '{print $5}'`
    personalContainerIP=`sudo lxc-ls -f | grep -w  $2 | awk '{print $5}'`
    corporateContainerIP=`sudo lxc-ls -f | grep -w  $3 | awk '{print $5}'`

    attackIP_E=`grep "Auto Access" /home/student/emptyContainerLog.log| tail -n 4 | head -n 1 | cut -d" " -f8 | cut -d"," -f1`
    attackIP_P=`grep "Auto Access" /home/student/personalContainer.log| tail -n 4 | head -n 1 | cut -d" " -f8 | cut -d"," -f1`
    attackIP_C=`grep "Auto Access" /home/student/personalContainer.log| tail -n 4 | head -n 1 | cut -d" " -f8 | cut -d"," -f1`

#Empty Machine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --jump DNAT --to-destination $emptyContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $emptyContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $emptyMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6900
    sudo iptables --table nat --delete POSTROUTING --source $emptyMachine --destination 0.0.0.0/0 --jump SNAT --to-source $emptyContainerIP
    sudo ip addr delete $emptyMachine/24 brd + dev "enp4s2"
    sudo lxc-stop $1
    sleep 2

#personal machine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $personalMachine --jump DNAT --to-destination $personalContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $personalContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $personalMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $personalMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6901
    sudo iptables --table nat --delete POSTROUTING --source $personalMachine --destination 0.0.0.0/0 --jump SNAT --to-source $personalContainerIP
    sudo ip addr delete $personalMachine/24 brd + dev "enp4s2"
    sudo lxc-stop $2
    sleep 2


#Corporate Machine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --jump DNAT --to-destination $corporateContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $corporateContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $corporateMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6903
    sudo ip addr delete $corporateMachine/24 brd + dev "enp4s2"
    sudo iptables --table nat --delete POSTROUTING --source $corporateMachine --destination 0.0.0.0/0 --jump SNAT --to-source $corporateContainerIP
    sudo lxc-stop $3
    sleep 2

#Snapshots of each container will already be created as well as the contents inside the container will already be created before this script will be run.
    sudo lxc-snapshot $1 -r snap0
    sleep 5

    sudo lxc-snapshot $2 -r snap0
    sleep 5

    sudo lxc-snapshot $3 -r snap0
    sleep 5

    sudo lxc-start $1
    sleep 10

    sudo lxc-start $2
    sleep 10

    sudo lxc-start $3
    sleep 10


#Sets up mitm and IP Table rules for the three containers
    /home/student/HACS200-Group2G/mitmSetupAndIPTable.sh $1 $2 $3
    sleep 5

  else
    echo "Container Does not exist"
    exit 1
  fi
fi
