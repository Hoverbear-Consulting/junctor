#! /usr/bin/env bash

set -e

sudo apt update --yes -qqq
sudo apt install --yes -qqq \
    gawk \
    make \
    build-essential \
    pkg-config \
    libusb-1.0-0-dev \
    libudev-dev \
    libssl-dev \
    python3-pip

./distribution/bootstraps/components/rust.sh
./distribution/bootstraps/components/python.sh

cat <<-EOF | sudo dd of=/etc/udev/rules.d/50-nRF52840.rules
# udev rules to allow access to USB devices as a non-root user

# nRF52840 Dongle in bootloader mode
ATTRS{idVendor}=="1915", ATTRS{idProduct}=="521f", TAG+="uaccess"

# nRF52840 Dongle applications
ATTRS{idVendor}=="2020", TAG+="uaccess"

# nRF52840 Development Kit
ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules