#!/bin/bash
# Save Path v1.11
# Change SavePath of SRM and STATE-files
# 29.01.2018
#
# by cyperghost for retropie.org.uk
#
# This script is intended to set automatically pathes to SRM and STATE files
# therefore 3 parameters got to be pathed to this
# Parameter 1: all or $1 (for system) > This sets retroarch.cfg system specific or all
# Parameter 2: Save path of ROM Savegames maybe '/home/pi/RetroPie/savegames/$1'
# Parameter 3: Save path of SRM Savegames maybe '/home/pi/RetroPie/savegames/$1/SRM'
#
# I differ between SRM and STATE-path if SRM parameter (Parameter 3) is NOT left empty
# If parameter 3 is missing then SRM will be in the same location as STATE.
#
# Errors are logged to /dev/shm/runcommand.log
#
# Example 1: SavePath.sh all "/home/pi/RetroPie/savegames/$1" with a NES ROM
# results: SRM and STATE savepath '/home/pi/RetroPie/savegames/nes'
# retroarch.cfg in /opt/retropie/configs/all will be used!
#
# Example 2: SavePath.sh system "home/pi/Retropie/savegames/$1" with a NES ROM
# results: SRM and STATE savepath '/home/pi/RetroPie/savegames/nes'
# but retroatch.cfg in /opt/retropie/configs/nes will be used!
#
# Example 3: SavePath.sh $1 "home/pi/Retropie/savegames/$1" "home/pi/Retropie/savegames/$1/SRM"
# with a NES ROM results: STATE savepath '/home/pi/RetroPie/savegames/nes'
# and SRM will be saved to '/home/pi/RetroPie/savegames/nes/SRM'
# but retroatch.cfg in /opt/retropie/configs/nes will be used!
#
# Example 4: SavePath.sh all "home/pi/Retropie/savegames/$1" "home/pi/Retropie/savegames/$1/SRM"
# with a NES ROM results: STATE savepath '/home/pi/RetroPie/savegames/nes'
# and SRM will be saved to '/home/pi/RetroPie/savegames/nes/SRM'
# and retroatch.cfg in /opt/retropie/configs/all will be used!
#
# Example 5: SavePath.sh all "home/pi/Retropie/savegames" with all ROMs 
# results: STATE savepath '/home/pi/RetroPie/savegames/'
# and SRM will be saved to '/home/pi/RetroPie/savegames/'
# retroatch.cfg in /opt/retropie/configs/all will be used!
# All ROMs of all systems will be saved there
#
# create or uncomment keys for 'savefile_directory = ""' and 
# 'savestate_directory = ""' by your own!
# I don't want to mess up anything with your config!

[ -z "$1" ] && echo "SavePath Check: Please parse 'all' or '$1'! Error!" >&2 && exit 1
[ -z "$2" ] && echo "SavePath Check: Please parse full path for save location!" >&2 && exit 1
[ "${1:0:1}" = "/" ] && echo "SavePath Check: You likely entered a path location! Please parse 'all' or '$1'! Error!" >&2 && exit 1

    state_path="$2"
    srm_path="$3"
    [ -z "$3" ] && srm_path="$2"
      
    config_dir="/opt/retropie/configs/$1"
    config_file="$config_dir/retroarch.cfg"

# Get Config State, if there is an error then exit
func_get_config() {
    config="$(grep -Po "(?<=^$1 = ).*" "$config_file")"

    # Check for string config if it's empty then exit
    # else remove quotation marks
    [ -z "$config" ] && echo "SavePath Check: config Key: $1 in $config_file not found! Exit!" >&2 && exit 1
    config="${config%\"}"
    config="${config#\"}"

    # This is tricky!
    # The ~ is a shortage to the HOME directory
    # RetroPie is used to save the home dir as '~/RetroPie...'
    # So I check for presence, remove it and expand it again
    [ "${config:0:1}" = "~" ] && config="${config#??}" && config=~/"$config"
}

# Write to config
func_set_config() {
    sed -i "s|^\($1\s*=\s*\).*|\1\"$2\"|" "$config_file"
#    echo "\"$1\" set to \"$2\"."
}

# ---------------------------  M  A  I  N  ---------------------------

    [ -z "${state_path##*/}" ] && state_path="${state_path%?}"     # Remove last / character from pathes
    [ "${state_path:0:1}" != "/" ] && echo "SavePath Check: No valid path for save STATE location entered!" >&2 && exit 1
    [ -z "${srm_path##*/}" ] && srm_path="${srm_path%?}"           # Remove last / character from pathes
    [ "${srm_path:0:1}" != "/" ] && echo "SavePath Check: No valid path for save SRM location entered!" >&2 && exit 1

    func_get_config "savefile_directory"
        if [ "$config" != "$srm_path" ]; then
            func_set_config "savefile_directory" "$srm_path"
            mkdir -p "$srm_path"
        fi

    func_get_config "savestate_directory"
        if [ "$config" != "$state_path" ]; then
            func_set_config "savestate_directory" "$state_path"
            mkdir -p "$state_path"
        fi
