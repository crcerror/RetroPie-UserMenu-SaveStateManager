#!/bin/bash
# cyperghosts SavestateManager v2 (extended)
#
# Use dialog -checklist now

# ----- Set variables ----
readonly rom_name="$(basename "$3")"
readonly rom_path="$(dirname "$3")"
readonly rom_no_ext="${rom_name%.*}"
readonly system="$1"

#Dialog variables
readonly dl_backtitle="ROM SaveState-Manager (extended) - cyperghost"

#Backup directory
readonly backup_dir="$HOME/RetroPie/backup/$system"

#Retroarch config file locartion
config_file="/opt/retropie/configs/all/retroarch.cfg"

# ----- JOY2KEY INIT -----
# Import from RetroPie setup, uses joy2keyStart and joy2keyStop
# scriptdir is  used by joy2key

readonly JOY2KEY_SCRIPTLOC="$HOME/RetroPie-Setup/scriptmodules/helpers.sh"
readonly CONFIG=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20)
source "$JOY2KEY_SCRIPTLOC"
scriptdir="$HOME/RetroPie-Setup"

function joy2key_init()
{
    if [[ -f $JOY2KEY_SCRIPTLOC ]]; then
        joy2keyStart ${CONFIG[@]}
    else
        echo "Can't import Joy2Key Script! Error!"
        echo "Script not found in: $JOY2KEY_SCRIPTLOC"
        sleep 5; exit 0
    fi
}

# ----- Function calls  ----
# This sniplet is part of hiulits boilerplate script thank you!
# This will determine path of SRM and STATUS directory
function get_config()
{
    local config
    config="$(grep -Po "(?<=^$1 = ).*" "$config_file")"
    config="${config%\"}"
    config="${config#\"*}"
    if [[ "${config:0:1}" == "~" ]]; then
        config="${config#??}"
        config=~/"$config"
    fi
    echo "$config"
}

# GET SRM and STATE location
# SRM   = savefile_directory
# STATE = savestate_directory
function get_savepathes()
{
    local path
    path="$(get_config "$1")"
    if [[ -d "$path" ]]; then
        [[ -z "${path##*/}" ]] && path="${path%?}" # Remove last / character from pathes
    else
        path="$rom_path"
    fi
    echo "$path"
}

# Create Backup location
function create_backup_dir()
{
    local ret
    local ba_dir="$1"
    mkdir -p "$ba_dir"
    ret=$?
    if [[ $ret -ne 0 ]]; then
        dialog_box msgbox " Error! " \
                  "Backup command failed!\n'$ba_dir'not found!" 0 0
    fi
    return $ret
}

function dialog_box()
{
   dialog --title "$2" --backtitle "$dl_backtitle" \
          --$1 "$3" $4 $5
}

function extended_dialog()
{
    local file="$1"
    local file_no_ext="$2"
    local ret ret_dialog
    local cmd choices
    local options=(
                   1 "Delete all except: $(basename "$file")"
                   2 "Backup current file to '$backup_dir'"
                   3 "Copy to state0 and delete all"
                   4 "Copy to state.auto and delete all"
                   5 "Copy to state0"
                   6 "Copy to state.auto"
                   7 "Move to state0"
                   8 "Move to state.auto"
                  )

    cmd=(dialog --backtitle "$dl_backtitle" --title "SaveState: $(basename "$file")" \
                 --no-tags --defaultno \
                 --menu "There are some items available. Which one to delete?" 14 65 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    ret_dialog=$?
    case $choices in
        1) #Delete multiple files except the selected one
            multi_del_file "$file"
            ret=$?
        ;;
        2) #Backup current file
            extended_file_command "cp -p -f" "$file" "$backup_dir"
            ret=$?
        ;;
        3) #Copy to state0 and delete all
            extended_file_command "cp -p -f" "$file" "${file_no_ext}.state0"
            if [[ $? -eq 0 ]]; then
                multi_del_file "${file%.*}.state0"
                ret=$?
            else
                ret=1
            fi
        ;;
        4) #Copy to state.auto and delete all
            extended_file_command "cp -p -f" "$file" "${file_no_ext}.state.auto"
            if [[ $? -eq 0 ]]; then
                multi_del_file "${file%.*}.state.auto"
                ret=$?
            else
                ret=1
            fi
        ;;
        5) #Copy to state0
            extended_file_command "cp -p -f" "$file" "${file_no_ext}.state0"
            ret=$?
        ;;
        6) #Copy to state.auto
            extended_file_command "cp -p -f" "$file" "${file_no_ext}.state.auto"
            ret=$?
        ;;
        7) #Move to state0
            extended_file_command "mv -f" "$file" "${file_no_ext}.state0"
            ret=$?
        ;;
        8) #Move to state.auto
            extended_file_command "mv -f" "$file" "${file_no_ext}.state.auto"
            ret=$?
        ;;
    esac

    if [[ $ret_dialog -eq 1 ]]; then
        joy2keyStop #Terminate Joy2Key session
        sleep 0.5
        joy2keyStart #Default Settings!
        exit 0
    elif [[ $ret -eq 0 ]]; then
        dialog_box msgbox " Success! " "Progress finished!\nExit now!" 0 0
        sleep 1
    else
        dialog_box msgbox " Error! " "Process failed!\nExit now!" 0 0
    fi

}


