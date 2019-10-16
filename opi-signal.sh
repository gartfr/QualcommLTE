#!/bin/bash
# ----------------------------------------------
# Retrieve Orange Pi temperature sensor values for internal
#
# Depends on packages : 
#
# Parameters :
#
# 10/12/2019, V1.0 - Creation by Gartox
# ----------------------------------------------

# read temperature for $1
case $1 in
  # read case internal temperature
  signal)
    signal=$(mmcli -m 0 | grep signal | awk '{split($0,a," "); print a[4]}' | sed s/\%//g)
    echo "$signal"
    ;;

  # default : nothing to do
  *)              
esac 

# end
exit 0
