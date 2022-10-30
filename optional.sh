#!/usr/bin/env bash

# Usage: source "$(optional.sh $*)"
# Options (environment variables):
#   OPTIONAL_POS_PREFIX changes the prefix of positional variables
#   OPTIONAL_DEBUG will print the temp files to stderr
#   ALLOWED will filter out any options not in that list

temp="$(mktemp)"
position=0
position_prefix="${OPTIONAL_POS_PREFIX:-POS}"

while test $# -gt 0; do
    if [[ "${1:0:2}" == "--" ]]
    then
        if echo "$1" | grep -q '='
        then
            # long with equals
            name="$(echo "${1%%=*}" | sed 's/-/_/g')"
            echo "${name:2}=\"${1#*=}\"" >> "${temp}"
        else
            # long with space
            if [[ "${2:0:1}" == '-' || -z "$2" ]]
            then
                # long flag
                echo "${1:2}=1" >> "${temp}"
            else
                # long with value
                name="$(echo "${1:2}" | sed 's/-/_/g')"
                echo "${name}=\"$2\"" >> "${temp}"
                shift
            fi
        fi
    elif [[ "${1:0:1}" == "-" ]]
    then
        # short option
        if echo "$1" | grep -q '='
        then
            # short with equals
            name="${1%%=*}"
            echo "${name:1}=\"${1#*=}\"" >> "${temp}"
        else
            if [[ "${#1}" -eq 2 ]]
            then
                # short with space
                if [[ "${2:0:1}" == '-' || -z "$2" ]]
                then
                    # short flag
                    echo "${1:1}=1" >> "${temp}"
                else
                    # short with value
                    echo "${1:1}=\"$2\"" >> "${temp}"
                    shift
                fi
            else
                # short with no space
                echo "${1:1:1}=\"${1:2}\"" >> "${temp}"
            fi
        fi
    else
        # unnamed option
        echo "${position_prefix}${position}=$1" >> "${temp}"
        position=$((position + 1))
    fi
    shift
done

if [ -n "$ALLOWED" ]
then
    grep_args=""
    for allow in $ALLOWED
    do
        grep_args="$grep_args -e ^${allow}="
    done
    temp2="$(mktemp)"
    grep $grep_args "${temp}" >> "${temp2}"
    mv "${temp2}" "${temp}"
fi

if [[ -n "$OPTIONAL_DEBUG" ]]
then
    echo "Produced file:" 1>&2
    cat "${temp}" 1>&2
    echo 1>&2
fi

echo "${temp}"
