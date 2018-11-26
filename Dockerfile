FROM amd64/ubuntu:18.04

LABEL maintainer "Greg Breen <greg@uncannier.com>"
LABEL description "Simplicity Studio in a container for CI of Thunderboard projects"

# To the best of my knowledge, Silicon Labs do not support headless install of 
# Simplicity Studio. We can do the base install headlessly, but we can't install
# the SDKs (Gecko and Bluetooth for example) without running the GUI. Thus we
# build this Docker image by copying a Simplicity Studio installation that already
# has the SDKs installed. Therefore this Dockerfile should be executed in a Linux distro
# that is the same as the Linux distro used as the base image here. Ubuntu 18.04 amd64 
# in my case.
RUN mkdir -p /opt/SimplicityStudio_v4
COPY SimplicityStudio_v4 /opt/SimplicityStudio_v4

# Need to install Simplicity Studio's prerequisites - we use its setup script to do
# this. As a consequence, we need to setup udev rules even though this image is only 
# used for building.
RUN dpkg --add-architecture i386
RUN apt-get update
RUN mkdir -p /etc/udev/rules.d
RUN sed -i "s/sudo apt-get install/apt-get install -y/" "/opt/SimplicityStudio_v4/setup.sh"
RUN /opt/SimplicityStudio_v4/setup.sh

# Need 64-bit edition of Qt5 for Simplicity Commander to run
RUN apt-get install libqt5gui5

# Need to install the following package to avoid warnings during builds
RUN apt-get install -y libcanberra-gtk-module

# Put Simplicity Commander in the path - our build calls Commander
ENV PATH="/opt/SimplicityStudio_v4/developer/adapter_packs/commander:$PATH"
