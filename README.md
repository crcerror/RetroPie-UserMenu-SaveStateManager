# RetroPie-UserMenu-SaveStateManager
SaveStateManager - This will let you delete determinated SaveStates of choosen ROM-file via runcommand UserMenu

## To install:

1. Get the script from this reop and place it to a space were no man has gone before maybe `/home/pi/RetroPie/scripts/SaveStateManager.sh`
2. We make the script executable with `chmod +x /home/pi/RetroPie/scripts/SaveStateManager.sh`
3. We create a small script in `/opt/retropie/configs/all/runcommand-menu/SaveStateManager.sh` with `nano`
3.1 We just make a small one liner `/home/pi/RetroPie/scripts/SaveStateManager.sh "$3" all`
3.2 You see `$3` is placed first in quotes, after this `all`represents the system and makes use of `/opt/retropie/configs/all`. We can also use `$1` to use configs for every system

## To use the script run your ROM:

1. If the grey `runcommand`box apperas, press a controller button
2. Access UserMenu and run SaveStateManger
3. Now delete your SaveStates you are fed off

## **Picture Gallery**

# Picture 7 and 8 are outdated! 
# Since v1.21 it's not possible to select ROMs

# 1. I want to try to delete an **Automatic** generated save file
![pic](https://up.picr.de/31617067ez.png)
# 2. I am asked if I really want to delete this file
![pic](https://up.picr.de/31617069fr.png)
# 3. As you see, the entry is faded away and can't be selected anymore
![pic](https://up.picr.de/31617070jp.png)
# 4. Now lets try to delete the SaveState Slot 10
![pic](https://up.picr.de/31617072ta.png)
# 5. Here I'm also asked to erase this file
![pic](https://up.picr.de/31617074qy.png)
# 6. Voilá the entry for SaveState Slot 10 is past now
![pic](https://up.picr.de/31617076fq.png)
# 7. What happens if I try to delete the ROM-file itself? You see the file extension? Of course you can modify the code and made also the ROM deletable. Do we need this?
![img](https://up.picr.de/31617373eu.png)
# 8. Well you can decide to return the the SaveStateManager or you can launch the ROM
![img](https://up.picr.de/31617387ia.png)
# 9. That was fun! You see you can also return to runcommand or to EmulationStation
![pic](https://up.picr.de/31617065xq.png)
