#!/usr/bin/env bash

VERSIONS=(
    0401
    0502
    0606
    0701
    0801
    0902
    2005
    2006
    2102
    2202
    3001
    3002
    3103
    3201
    3307
    3309
)

DIR="$HOME/KGPE-D16/"
URL1="https://dlcdnets.asus.com/pub/ASUS/mb/SocketG34(1944)/BIOS/KGPE-D16-ASUS-"
URL2="https://dlcdnets.asus.com/pub/ASUS/mb/SocketG34(1944)/KGPE-D16/BIOS/KGPE-D16-ASUS-"
SUF=".zip"


get-versions() {
    # download all bios versions if we haven't done so already
    local input; input="$*"
    local NUM_ARCHIVES="$(c=0; for i in *; do if [[ "$i" =~ .*\.zip ]]; then c="$((c + 1))"; fi; done; echo "$c")"

    if ((NUM_ARCHIVES == 0)); then
	for VERSION in $input; do	    
	    { wget -q "${URL1}${VERSION}${SUF}" || wget -q "${URL2}${VERSION}${SUF}"; } &
	done
	wait
    fi
}

unarchive() {
    # extract all bios versions, but leave window executables
    local input; input="$*"
    for ARCHIVE in $input; do
	unzip -qq "$ARCHIVE" -x "*.EXE" 2>&- &
    done
    wait
}

_print-name() {
    # prints a name like 00.rom
    local -i n; n="$2"
    local a   ; a="$1"
    
    printf "%02d.${2}" "${1}"
}

rename() {
    # renames all bios updates like 00.rom
    local input c new
    input="$*"; c=0 
    for old_name in $input; do
	if [[ $old_name =~ .*\.ROM ]]; then
	    new_name=$(_print-name $c rom)
	    mv "$old_name" "$new_name"
	    c=$((c + 1))
	fi
    done
}

gen-patched() {
    # creates and applies patch between A.a and B, resulting in A.b
    # creates and applies patch between A.b and C, resulting in A.c
    # ...
    # creates and applies patch between A.m and N, resulting in A.n
    for ((i=0;i<14;i++)); do
	local ii old_rom new_rom patch
        ii=$((i + 1))
	old_rom=$(_print-name $i rom)
	new_rom=$(_print-name $ii rom)
	patch=$(_print-name $ii patch)
	
	bsdiff "$old_rom" "$new_rom" "$patch"
	
	if ((ii < 14)); then 
	    bspatch "$old_rom" patched-"$new_rom" "$patch"
	else
	    bspatch "$old_rom" patched-final.rom "$patch"
	fi
    done
}

(
    mkdir "$DIR" 2>&- || :
    cd "$DIR" || exit
    # cleanup directory
    rm ./*.{rom,ROM,patch} 2>&- || :
    # if no archives download them
    get-versions "${VERSIONS[@]}"    
    unarchive ./*
    rename ./*
    # incrementally patch base bios
    gen-patched
)
