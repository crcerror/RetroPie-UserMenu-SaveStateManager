# RetroPie-UserMenu-SaveStateManager
SaveStateManager - This will let you delete determinated SaveStates of choosen ROM-file via runcommand UserMenu

## To install:

1. Get the script from this reop and place it to a space were no man has gone before maybe `/home/pi/RetroPie/scripts/SaveStateManager.sh`
2. We make the script executable with `chmod +x /home/pi/RetroPie/scripts/SaveStateManager.sh`
3. We create a small script in `/opt/retropie/configs/all/runcommand-menu/SaveStateManager.sh` with `nano`
     *  We just make a small one liner `/home/pi/RetroPie/scripts/SaveStateManager.sh "$3" all`
     *  You see `$3` is placed first in quotes, after this `all`represents the system and makes use of `/opt/retropie/configs/all`. We can also use `$1` to use configs for every system

## To use the script run your ROM:

1. If the grey `runcommand`box apperas, press a controller button
2. Access UserMenu and run SaveStateManger
3. Now delete your SaveStates you are fed off with B-Button
4. To have some extra options go to Extended Menu (extended version)
5. To Backup the current selected file (blue row) select Backup file

## **Picture Gallery**

