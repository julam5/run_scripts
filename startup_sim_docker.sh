#!/bin/bash

NAME=Sim-Docker
IMAGE=airspacesystems/simulator:1.0.0

# remove any container with the same name as IMAGE
if [ "$(sudo docker ps -aq -f name=$NAME)" ]; then
    sudo docker stop -t 3 $NAME
    sudo docker rm $NAME
fi

echo running $IMAGE

# run new docker container with NAME
XAUTH=$HOME/.Xauthority
touch $XAUTH

xhost +local:docker

sudo docker run \
      --privileged \
      --runtime=nvidia \
      -d    \
      --name $NAME \
      --expose=2303 \
      --expose=2301 \
      --expose=6666 \
      --tty \
      --network=host \
      --env DISPLAY=$DISPLAY \
      --volume $XAUTH:/root/.Xauthority \
      --volume /etc/timezone:/etc/timezone:ro \
      --volume /etc/localtime:/etc/localtime:ro \
      --ipc host \
      $IMAGE
      
sudo docker exec -it -w /ardupilot $NAME \
    bash -c "./Tools/autotest/sim_vehicle.py -v ArduCopter --map --console"
    
    #sim_vehicle.py -v ArduCopter --map --console
