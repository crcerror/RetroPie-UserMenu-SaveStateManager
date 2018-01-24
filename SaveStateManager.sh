# Savestate Manager 1.0
# This will let you delete determinated SaveStates of choosen ROMfile
# This script is best called into RetroPie's User Menu
# Press 'any' key during loading screen and get access to runcommand menu
# There choose 'User Menu'
#
# by cyperghost
#
# rom=$3, is first parameter
# system=$1, is second parameter
# So for exp. ./savestate.sh  $1 $3 or ./savestate.sh $1 all

[ -z $2 ] && echo "SaveState Check: Please parse system parameter! Error!" >&2 && exit 1
[ -z $1 ] && echo "SaveState Check: Please parse rompath! Error!" >&2 && exit 1

    rom="$1"
    sytem="$2"
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
    if [ "$1" = "$rom_name" ]; then
        dialog --infobox "This a ROM file\nI don't delete this!" 0 0 && sleep 5
     else
        echo "File delteted"
    fi
}

func_get_savepathes

# Determinine number of Statussavegames!
# Is Array valid? (Maybe here some code magic can help me?)
    status_array=("$status_path/$rom_no_ext."*)         #Build Array
    idx=${#status_array[@]}                             #Get Array size

# Array validity check!
    [ $idx = 1 ] && dialog --infobox "No Savestate found" 0 0 && sleep 3 && exit

# Building Choices Array for options
# Means "counter Text counter Text"
    for (( z=0; z<$idx; z++ ))
        do
            options[$z*3]=$(( $z + 1 ))
            options[$z*3+1]="${status_array[$z]##*/}"
            options[$z*3+2]="off"
        done

cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

for choice in $choices
do
    case $choice in
        *) func_save_del "${options[$choice*3-2]}" && sleep 1
    esac
done