function multi_del_file()
{
    local exception_file="$1"
    local i ret=0
    for i in "${saves_array[@]}"; do
        [[ "$i" == "$exception_file" ]] && continue
        extended_file_command "rm -f" "$i"
        [[ $? -eq 1 ]] && ret=1
    done
    return $ret
}

function extended_file_command()
{
    local cmd="$1"
    local file="$2"
    local dest="$3"
    local ret
    $cmd "$file" "$dest"
    ret=$?
    if [[ $ret -ne 0 ]]; then
        dialog_box msgbox " Error! " \
                          "Backup command failed!\n'$cmd \"$file\" \"$dest\"'!" 0 0
    fi
    return $ret
}

# ----- Main Call -----

#Create Backup location
create_backup_dir "$backup_dir" || exit 1

# Obtain SRM and STATE pathes
srm_file="$(get_savepathes savefile_directory)/$rom_no_ext.srm"
sav_path="$(get_savepathes savestate_directory)"

# Build Array
readarray -t saves_array < <(find "$sav_path" -name "$rom_no_ext.state*")
if [[ -f "$srm_file" ]]; then
    options=("$srm_file" "Battery Savestate" "off" "Filename: \"$(basename "$srm_file"\")")
fi

# Array validity check!
if [[ ${#options[@]} -eq 0 && ${#saves_array[@]} -eq 0 ]]; then
    dialog_box infobox " Error " \
               "\nNo Savestate found!\n\nExit to runcommand!\n" 7 23
    sleep 3
    exit 1
fi

# Building Options array for dialog input
# Remeber: Threr might be some data in already (SRM!!)
for i in "${saves_array[@]}"; do
            options+=("$i")
            options+=("SaveState: ${i##*.}   $(date -r "$i" +'%t%Y-%m-%d %H:%M:%S')")
            options+=("on")
            options+=("Filename: \"$(basename "$i")\"")
done
# Here you could unset the first array
#unset saves_array

#Init Joy2Key with special characters
sudo pkill -f joy2key
sleep 0.5 #Debounce
joy2key_init

# Selection Dialog
# tags are filenames, --separate-output is for adding newline to output
cmd=(dialog --backtitle "$dl_backtitle" --title "ROM: $rom_name" \
            --separate-output --no-tags --item-help --defaultno \
            --help-button --help-label "Extended Menu"\
            --checklist "There are some items available. Which one to delete?" 14 65 16)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

case $? in
    0)
        if [[ -n "$choices" ]]; then
            readarray -t choices <<< "$choices"
            dialog --defaultno --backtitle "$dl_backtitle" \
                   --yesno "Delete ${#choices[@]} selected files?\nThese are marked with [*]" 0 0
            if [[ $? -eq 0 ]]; then
                rm -f "${choices[@]}"
            fi
        else
            dialog_box msgbox " Error! " "No SaveState selected!" 0 0
        fi
    ;;


    2)
        choices="${choices#*\"}"
        choices="${choices%\"}"
        if [[ "${choices#*.}" == "srm" ]]; then
            #SRM file only Backup!
            extended_file_command "cp -f" "$srm_file" "$backup_dir"
            if [[ $? -eq 0 ]]; then
                dialog_box msgbox "Backup success" "Copied\n$(basename "$srm_file")\nto\n$backup_dir" 0 0
            fi
        else
            #Popup Extra Menu for savestates
            extended_dialog "${sav_path}/$choices" "${sav_path}/$rom_no_ext"
        fi
    ;;
esac

joy2keyStop #Terminate Joy2Key session
sleep 0.5
joy2keyStart #Default Settings!
