#!/bin/bash
pass=$(zenity --password --title="Enter root Password")
echo $pass | sudo -S bash $HOME/scripts/performance_mode.sh
echo $pass | sudo -S bash $HOME/scripts/prevent-sleep.sh
