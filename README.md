 # Peaks Si
 
 * [Prerequisites](#prerequisites)
 * [Getting Started](#getting-started)
   * [Some words of caution:](#some-words-of-caution)
   * [Build from PHYTEC-LABS Docker Registry](#build-from-phytec-labs-docker-registry)
   * [Build your own docker image](#build-your-own-docker-image)

         
# Prerequisites

1. A beefy 'build' machine. This 'build machine' will be what you run the docker container on. In order to build efficiently (well in the temporal sense) your build system should have at least 16 "threads" (CPU architectures define 'cores' a bit differenlty so we will stick to threads), more than 8GB of RAM, a fast and reliabe internet connection, and, for some BSPs, more than 400GB of hard drive space. A SSD is perferable here as well. Most BSPs require 20-60GB of space (including the host OS). 
2. Install Docker https://www.docker.com/get-started *Linux works best for this*
3. This script has only been tested on systems running Linux + Docker and macOS + Docker. Windows has not currently been tested but it should work. 

# Getting Started
## Some words of caution
The BSP scripts set the git config user.email and user.name values to avoid errors when using repo and bitbake. They are currently set to dummy values such as phytec-labs@phytec.com and bitbaker (name). If you were to run the BSP scripts outside of a docker container, they will most likely change your host's git settings. So be sure to run the scripts in a docker container. 

## Build from PHYTEC-LABS Docker Registry
PHYTEC-LABS provides pre-build docker images on this git repo. If you don't care about creating your own local docker image from the dockerfile then you can just browse the available Docker Images here: https://hub.docker.com/orgs/phyteclabs/repositories and create a docker container.

1. Browse (or see above lists) to https://hub.docker.com/orgs/phyteclabs/repositories and explore the peaks (releases). It may be that the latest release is fine for you. Note the name of the release (e.g. 'rainier', or 'si', etc.)
2. Install docker on your host machine (this machine should be powerfull and have >200GB of free space). https://docs.docker.com/get-docker/
3. On your host machine run the docker container with the command docker run -it --name my-container-name --ulimit nofile=8192:8192 phyteclabs/chosen_peak:latest (or specific tag) (you may need to use sudo). chosen_peak should be the peaks release you want to use(rainier, si, etc.). Note we set the ulimit here because in some instances this has been seen to be very low within a docker container (so we force it here).
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
4. Checkout the build environment branch you want (currently go for Rainier) `git checkout -t origin/release/si`
5. Think of a name for your docker image. We will use 'rainier' now 
6. Build the docker image ``docker build -t si:latest `pwd` ``
7. Run your docker container `docker run -it si:latest`
8. You will know you are in the docker container because the user will be `baker@...`
9. In the container, browse to the BSP build script you want to build `cd peaks/phycore-am57xx/linux/`
10. Execute the build script `source PD20.1.0.sh`
11. The build will take some time...
12. Once finished you can export your built images by using any traditional method like scp, curl, etc. PHYTEC has an artifactory server and we use curl to push whatever artifacts we want up to the server and then download to whatever machine will be used to create the SD Card.








