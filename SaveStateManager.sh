# cyperghosts SavestateManager 1.30
#
# 22.01.18 - 1.00 Never released, used selection list
# 22.01.18 - 1.10 Introduced ROM start screen, use menu list
# 23.01.18 - 1.20 Handling of arrays improved! Better detection of SRM files
# 24.01.18 - 1.21 ROM will not show in list, this is version just detects state and SRM files, BETA released
# 24.01.18 - 1.25 Better name handling in deletion window and some code cleanup, Internal testings, never released
# 28.01.18 - 1.30 Including all testing of 1.2 branch, alle errors seems to be fixed, Try to load runcommand-onend.sh

# BETA
# 1.22 Improved handling of pathes /
# 1.23 Sanitize pathes, never released
# 
# This will let you delete determinated SaveStates of choosen ROMfile
# This script is best called into RetroPie's User Menu
# Press 'any' key during loading screen and get access to runcommand menu
# There choose 'User Menu'
#
# by cyperghost for retropie.org.uk
#
# rom=$3, is first parameter
# system=$1, is second parameter
# So for exp. ./savestate.sh  $1 $3 or ./savestate.sh $1 all

[ -z "$2" ] && echo "SaveStateManager Check: Please parse system parameter! Error!" >&2 && exit 1
[ -z "$1" ] && echo "SaveStateManager Check: Please parse rompath! Error!" >&2 && exit 1

    rom="$1"
    system="$2"
    rom_name="$(basename "$rom")"
    rom_path="$(dirname "$rom")"
    rom_no_ext="${rom_name%.*}"

    config_dir="/opt/retropie/configs/$system"
    config_file="$config_dir/retroarch.cfg"

# This sniplet is part of hiulits Boilerplate script thank you!
# This will determine path of SRM and STATUS directory
func_get_config() {
    config="$(grep -Po "(?<=^$1 = ).*" "$config_file")"
    config="${config%\"}"
    config="${config#\"}"
}

func_get_savepathes() {
    # GET SRM file location
    func_get_config "savefile_directory"
    [ "${config^^}" = "DEFAULT" ] && srm_path="$rom_path" || srm_path="$config"

    # GET STATE file location
    func_get_config "savestate_directory"
    [ "${config^^}" = "DEFAULT" ] && status_path="$rom_path" || status_path="$config"
}

func_save_del() {
    # Delete Save games
    # Is Array value already empty? If Yes then return
    [ -z "${status_array[$2-1]}" ] && return

    dialog --yesno "I will delete following SaveState after you choose YES\n\n$1\n" 10 60
    [ $? = 0 ] && rm -f "$1" && status_array[$2-1]="" && options[$2*2-1]=""
}

func_get_savepathes
# Get number of Statussavegames = Array size!
# Build Array with search path of SaveStates
# Get srm file with testcommand -f
# Is Array valid?

    z=("$status_path/$rom_no_ext.state"*)
    [ "${z#*.state}" != "*" ] && status_array+=("${z[@]}")
    [ -f "$srm_path/$rom_no_ext.srm" ] && status_array+=("$srm_path/$rom_no_ext.srm")    
    unset z

    idx=${#status_array[@]}                             #Get Array size

# Array validity check!
    [ $idx = 0 ] && dialog --title " Error " --infobox "\nNo Savestate found!\n\nExit to runcommand!\n" 7 23 && sleep 3 && exit 0

# Building Choices Array for options
# Means "counter Text counter Text"
    for (( z=0; z<$idx; z++ ))
        do
            options+=($(( $z + 1 )))
            name_state="${status_array[$z]##*/}"
            name_state="${name_state%% (*}.${name_state##*.}"
            options+=("$name_state")
        done

# Create Entry for several Exit options at last positions
    options+=("L")
    options+=("Launch ROM")
    options+=("R")
    options+=("Exit to RunCommand")
    options+=("X")
    options+=("Exit to EmulationStation")

# Build Dialog output of SaveState selection
while true
do

    cmd=(dialog --backtitle "cyperghosts SaveStateManager v1.30" \
                --title "ROM: ${rom_no_ext%% (*}.${rom_name##*.}" \
                --cancel-label "Launch ROM" \
                --menu "Select SaveState to delete:" 18 65 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case $choices in
        X) /opt/retropie/configs/all/runcommand-onend.sh && exit 1 ;;
        L) exit 2 ;;
        R) exit 0 ;;
        [1-999]) func_save_del "${status_array[$choices-1]}" "$choices" ;;
        *) exit 2 ;;
    esac
done
