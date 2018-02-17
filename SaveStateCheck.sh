# SaveStateCheck 1.1 (for status and SRM files data)
# by cyperghost
#
# Parameter 1: RomPath parsed by RetroPie as $3 -- Mandatory!
# Parameter 2: Is system name parsed by RetroPie as $1 -- Mandatory!
# Parameter 3: How states are displayed. Choose between 'light' and 'window' (default)
# Parameter 4: How long states are diplayed. Default is 3 seconds
#
# So for exp. ./savestate.sh  "$3" $1 5 or ./savestate.sh "$1" all light 5 or ./savestate.sh "$3" $1
#
# Precheck if parameters are setted, if not we exit with error

[ -z "$1" ] && echo "SaveState Check: Please parse rompath! Error!" >&2 && exit 1
[ -z "$2" ] && echo "SaveState Check: Please parse system parameter! Error!" >&2 && exit 1


    rom="$1"
    system="$2"
    dialog="$3"
    pause="$4"

    [ -z "$3" ] && dialog="windows"
    [ -z "$4" ] && pause=3

    rom_name="$(basename "$rom")"
    rom_path="$(dirname "$rom")"
    rom_no_ext="${rom_name%.*}"

    config_dir="/opt/retropie/configs/$system"
    config_file="$config_dir/retroarch.cfg"

# This will determine path of SRM and STATUS directory
# This is part of hiuilits Boilerplate script, with small modification
# if '~' is detected then expand full homepath
func_get_config() {
    config="$(grep -Po "(?<=^$1 = ).*" "$config_file")"
    config="${config%\"}"
    config="${config#\"}"
    [ "${config:0:1}" = "~" ] && config="${config#??}" && config=~/"$config"
}

# This will check extracted pathes and make them conform by removing last slash
func_get_savepathes() {
    # GET SRM file location
    func_get_config "savefile_directory"
    [ -z "${config##*/}" ] && config="${config%?}"
    [ "${config:0:1}" = "/" ]  && srm_path="$config" || srm_path="$rom_path"

    # GET STATE file location
    func_get_config "savestate_directory"
    [ -z "${config##*/}" ] && config="${config%?}"
    [ "${config:0:1}" = "/" ] && status_path="$config" || status_path="$rom_path"
}


func_get_savepathes
# Get number of Statussavegames = Array size!
# Build Array with search path of SaveStates
# Get srm file with testcommand -f
# Is Array valid?

    z=("$status_path/$rom_no_ext.state"*)
    [ "${z#*.state}" != "*" ] && status_array+=("${z[@]}")
    unset z

    idx=${#status_array[@]}                             #Get Array size

# Build messages
# Select if array entry contains '.auto'
# Add SRM savestate to array if it is a valid file
    z=0
        while [ $z -lt $idx ]
        do
            status_array[$z]="${status_array[$z]#*.state}"
            [ "${status_array[$z]}" != ".auto" ] && number=$(printf "%03d" ${status_array[$z]}) || number="ASv"
            status_array[$z]="\nGame Slot $number found"
            z=$[$z+1]
        done

        [ -f "$srm_path/$rom_no_ext.srm" ] && status_array+=("\nSRM Savestate found")

# Check array, if it is zero then exit
    [ ${#status_array[@]} = 0 ] && exit

# Better looking ROMnames
rom_name="${rom_name%%[*}"
rom_name="${rom_name%%(*}"

# Building Screenoutput
case "$dialog" in
    "window") dialog --title "SaveStateCheck" --infobox \
              "Loaded ROM:\n$rom_name\n\nConsits of $idx SaveStates\n${status_array[*]}" 17 50
              ;;

    "light")  echo -e "$idx SaveStates found:\n-------------------${status_array[*]}" 
              ;;
esac

# Show message for $pause seconds (default=3)
sleep $pause
