#!/bin/bash
#PD20.1.0.sh

#########################################
# am57xx PD-BSP-Yocto-TISDK-AM57xx-PD20.1.0          # 
#########################################


#variables - these can be changed to build different images or machines
MACHINE=am57xx-phycore-kit
IMAGE=arago-core-tisdk-bundle
BSP_VERSION=PD-BSP-Yocto-TISDK-AM57xx-PD20.1.0
MANIFEST_URL=https://stash.phytec.com/scm/pub/manifests-phytec.git
MANIFEST_BRANCH=am57xx
MANIFEST_FILE=PD20.1.0.xml

USER_NAME=$(whoami)

bash /home/$USER_NAME/bsp-build-scripts/versions.sh

echo "*** Setting up the build environment. Your user will need sudo access!"
echo "*** Building am57xx $BSP_VERSION BSP."
echo "*** BSP will be built using the current user: $USER_NAME"
echo "*** The current machine target is: $MACHINE"
echo "*** The current image target is: $IMAGE"

#install the specific host packages for the build
echo "Installing host packages for build"

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y git curl cpio repo build-essential python python3 diffstat texinfo gawk chrpath dos2unix wget unzip socat doxygen gcc-multilib g++-multilib bison flex lzop u-boot-tools

# set up git
git config --global user.email "phytec-labs@phytec.com"
git config --global user.name "$USER_NAME"

# set up BSP directories
echo "Setting up BSP directory structure"
mkdir -p /home/$USER_NAME/PHYTEC_BSPs/downloads
mkdir -p /home/$USER_NAME/PHYTEC_BSPs/$MANIFEST_BRANCH/$BSP_VERSION
cd /home/$USER_NAME/PHYTEC_BSPs/$MANIFEST_BRANCH/$BSP_VERSION
YOCTO_DIR="/home/$USER_NAME/PHYTEC_BSPs/$MANIFEST_BRANCH/$BSP_VERSION"


#set up additional linaro toolchain for TI
mkdir toolchain
cd toolchain
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz
tar -Jxvf gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz -C $YOCTO_DIR/toolchain
rm gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz
cd $YOCTO_DIR



#make sure there is a bashrc file and add a YOCTO_DIR variable to make things easier later
touch /home/$USER_NAME/.bashrc

# repo project
echo "initializing repo tool..."
cd $YOCTO_DIR
git config --global color.ui false
repo init -u $MANIFEST_URL -b $MANIFEST_BRANCH -m $MANIFEST_FILE
repo sync
export PATH="$YOCTO_DIR/sources/oe-core/bitbake/bin:$PATH"

# set environment
cd $YOCTO_DIR
TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-ti/conf MACHINE=$MACHINE source sources/oe-core/oe-init-build-env build

# change download location & machine
# accept EULA for NXP/FSL BSP
cd $YOCTO_DIR/build/conf \
    && echo "TOOLCHAIN_BASE = \"$YOCTO_DIR/toolchain\"" >> $YOCTO_DIR/build/conf/local.conf \
    && sed -i '/downloads/d' $YOCTO_DIR/build/conf/local.conf \
    && echo "DL_DIR = \"/home/$USER_NAME/PHYTEC_BSPs/downloads\"" >> $YOCTO_DIR/build/conf/local.conf

#remove the default build parallelization settings
cd $YOCTO_DIR/build/conf \
        && sed -i 's/PARALLEL_MAKE = "-j 4"/PARALLEL_MAKE = "-j 16"/g' local.conf \
        && sed -i 's/BB_NUMBER_THREADS = "4"/BB_NUMBER_THREADS = "16"/g' local.conf

#increase open file descriptors for the build

ulimit -n 8192

echo "bitbake build environment ready. Would you like to start the build?"


#do not build by default
BUILD='n'
YES='y'

read -t 15 -p "Enter y for yes or n for no [n]: " BUILD
BUILD=${BUILD:-n}

if [[ $BUILD == 'y' ]];
then
        echo "starting the build. This may take a while..."
        # bitbake build
        cd $YOCTO_DIR/build \
        && machine=$MACHINE bitbake $IMAGE

echo -e "\n\n\n\nYour build is complete. If build was sucessfull your images should be in build/tmp/deploy/images \n\n\n"
echo -e "\n\nIf you would like to build later you can re-initialize the bitbake environment by entering \n
cd $YOCTO_DIR && TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-fsl/conf source sources/poky/oe-init-build-env build \n
And then entering your bitbake command. \n\n\n The bitbake command used for this build was: \n
cd $YOCTO_DIR/build && machine=$MACHINE bitbake $IMAGE \n"
else
    echo -e "\n\n If you would like to build later you can re-initialize the bitbake environment by entering \n
cd $YOCTO_DIR && TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/meta-phytec-fsl/conf source sources/poky/oe-init-build-env build \n
And then entering your bitbake command. \n\n\n The bitbake command used for this build was: \n
cd $YOCTO_DIR/build && machine=$MACHINE bitbake $IMAGE \n"
fi