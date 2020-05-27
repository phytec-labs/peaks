# Peaks

Welcome to the Peaks project!  

This project provides Docker images and scripts to create suitable build environments for building various PHYTEC BSPs. 

Because building BSPs can be a mountain of a task this project is codenamed 'Peaks' and each build environment will be on a branch using a mountain peak name. 

Each peak will be based on an existing Linux distribution (such as Ubuntu 16.04, 18.04, etc.). This is done because updating host distributions can break builds (due to various package changes).

Each branch will have a list of supported BSPs and tested machine and image types. Note that not all machines and images are tested in each build environment. 

## How to get started?
### Quickest Way
If you would simply like to build a BSP in a docker container then all you need to do is determine which release you need and then run the docker container on your host machine.
1. Browse to https://github.com/phytec-labs/peaks/packages and examine the releases. It may be that the latest release is fine for you. Note the name of the release (e.g. 'rainier', or 'si', etc.)
2. Install docker on your host machine (this machine should be powerfull an have >200GB of free space)
3. On your host machine run the docker container with the command `docker run -it docker.pkg.github.com/phytec-labs/peaks/peaks:rainier` (you may need to use sudo)
4. Image will download and then you will be launched into a docker container. You will know this because your command line will change to show `baker@xxxxx` as the user.
5. Browse the bsp-build-scripts folder for the BSP that you would like to build.
6. Build the BSP by typing `source BSP-version.sh'
7. The BSP will build (this could take 2-12 hours depending on the BSP and your machine)
8. Once the BSP is finished you can copy build images and other files to your host machine by using the `docker cp` command *on your host machine*.
9. **The Docker container is volatile! If you 'exit' or close your container your work will be lost. You can 'commit' the state of the container to your local image. **

## Developing with Peaks
You can also fork (or base your docker image on the release image) this repository and start to create your own build system based from here. To do this follow these steps:
1. Install Docker on your host machine. Your host machine should be a beefy rig in order to build the BSPs quickly. Some BSPs will require more than 400GB of free space!
2. clone or fork this repo
3. Let's assume you clone it - Clone this repo `git clone https://github.com/phytec-labs/peaks.git`
4. Change to the bsp environment directory `cd peaks`
5. Checkout the build environment branch you want (currently go for Rainier) `git checkout -t origin/rainier`
6. create your own branch
7. Modify whatever build scripts you want in the bsp-build-scripts folder
8. Think of a name for your docker image. We will use 'rainier' now 
9. Build the docker image ``docker build -t peaks:rainier `pwd` ``
10. Run your docker container `docker run -it peaks:rainier`
11. You will know you are in the docker container because the user will be `baker@...`
12. In the container, browse to the BSP build script you want to build e.g. `cd bsp-build-scripts/phycore-imx7/linux/`
13. Execute the build script `source PD19.1.0.sh`
14. The build will take some time...
15. Once finished you can export your built images by using any traditional method like scp, curl, etc. PHYTEC has an artifactory server and we use curl to push whatever artifacts we want up to the server and then download to whatever machine will be used to create the SD Card. You can also use the `docker cp` command on your host machine. 

## Issues?

If you have issues, questions, etc. please create them in GitHub for this project!


