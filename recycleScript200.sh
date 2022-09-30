#!/bin/bash

emptyMachine='128.8.238.111'
personalMachine='128.8.238.120'
corporateMachine='128.8.37.121'
hostIP=`ip addr | grep inet | grep 172 | cut -d ' ' -f6 | cut -d '/' -f1`


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


#Empty Machine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --jump DNAT --to-destination $emptyContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $emptyContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $emptyMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $emptyMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6900
    sudo lxc-stop $1
    sleep 2

#personal machine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $personalMachine --jump DNAT --to-destination $personalContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $personalContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $personalMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $personalMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6900
    sudo lxc-stop $2
    sleep 2


#Corporate Machine    
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --jump DNAT --to-destination $corporateContainerIP
    sudo iptables --table nat --delete POSTROUTING --source $corporateContainerIP --destination 0.0.0.0/0 --jump SNAT --to-source $corporateMachine
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $corporateMachine --protocol tcp --dport 22 --jump DNAT --to-destination $hostIP:6900
    sudo lxc-stop $3
    sleep 2

#Snapshots of each container will already be created as well as the contents inside the container will already be created before this script will be run. 
    sudo lxc-snapshot $1 -r snap0
    sleep 2

    sudo lxc-snapshot $2 -r snap0
    sleep 2

    sudo lxc-snapshot $3 -r snap0
    sleep 2

    sudo lxc-start $1
    sleep 2

    sudo lxc-start $2
    sleep 2

    sudo lxc-start $3
    sleep 2


#Sets up mitm and IP Table rules for the three containers
    ./mitmSetupAndIPTable.sh $1 $2 $3
    sleep 5

  else
    echo "Container Does not exist"
    exit 1
  fi
fi
