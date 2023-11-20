#!/usr/bin/env bash

if [[ $EUID == 0 ]] || [[ $UID == 0 ]]; then
    guix_locs=(
	"/gnu"
	"/var/guix"
	"/etc/guix"
	"$HOME/.profile/guix"
	"/var/roothome/.config/guix"
	"/etc/profile.d/guix.sh"
	"/etc/systemd/system/gnu-store.mount"
	"/etc/systems/system/guix-daemon.service"
    )
    
    guix_builders=( $(seq -w 1 $(( $(grep -c processor /proc/cpuinfo) + 2 )) | xargs -I {} echo guixbuilder{}) )

    systemctl stop guix-daemon.service 2>/dev/null
    systemctl disable gnu-store.mount 2>/dev/null
    echo "${guix_locs[@]}" | xargs rm -vrf {}
    for user in "${guix_builders[@]}"; do userdel --force --remove "$user" & done
else
    echo "$0 must be run as root!!!"
fi
