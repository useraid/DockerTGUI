#!/bin/bash

if ! command -v dialog &> /dev/null
then
    function get_distro() {
        if [[ -f /etc/os-release ]]
        then
            source /etc/os-release
            echo $ID
        else
            uname
        fi
    }
    case $(get_distro) in 
        fedora)
            sudo dnf install dialog
            ;;
        ubuntu)
            sudo apt-get -y install dialog
            ;;
        debian)
            sudo apt-get -y install dialog
            ;;
    esac   
fi

if ! command -v docker &> /dev/null
then
    if dialog --yesno "Docker is not installed. Do you want to install it?" 10 100; then
        curl -sSL https://get.docker.com/ | sh
        sudo usermod -aG docker $USER
        newgrp docker
    else
        dialog --msgbox "You need Docker to be installed to create containers." 10 100
        clear
        exit
    fi
fi


image=$(dialog --title "Container creation" --inputbox "Enter image : " 10 100 3>&1 1>&2 2>&3)
name=$(dialog --title "Container creation" --inputbox "Enter container name : " 10 100 3>&1 1>&2 2>&3)
host_port=$(dialog --title "Container creation" --inputbox "Enter host port : " 10 100 3>&1 1>&2 2>&3)
container_port=$(dialog --title "Container creation" --inputbox "Enter container port : " 10 100 3>&1 1>&2 2>&3)
host_volume=$(dialog --title "Container creation" --inputbox "Enter host volume (Leave empty to not bind volume) : " 10 100 3>&1 1>&2 2>&3)
container_volume=$(dialog --title "Container creation" --inputbox "Enter container volume (Leave empty to not bind volume) : " 10 100 3>&1 1>&2 2>&3)

options=$(dialog --separate-output --checklist "Choose options" 10 35 5 \
  "1" "Detached Mode" ON \
  "2" "Delete Container after stopping" OFF \
   3>&1 1>&2 2>&3)

if [ -z "$name" ]
then
      container_name=""
else
      container_name="--name ${name}"
fi

if [ -z "$host_volume" ] || [ -z "$container_volume" ]
then
      volume=""
else
      volume="-v $host_volume:$container_volume"
fi


if [ -z "$options" ]; then
  echo "No option was selected (user hit Cancel or unselected all options)"
else
  for options in $options; do
    case "$options" in
    "1")
        detached="-d"
      ;;
    "2")
        removal="--rm"
      ;;
    *)
      exit
      ;;
    esac
  done
fi

clear
docker run ${removal} ${detached} ${container_name} -p ${host_port}:${container_port} ${volume} ${image}