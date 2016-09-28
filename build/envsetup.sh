# Cyanide functions that extend build/envsetup.sh

function cyanide_device_combos() {
    local device

    T="$(gettop)"
    list_file="${T}/vendor/cyanide/cyanide.devices"
    variant="userdebug"

    if [[ $1 ]]
    then
        if [[ $2 ]]
        then
            list_file="$1"
            variant="$2"
        else
            if [[ ${VARIANT_CHOICES[@]} =~ (^| )$1($| ) ]]
            then
                variant="$1"
            else
                list_file="$1"
            fi
        fi
    fi

    if [[ ! -f "${list_file}" ]]
    then
        echo "unable to find device list: ${list_file}"
        list_file="${T}/vendor/cyanide/cyanide.devices"
        echo "defaulting device list file to: ${list_file}"
    fi

    while IFS= read -r device
    do
        add_lunch_combo "cyanide_${device}-${variant}"
    done < "${list_file}"
}
