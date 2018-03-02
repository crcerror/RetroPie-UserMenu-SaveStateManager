#!/bin/bash
# SavePathFix
#
# A small tool to fix savelocation of some emulators
#
# Nothing awesome, just a bit of cosmetics
#
# 25/02/18 - Initial version
#
#
# What is needed for init? MANDOTARY!!!
# Emulatorname for case selection - Parameter 1 > $2
# ROM itself for copying files - Parameter 2 > $3
#
# Parameter 3: Optinal system $1 or all, to select place of retroarch.cfg
# if Parameter 3 is missing then 'all' is set as standard config
#

[[ -z $1 ]] && echo "SavePathFix CEr: Please parse '$2' for emulator usage! Critical Error!" >&2 && exit 1
[[ -z $2 ]] && echo "SavePathFix CEr: Please parse '$3' for status! Critical Error!" >&2 && exit 1
[[ ${1:0:1} = "/" ]] && echo "SavePathFix CEr: You likely entered a path location! Please parse '$3'! Critical Error!" >&2 && exit 1
[[ ${2:0:1} != "/" ]] && echo "SavePathFix CEr: You like did not parse '$3'! Critical Error!" >&2 && exit 1 

EMULATOR="$1"
ROM="$2"
SYSTEM="$3"

[[ -z $SYSTEM ]] && SYSTEM="all"

ROM_NAME="$(basename "$ROM")"
ROM_PATH="$(dirname "$ROM")"
ROM_NO_EXT="${ROM_NAME%.*}"

CONFIG_DIR="/opt/retropie/configs/$SYSTEM"
CONFIG_FILE="$CONFIG_DIR/retroarch.cfg"

# This will determine of savestate directory = config
# This is part of hiuilits Boilerplate script, with small modification
# if '~' is detected then expand full homepath
function get_config() {
    local config
    config="$(grep -Po "(?<=^$1 = ).*" "$CONFIG_FILE")"
    config="${config%\"}"
    config="${config#\"}"
    [[ ${config:0:1} = "~" ]] && config="${config#??}" && config=~/"$config"
    [[ -z ${config##*/} ]] && config="${config%?}"
    [[ ${config:0:1} != "/" ]] && config="$ROM_PATH"
    echo "$config"
}

# This will determine which script is curently running
# Is it 'runcommand-onend.sh' or 'runcommand-onstart.sh'
function get_runcommand() {
   local i
   local file_array=("runcommand-onend.sh" "runcommand-onstart.sh")
   for i in "${file_array[@]}"
   do
      [[ $(pgrep -f "$i") ]] && i="${i#*-on}" && echo "${i%.*}"
   done
}

# Determining file ages
function file_age() {
    echo "$(date +%s -r "$1")"
}

case "$EMULATOR" in

    lr-fbalpha2012)
        ext_matrix=("hi" "nv")
        run_command="$(get_runcommand)"
        savefile_directory="$(get_config "savefile_directory")"
        [[ $savefile_directory == $ROM_PATH ]] && break
        for ext in "${ext_matrix[@]}"
        do
            if [[ $run_command == "start" && -f "$savefile_directory/$ROM_NO_EXT.$ext" ]]
            then
                mv "$savefile_directory/$ROM_NO_EXT.$ext" "$ROM_PATH"
                echo "SavePathFix OKAY: Moved via runcommand-on$run_command.sh $savefile_directory/$ROM_NO_EXT.$ext to $ROM_PATH" >&2
            elif [[ $run_command == "end" && -f  "$ROM_PATH/$ROM_NO_EXT.$ext" ]]
            then
                mv "$ROM_PATH/$ROM_NO_EXT.$ext" "$savefile_directory"
                echo "SavePathFix OKAY: Moved via runcommand-on$run_command.sh $ROM_PATH/$ROM_NO_EXT.$ext to $savefile_directory" >&2
            else
                [[ -z $run_command ]] && echo "SavePathFix Critical: Script was not initiated via runcommand.sh call" >&2 && break
                echo "SavePathFix NoCEr: $ROM_NO_EXT.$ext not found! This is no critical error" >&2
            fi
        done
    ;;

    *)
        run_command="$(get_runcommand)"
        echo "SavePathFix NoCEr: Emulator $EMULATOR not found for file process. This is no error!" >&2
        [[ -z $run_command ]] && echo "SavePathFix Critical: Script was not initiated via runcommand.sh call" >&2 && break
        echo "SavePathFix NoCEr: Script started through runcommand-on$run_command.sh - This is no error!" >&2
    ;;

esac
