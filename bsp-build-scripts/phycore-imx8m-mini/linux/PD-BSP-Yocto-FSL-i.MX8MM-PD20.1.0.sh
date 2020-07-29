#!/bin/bash

##########################################################
# imx8m-mini PD-BSP-Yocto-FSL-i.MX8MM-PD20.1.0.sh        # 
##########################################################


#variables - these can be changed to build different images or machines
MACHINE=phyboard-polis-imx8mm-2
IMAGE=phytec-headless-image
DISTRO=yogurt-vendor
BSP_VERSION=PD-BSP-Yocto-FSL-i.MX8MM-PD20.1.0
MANIFEST_URL=git://git.phytec.de/phy2octo
MANIFEST_BRANCH=imx8mm
MANIFEST_FILE=PD-BSP-Yocto-FSL-i.MX8MM-PD20.1.0.xml

USER_NAME=$(whoami)

bash /home/$USER_NAME/bsp-build-scripts/versions.sh

echo "*** Setting up the build environment. Your user will need sudo access!"
echo "*** Building $MACHINE $BSP_VERSION BSP."
echo "*** BSP will be built using the current user: $USER_NAME"
echo "*** The current machine target is: $MACHINE"
echo "*** The current image target is: $IMAGE"

#install the specific host packages for the build
echo "Installing host packages for build"

#fix for tzdata package not allowing unattended installation...
echo " Forcing timzeone to American EST to fix issue with tzdata package not allowing unattended install"
sudo mkdir /etc/localtime
sudo ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

export DEBIAN_FRONTEND=noninteractive
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y curl repo gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm

# set up git
git config --global user.email "phytec-labs@phytec.com"
git config --global user.name "$USER_NAME"

# set up BSP directories
echo "Setting up BSP directory structure"
export YOCTO_DIR="/home/$USER_NAME/PHYTEC_BSPs/$MANIFEST_BRANCH/$BSP_VERSION"
mkdir -p $YOCTO_DIR
mkdir -p /home/$USER_NAME/PHYTEC_BSPs/downloads

#make sure there is a bashrc file and add a YOCTO_DIR variable to make things easier later
touch /home/$USER_NAME/.bashrc

# pull BSP manifest
echo "initializing repo tool..."
cd $YOCTO_DIR
git config --global color.ui false
repo init -u $MANIFEST_URL -b $MANIFEST_BRANCH -m $MANIFEST_FILE
repo sync
export PATH="$YOCTO_DIR/sources/oe-core/bitbake/bin:$PATH"

#Apply fixups
#ISSUE-#30 https://github.com/phytec-labs/peaks/issues/30
#PD-BSP-Yocto-FSL-i.MX8MM-ALPHA2.sh fails when Host OS is using kernel > 4.15
cd /home/$USER_NAME/PHYTEC_BSPs/$MANIFEST_BRANCH/$BSP_VERSION/sources/poky 
curl -O "https://artifactory.phytec.com/artifactory/fixups/thud/poky/0001-wic-filemap-If-FIGETBSZ-iotctl-fail-failback-to-os.s.patch"
git am 0001-wic-filemap-If-FIGETBSZ-iotctl-fail-failback-to-os.s.patch

# set environment


#create the templateconf for this BSP
# meta-phytec/scrupts/init is not running properly inside the docker container.
# run excerpt from init script from meta-phytec to create bblayers. 

cd $YOCTO_DIR
ROOTDIR=$YOCTO_DIR
PHYTEC_DIR="$YOCTO_DIR/sources/meta-phytec"

# copy release notes to rootdir, if they are present in phy2octo
RELEASE_UID=$(sed -n 's:.*release_uid="\([^"]*\).*:\1:p' ${ROOTDIR}/.repo/manifest.xml)
RELEASE_NOTES="${ROOTDIR}/.repo/manifests/releasenotes/${RELEASE_UID}"
if [ -e ${RELEASE_NOTES} ]; then
    install -pm 0644 ${RELEASE_NOTES} ${ROOTDIR}/ReleaseNotes
fi

#create our build directory with standard config from PHYTEC
cd $YOCTO_DIR
TEMPLATECONF=$YOCTO_DIR/sources/meta-phytec/conf MACHINE=phyboard-polis-imx8mm-2 DISTRO=yogurt-vendor-xwayland source sources/poky/oe-init-build-env

# Modify local conf and bblayers for BSP
cd $YOCTO_DIR/build/conf \
    && sed -i '/downloads/d' $YOCTO_DIR/build/conf/local.conf \
    && echo "DL_DIR = \"/home/$USER_NAME/PHYTEC_BSPs/yocto_dl\"" >> $YOCTO_DIR/build/conf/local.conf


# add commented line in local.conf.sample (for easy acceptable NXP EULA)
echo "" >> $YOCTO_DIR/build/conf/local.conf
echo "# By building this BSP you are accepting the NXP EULA" >> $YOCTO_DIR/build/conf/local.conf
echo "# EULA can be found under ../sources/meta-freescale/EULA" >> $YOCTO_DIR/build/conf/local.conf
echo "ACCEPT_FSL_EULA = \"1\""  >> $YOCTO_DIR/build/conf/local.conf

# add BSPDIR variable in bblayers.conf.sample (needed by recipes of NXP)
sed -e '9iBSPDIR := "${OEROOT}/../.."' -i $YOCTO_DIR/build/conf/bblayers.conf

#add additional layers to bblayers.conf 
#TODO - ISSUE #21 - Fix this so it will not append everytime you run the script...

echo "" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "# Adding sublayer because of \"$RELEASE_UID\" release" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "BBLAYERS += \"\\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-browser \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-freescale-3rdparty \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-freescale-distro \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-phytec \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-qt5 \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-rauc \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-rust \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-yogurt \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-openembedded/meta-gnome \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-fsl-bsp-release/imx/meta-bsp \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-fsl-bsp-release/imx/meta-sdk \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-fsl-bsp-release/imx/meta-ml \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \${OEROOT}/../meta-freescale \\" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "  \"" >> $YOCTO_DIR/build/conf/bblayers.conf
echo "" >> $YOCTO_DIR/build/conf/bblayers.conf


#Fixup MACHINE
cd $YOCTO_DIR/build/conf \
    && sed -i 's/MACHINE ?= "UNASSIGNED"/MACHINE ?= "'"$MACHINE"'" /g' local.conf \

#Fixup Distro
cd $YOCTO_DIR/build/conf \
    && sed -i 's/DISTRO ?= "yogurt"/DISTRO ?= "'"$DISTRO"'" /g' local.conf \

#Add fix for NXP EULA
cd $YOCTO_DIR/build/conf \
    && echo "FSL_EULA_FILE=\""\${BSPDIR}/sources/meta-fsl-bsp-release/imx/EULA.txt\""" >> local.conf

#add the default build parallelization settings
echo "PARALLEL_MAKE = \""-j 16\""" >>  $YOCTO_DIR/build/conf/local.conf
echo "BB_NUMBER_THREADS = \""16\""" >>  $YOCTO_DIR/build/conf/local.conf
echo "bitbake build environment ready. Would you like to start the build?"


#build by default
BUILD='n'
YES='y'

read -t 15 -p "Enter y for yes or n for no [n]: " BUILD
BUILD=${BUILD:-n}

cd $YOCTO_DIR/build

if [[ $BUILD == 'y' ]];
then
        echo "starting the build. This may take a while..."
        # bitbake build
        machine=$MACHINE bitbake $IMAGE

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
