[TL;DR Show me how to build ](#building-a-bsp)

# Peaks
Welcome to the Peaks project!  

This project provides Dockerfiles to create suitable build environments for building various PHYTEC BSPs. The Docker images also include build scripts to build various BSPs. 

Because building BSPs can be a mountain of a task this project is codenamed 'Peaks' and each build environment will be on a branch using a mountain peak name. 

Each peak(branch) will be based on an existing Linux distribution (such as Ubuntu 16.04, 18.04, etc.). This is done because updating host distributions can break builds (due to various package changes, toolchain requirements, etc.).

Each branch will have a list of supported BSPs and tested machine and image types. Note that not all machines and images are tested in each build environment. You can also look below to see a table of supported/buildable BSPs in each Peak. 

This project exists to overcome the many challenges one faces when trying to recreate stable host build environments for building BSPs and distributions. Mismatched toolchains, host packages and library dependencies, just to name a few can wreak havok on builds. You can usually overcome this by using a virtual machine but those are often cumbersome. Docker containers are intended to be ephemeral (only lasting a short time). The purpose of this project is to provide a way to build BSPs the same way everytime. You should be doing your development on a different machine. But when the time comes to do a final build or test your build, this is a great way of doin that. Launch the build on a powerfull machine that has a solid internet connection, let it build, grab the results, test, and repeat if necessary. This could also be utilized in a continuous integration environment as a 'check'.  

# Supported BSPs
## Rainier (Ubuntu 16.04)
### phyCORE-i.MX7 and phyBOARD-Zeta (phyBOARD-i.MX7)
- Linux Yocto PD19.1.0


## Si (Ubuntu 18.04)
### phyCORE-AM57xx
- Linux Yocto PD20.1.0

# Building a BSP
## Quickest Way
If you would simply like to build a BSP in a docker container then all you need to do is determine which peak (release) you need and then run the docker container on your host machine.

1. Browse (or see above lists) to https://github.com/phytec-labs/peaks/packages and explore the peaks (releases). It may be that the latest release is fine for you. Note the name of the release (e.g. 'rainier', or 'si', etc.)
2. Install docker on your host machine (this machine should be powerfull and have >200GB of free space). https://docs.docker.com/get-docker/ 
3. On your host machine run the docker container with the command `docker run -it --name my-container-name --ulimit nofile=8192:8192 docker.pkg.github.com/phytec-labs/peaks/chosen_peak:latest` (you may need to use sudo). `chosen_peak` should be the peaks release you want to use(rainier, si, etc.). Note we set the ulimit here because in some instances this has been seen to be very low within a docker container (so we force it here). 
4. The docker image will download and then you will be launched into a docker container. You will know this because your command line will change to show `baker@xxxxx` as the user.
5. Browse the bsp-build-scripts folder and find the BSP that you would like to build.
6. Build the BSP by typing `source BSP-version.sh'
7. The BSP will build (this could take 2-12 hours depending on the BSP and your machine)
8. Once the BSP is finished  building you can copy build images and other files to your host machine by using the `docker cp` command *on your host machine*. You will need to find and locate the images to copy using the BSP release notes (this guide does not offer that level of detail). You can typically refer to the BSP Guide for the specific release to find the images. They are usually located in $YOCTO_DIR/build/*toolchain*/deploy/images . But that path can differ depending on the BSP, image, machine, etc. 
9. You can detach from your build container (but keep the container running) by typing hitting ctrl and then hold P and press Q `ctrl P+Q`. Keep in mind that your container is most likely using a substantial amount of resources so you might not want to keep them. You can re-attach to it at a later point (to do more builds if you want) by finding the container process ID or name - `docker ps` and then attaching to it by typing `docker attach {PID or container name}`. If you don't see your container try runnging `docker container ls -a` to see all the containers. You can remove a container (deleting all of your work!) by using `docker rm container_id`. Get the `container_id` by using `docker ps` or `docker container ls -a`. 


## Developing a Build System with Peaks

## Why?
You can use Peaks to develop your own dockerized build system. This could be integrated into your own CI, Jenkins or custom deployment system. This is a great way to avoid building different BSPs on your build server 'metal'. As well as avoiding cumbersome virtual servers and emulators.

You can also fork (or base your docker image on the release image) this repository and start to create your own build system based from here.

## Getting Started
1. Install Docker on your host machine. Your host machine should be a beefy rig in order to build the BSPs quickly. Some BSPs may require more than 400GB of free space!
2. clone or fork this repo
3. Let's assume you clone it - Clone this repo `git clone https://github.com/phytec-labs/peaks.git`
4. Change to the bsp environment directory `cd peaks`
5. Checkout the build environment branch you want (currently go for Rainier) `git checkout -t origin/release/rainier`
6. create your own branch
7. Modify whatever build scripts you want in the bsp-build-scripts folder. You could change the machine target, manifest file, etc.
8. Think of a name for your docker image. We will use 'rainier' in the current quickstart 
9. Build the docker image ``docker build -t rainier:my_tag `pwd` ``
10. Run your docker container `docker run -it rainier:my_tag`
11. You will know you are in the docker container because the user will be `baker@...`
12. In the container, browse to the BSP build script you want to build e.g. `cd bsp-build-scripts/phycore-imx7/linux/`
13. Execute the build script `source PD19.1.0.sh`
14. The build will take some time...
15. Once finished you can export your built images by using any traditional method like scp, curl, etc. PHYTEC has an artifactory server and we use curl to push whatever artifacts we want up to the server and then download to whatever machine will be used to create the SD Card. You can also use the `docker cp` command on your host machine. 

You can look at the github workflows on the master branch of this repo to see how we are automatically deploying docker images to a repository. 

# Other uses of Peaks
## Integrating Peaks With Your Development
The included scripts will build the default PHYTEC BSP and image (for the target). Most of the time these will be targeted to PHYTEC development kits. Assuming you have developed your own hardware based on a PHYTEC reference design, you will most likely have your own software as well.

### 1. Clone Peaks
The easiest way is probably to clone Peaks and start maintaining your own build environment. You can simply start with the base BSP scripts and modify them to use your code bases instead of PHYTEC's. PHYTEC generally uses repo and manifests so you can simply create your own manifest (in your own repo) with your software. You could have a manifest file that points to  your development branches, include your repo ssh key or github token in the docker image (if your development branches are on a private server) and this would alow your build container to always build based off of a specified branch (instead of PHYTEC's).

### 2. Develop your own BSP build scripts
You can use the provided BSP build scripts as a base. Modify these scripts to suit your needs, rename them, etc. You can still use the Dockerfile if you wish as a base. 

### 3. Commit your changes
Commit your changes to your branch. You can set up GitHub Actions (like we have done here) or use your own CI to automatically build a the docker image. You now have a repository that you can use to do 'clean' builds of your BSPs. If you want to go further and use this environment for actual development you can continue reading. 

## Using Peaks As Your Development Machine
It is possible to use the dockerized container as your main development machine. You will most likely want to commit the docker container to an image every so often so you don't loose your work. You can simply attach and detach from the container. One challenge will be accessing hardware but this is usually only necessary if you need to flash an SD card. To do this you can always send or copy your image files to your host machine to flash. If you are using Yocto, you can also set up a package repository inside your build machine and allow network access to the docker container to push out packages to your live hardware. 

# Having Issues?
If you have issues, questions, etc. please create them in GitHub for this project!

# Want To Contribute?
Right now this project is only supporting PHYTEC BSPs. If you would like to add support for a BSP please create an issue and we will figure out the next steps. 
