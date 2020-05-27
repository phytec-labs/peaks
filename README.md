## TL;DR QuickStart
Some words of caution:
The BSP scripts set the git config user.email and user.name values to avoid errors when using repo and bitbake. They are currently set to dummy values such as phytec-labs@phytec.com and bitbaker (name). If you were to run the BSP scripts outside of a docker container, they will most likely change your host's git settings. So be sure to run the scripts in a docker container. 

1. Install Docker on your host machine. Your host machine should be a beefy rig in order to build the BSPs quickly. Some BSPs will require more than 400GB of free space!
2. Clone this repo `git clone https://github.com/phytec-labs/bsp-docker-build-envs.git`
3. Change to the bsp environment directory `cd bsp-docker-build-envs`
4. Checkout the build environment branch you want (currently go for Rainier) `git checkout -t origin/rainier`
5. Think of a name for your docker image. We will use 'rainier' now 
6. Build the docker image ``docker build -t peaks:rainier `pwd` ``
7. Run your docker container `docker run -it peaks:rainier`
8. You will know you are in the docker container because the user will be `baker@...`
9. In the container, browse to the BSP build script you want to build `cd bsp-build-scripts/phycore-imx7/linux/`
10. Execute the build script `source PD19.1.0.sh`
11. The build will take some time...
12. Once finished you can export your built images by using any traditional method like scp, curl, etc. PHYTEC has an artifactory server and we use curl to push whatever artifacts we want up to the server and then download to whatever machine will be used to create the SD Card.


# About bsp-docker-build-envs

This project project provides Docker image files to create suitable build environments for building various PHYTEC BSPs. 

Because building BSPs can be a mountain of a task this project is codenamed 'Peaks'. Each build environment will be on a branch using a mountain peak name and each branch will have an assosciated Docker image available. Each peak will be based on an existing Linux distribution (such as Ubuntu 18.04). This is done because updating host distributions can break builds (due to various package changes). 

The build environments are, currently, not 100% unattended. You will need to have some interaction to start a build. 

## What is this for?

Building BSPs and custom distributions with Yocto can be tedious. The problem is that many BSP meta-layers require specific host packages and configurations. Having a separate clean build environment is a good way to ensure build success.

## Prerequisites

1. A beefy 'build' machine. This 'build machine' will be what you run the docker container on. In order to build efficiently (well in the temporal sense) your build system should have at least 16 "threads" (CPU architectures define 'cores' a bit differenlty so we will stick to threads), more than 8GB of RAM, a fast and reliabe internet connection, and, for some BSPs, more than 400GB of hard drive space. A SSD is perferable here as well.
2. Install Docker https://www.docker.com/get-started *Linux works best for this*



