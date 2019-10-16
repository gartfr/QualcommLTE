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
  internal)
    rawtemp=$(cat /sys/devices/virtual/thermal/thermal_zone0/temp)
    temp=$((rawtemp/1000))
    echo "$temp"
    ;;

  # default : nothing to do
  *)              
esac 

# end
exit 0
