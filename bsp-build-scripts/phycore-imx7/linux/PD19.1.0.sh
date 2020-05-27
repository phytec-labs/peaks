#!/bin/bash
#PD19.1.0.sh

#########################################
#           iMX7  PD19.1.0.sh           # 
#########################################


#variables - these can be changed to build different images or machines
MACHINE=imx7d-phyboard-zeta-004
IMAGE=fsl-image-validation-imx
BSP_VERSION=PD19.1.0
MANIFEST_URL=https://stash.phytec.com/scm/pub/manifests-phytec.git
MANIFEST_BRANCH=imx7
MANIFEST_FILE=BSP-Yocto-FSL-iMX7-PD19.1.0.xml

USER_NAME=$(whoami)

bash /home/$USER_NAME/bsp-build-scripts/versions.sh

echo "*** Setting up the build environment. Your user will need sudo access!"
echo "*** Building iMX7 $BSP_VERSION BSP."
echo "*** BSP will be built using the current user: $USER_NAME"
echo "*** The current machine target is: $MACHINE"
echo "*** The current image target is: $IMAGE"

#install the specific host packages for the build
echo "Installing host packages for build"

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libx11-dev x11proto-core-dev vim openssh-client curl ssh sudo git repo python3 build-essential python diffstat texinfo gawk chrpath dos2unix wget unzip socat doxygen libc6-dev libncurses5:i386 libstdc++6:i386 zlib1g:i386 lib32stdc++6 lib32ncurses5 lib32z1 libc6-dev-i386 cpio gcc-multilib git-core xz-utils

# set up git
git config --global user.email "phytec-labs@phytec.com"
git config --global user.name "$USER_NAME"

# set up BSP directories
echo "Setting up BSP directory structure"
mkdir /home/$USER_NAME/PHYTEC_BSPs
cd /home/$USER_NAME/PHYTEC_BSPs
mkdir -p yocto_imx7
mkdir -p yocto_dl
YOCTO_DIR="/home/$USER_NAME/PHYTEC_BSPs/yocto_imx7"

#make sure there is a bashrc file and add a YOCTO_DIR variable to make things easier later
touch /home/$USER_NAME/.bashrc
export YOCTO_DIR="/home/$USER_NAME/PHYTEC_BSPs/yocto_imx7"

# repo project
echo "initializing repo tool..."
cd $YOCTO_DIR
git config --global color.ui false
repo init -u $MANIFEST_URL -b $MANIFEST_BRANCH -m $MANIFEST_FILE
repo sync
export PATH="$YOCTO_DIR/sources/oe-core/bitbake/bin:$PATH"

# set environment
cd $YOCTO_DIR && TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-fsl/conf source sources/poky/oe-init-build-env build

# change download location & machine
# accept EULA for NXP/FSL BSP
cd $YOCTO_DIR/build/conf \
    && echo 'ACCEPT_FSL_EULA = "1"' >> $YOCTO_DIR/build/conf/local.conf \
    && sed -i '/downloads/d' $YOCTO_DIR/build/conf/local.conf \
    && echo "DL_DIR = \"/home/$USER_NAME/PHYTEC_BSPs/yocto_dl\"" >> $YOCTO_DIR/build/conf/local.conf

#remove the default build parallelization settings
cd $YOCTO_DIR/build/conf \
	&& sed -i 's/PARALLEL_MAKE = "-j 4"/ /g' local.conf \
	&& sed -i 's/BB_NUMBER_THREADS = "4"/ /g' local.conf

echo "bitbake build environment ready. Would you like to start the build? Build will start automatically in 15 seconds"


#build by default
BUILD='y'
YES='y'

read -t 15 -p "Enter y for yes or n for no [y]: " BUILD
BUILD=${BUILD:-y}

if [[ $BUILD == 'y' ]];
then
	echo "starting the build. This may take a while..."
	# bitbake build
	cd $YOCTO_DIR/build \
    	&& machine=$MACHINE bitbake $IMAGE

echo -e "\n\n\n\nYour build is complete. If build was sucessfull your images should be in build/tmp/deploy/images \n\n\n"
echo -e "\n\nIf you would like to build later you can re-initialize the bitbake environment by entering \n
cd $YOCTO_DIR && TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-fsl/conf source sources/poky/oe-init-build-env build \n
And then entering your bitbake command. The bitbake command used for this build was: \n
cd $YOCTO_DIR/build && machine=$MACHINE bitbake $IMAGE \n"
fi
echo -e "\n\n If you would like to build later you can re-initialize the bitbake environment by entering \n
cd $YOCTO_DIR && TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-fsl/conf source sources/poky/oe-init-build-env build \n
And then entering your bitbake command. The bitbake command used for this build was: \n
cd $YOCTO_DIR/build && machine=$MACHINE bitbake $IMAGE \n"


