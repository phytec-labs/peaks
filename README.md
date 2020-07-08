 # Peaks 
 
 * [Prerequisites](#prerequisites)
 * [Getting Started](#getting-started)
   * [Some words of caution:](#some-words-of-caution)
   * [Build from PHYTEC-LABS Docker Registry](#build-from-phytec-labs-docker-registry)
   * [Build your own docker image](#build-your-own-docker-image)

Welcome to the Peaks project!  

This project provides Dockerfiles to create suitable build environments for building various PHYTEC BSPs. The Docker images also include build scripts to build various BSPs. 

Because building BSPs can be a mountain of a task this project is codenamed 'Peaks'. 

This project exists to overcome the many challenges one faces when trying to recreate stable host build environments for building BSPs and distributions. Mismatched toolchains, host packages and library dependencies, just to name a few can wreak havok on builds. You can usually overcome this by using a virtual machine but those are often cumbersome. Docker containers are intended to be ephemeral (only lasting a short time). The purpose of this project is to provide a way to build BSPs the same way everytime. This could also be utilized in a continuous integration environment as a 'check'.  
         
# Prerequisites

1. A beefy 'build' machine. This 'build' machine will be what you run the docker container on. In order to build efficiently (well in the temporal sense) your build system should have at least 16 "threads" (CPU architectures define 'cores' a bit differenlty so we will stick to threads), more than 8GB of RAM, a fast and reliabe internet connection, and, for some BSPs, more than 400GB of hard drive space. A SSD is perferable here as well. Most BSPs require 20-60GB of space (including the host OS). 
2. Install Docker https://www.docker.com/get-started *Linux works best for this*
3. This script has only been tested on systems running Linux + Docker and macOS + Docker. Windows has not currently been tested but it should work. 

# Getting Started
## Some words of caution
The BSP scripts set the git config user.email and user.name values to avoid errors when using repo and bitbake. They are currently set to dummy values such as phytec-labs@phytec.com and bitbaker (name). If you were to run the BSP scripts outside of a docker container, they will most likely change your host's git settings. So be sure to run the scripts in a docker container. 

## Build from PHYTEC-LABS Docker Registry
PHYTEC-LABS provides pre-build docker images on this git repo. If you don't care about creating your own local docker image from the dockerfile then you can just browse the available Docker Images here: https://hub.docker.com/orgs/phyteclabs/repositories and create a docker container.

1. Browse (or see above lists) to https://hub.docker.com/orgs/phyteclabs/repositories and explore the peaks (releases). It may be that the latest release is fine for you. You can also specify specific relases by the use of the SHA commit ID. 
2. Install docker on your host machine. https://docs.docker.com/get-docker/
3. On your host machine run the docker container with the command docker run -it --name my-container-name --ulimit nofile=8192:8192 phyteclabs/peaks:latest (you may need to use sudo). Note we set the ulimit here because in some instances this has been seen to be very low within a docker container (so we force it here). You can also pull specific releases of Peaks by using the release tag you want. 
4. The docker image will download and then you will be launched into a docker container. You will know this because your command line will change to show baker@xxxxx as the user.
5. Browse the bsp-build-scripts folder and find the BSP that you would like to build.
6. Build the BSP by typing `source BSP-version.sh'
7. The BSP will build (this could take 2-12 hours depending on the BSP and your machine)
8. Once the BSP is finished building you can copy build images and other files to your host machine by using the docker cp command on your host machine. You will need to find and locate the images to copy using the BSP release notes (this guide does not offer that level of detail). You can typicall refer to the BSP Guide for the specific release to find the images. They are usually located in $YOCTO_DIR/build/toolchain/deploy/images . But that path can differ depending on the BSP, image, machine, etc.
9. You can detach from your build container (but keep the container running) by typing hitting ctrl and then hold P and press Q ctrl P+Q. Keep in mind that your container is most likely using a substantial amount of resources so you might not want to keep them. You can re-attach to it at a later point (to do more builds if you want) by finding the container process ID or name - docker ps and then attaching to it by typing docker attach {PID or container name}. If you don't see your container try runnging docker container ls -a to see all the containers. You can remove a container (deleting all of your work!) by using docker rm container_id. Get the container_id by using docker ps or docker container ls -a.

## Build your own docker image


1. Install Docker on your host machine. https://www.docker.com/get-started *Linux works best for this*
2. Clone this repo `git clone https://github.com/phytec-labs/peaks.git`
3. Change to the bsp environment directory `cd peaks`
4. Think of a name for your docker image. We will use 'rainier' now 
5. Build the docker image ``docker build -t peaks:rainier `pwd` ``
6. Run your docker container `docker run -it peaks:rainier`
7. You will know you are in the docker container because the user will be `baker@...`
8. In the container, browse to the BSP build script you want to build `cd peaks/phycore-imx7/linux/`
9. Execute the build script `source PD19.1.0.sh`
10. The build will take some time...
11. Once finished you can export your built images by using any traditional method like scp, curl, etc. PHYTEC has an artifactory server and we use curl to push whatever artifacts we want up to the server and then download to whatever machine will be used to create the SD Card.








