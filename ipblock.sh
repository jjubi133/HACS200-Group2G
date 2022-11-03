#!/bin/bash

# argument 1 should be log name ex: APLL.log
tail -1 $1 | colrm 1 24 | cut -d ';' -f 1

# add iptable rule that blocks all other traffic

# add iptable rule that allows traffic from that ip

