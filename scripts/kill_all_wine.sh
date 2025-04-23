#!/bin/bash
pass="not_gonna_dox"

# Kill wineserver from a specific prefix too
echo $pass | sudo -S WINEPREFIX="/home/bean/BattleNet" wineserver -k 
pidsbn=$(lsof 2>/dev/null | grep "/home/bean/BattleNet/drive_c" | awk '{print $2}' | sort -u)
for pid in $pidsbn; do
  kill -9 $pid
  echo $pass | sudo -S pkill -9 -f $pid
done
echo $pass | sudo -S WINEPREFIX="/home/bean/binance" wineserver -k 
pidsbi=$(lsof 2>/dev/null | grep "/home/bean/binance/drive_c" | awk '{print $2}' | sort -u)
for pid in $pidsbi; do
  kill -9 $pid
  echo $pass | sudo -S pkill -9 -f $pid
done

# Use lsof to find all Wine-related processes using C: drive
pids=$(lsof 2>/dev/null | grep "/home/bean/.wine/drive_c" | awk '{print $2}' | sort -u)
for pid in $pids; do
  kill -9 $pid
  echo $pass | sudo -S pkill -9 -f $pid
done

# Kill wine services and known binaries
echo $pass | sudo -S pkill -9 -f wineserver 
echo $pass | sudo -S pkill -9 -f wine64 
echo $pass | sudo -S pkill -9 -f wine-preloader 
echo $pass | sudo -S pkill -9 -f wine 