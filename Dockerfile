#The MIT License (MIT)

#Copyright (c) 2020 PHYTEC America LLC

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without
#restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom 
#the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE 
#AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#This Dockerfile is refactored from an original work by Grace Hwang ghwang@phytec.com
#Current maintainer: Nick McCarty nmccarty@phytec.com

# pull basse ubuntu image
FROM ubuntu:18.04

#set up our release labels
LABEL vendor="PHYTEC"
LABEL distribution="Peaks"
LABEL description="PHYTEC Peaks Build System v2.0.0. A build system for building a subset of PHYTEC BSPS in a docker container"
LABEL version="2.0.0"
LABEL version.codename="Si"

# set up bash instead of dash
RUN ln -sf bash /bin/sh

# install core dependencies
RUN echo "Installing dependencies"
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 \
    && apt -yqq update \
    && apt-get install -yqq locales sudo

# locales issue fix
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
ENV LANG=en_US.UTF-8


# bitbake - create a non-root user for bitbake
RUN adduser --disabled-password --gecos '' baker \
    && adduser baker sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# change the user
USER baker

# set up env directory
ENV DIR "/home/baker"
WORKDIR $DIR


#Copy current supported build scripts
COPY bsp-build-scripts/ bsp-build-scripts 
RUN sudo chown -R baker bsp-build-scripts/

#make scripts executable
RUN find bsp-build-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;





