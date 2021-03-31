#!/bin/bash

echo "path to rmount config file (usually ~/.config/rclone/rclone.conf)"
read rmount_config
echo "Enter your mount point (e.g. /media/[username]/)"
read mount_point

rmount_config=$( eval "realpath ${rmount_config}" )
mount_point=$( eval "realpath ${mount_point}" )

echo "Enter the drive's name as configured in rmount:"
drives=()

finished=false
while [ "$finished" != "true" ];
do 
    read input
    drives+=($input)

    valid=false
    while [ "$valid" != "true" ];
    do
        read -p "Do you wish to add another drive?" yn
        case $yn in
            [Yy]* ) valid=true;;
            [Nn]* ) finished=true; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
done

echo "$(eval "echo \"$(cat rclone@.service.template)\"")" > rclone@.service
sudo cp -r rclone@.service /etc/systemd/system/rclone@.service
sudo systemctl disable rclone@.service

for val in ${drives[@]}; do
    eval "sudo mkdir ${mount_point}/${val}/"
    eval "sudo chown -R $USER ${mount_point}/${val}/"
    eval "sudo systemctl enable rclone@${val}.service"
    eval "sudo systemctl start rclone@${val}.service"
    echo "Enabled service for drive ${val}"
done
