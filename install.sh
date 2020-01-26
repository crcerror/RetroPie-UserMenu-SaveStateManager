#!/bin/bash
#Check root 
if [[ $EUID -eq 0 ]]; then
    echo "Do not use root user"
    exit
fi
clear
echo "Starting Install the scripts"
#Create runcommand-menu dir
RC_DIR="/opt/retropie/configs/all/runcommand-menu"
mkdir -p "$RC_DIR"
[[ $? -eq 0 ]] || exit 
echo "Created Directory: $RCDIR"

#Man my mistake with the rename!!
pushd "$RC_DIR"
wget -q --show-progress "https://raw.githubusercontent.com/crcerror/RetroPie-UserMenu-SaveStateManager/master/SafeState-Manager%20v2%20(extended).sh" -O "SaveState-Manager v2 (extended).sh"
wget -q --show-progress "https://raw.githubusercontent.com/crcerror/RetroPie-UserMenu-SaveStateManager/master/SafeState-Manager%20v2%20(light).sh" -O "SaveState-Manager v2 (light).sh"
popd 
echo
echo "Downloaded light and extended script versions!"
echo
echo "That's it!"
echo "Now select from USER-Menu if you press any button during loading the ROM"
echo "Goodbye -your cyperghost"
