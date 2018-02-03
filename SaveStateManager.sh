# cyperghosts SavestateManager 1.21 
# ROM will not show in list
# 24.01.2018
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

    # Is this entry is a ROM
    # If yes then display a Info, if no erase file and erase all Arrays with
    # related entry

    if [ "$1" = "$rom" ]; then
        dialog --cancel-label "Launch ROM" \
               --pause "This is a ROM file! I don't delete this!" 8 45 5
            [ $? = 1 ] && exit 2
      else
        dialog --yesno "I will delete following SaveState after you choose YES\n\n$1\n" 10 60
            [ $? = 0 ] && rm -f "$1" && status_array[$2-1]="" && options[$2*2-1]=""
    fi
}

func_get_savepathes

# Determinine number of Statussavegames!
# Is Array valid? (Maybe here some code magic can help me?)

    z=("$status_path/$rom_no_ext.state"*)
    [ "${z#*.state}" != "*" ] && status_array+=("${z[@]}")
    [ -f "$srm_path/$rom_no_ext.srm" ] && status_array+=("$srm_path/$rom_no_ext.srm")    
    unset z


    idx=${#status_array[@]}                             #Get Array size

# Array validity check!
    [ $idx = 0 ] && dialog --infobox "No Savestate found!" 0 0 && sleep 3 && exit

# Building Choices Array for options
# Means "counter Text counter Text"
    for (( z=0; z<$idx; z++ ))
        do
            options+=($(( $z + 1 )))
            options+=("${status_array[$z]##*/}")
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

cmd=(dialog --backtitle "cyperghosts - SaveStateManager" \
            --title "ROM: ${rom_no_ext%%(*}" \
            --cancel-label "Launch ROM" \
            --menu "Select SaveState to delete:" 18 65 16)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case $choices in
        X) exit 1 ;;
        L) exit 2 ;;
        R) exit 0 ;;
        [1-999]) func_save_del "${status_array[$choices-1]}" "$choices" ;;
        *) exit 2 ;;
    esac
done
