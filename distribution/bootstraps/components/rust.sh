#! /usr/bin/env bash

set -e

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet

source ~/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"

# TODO: Take off my training wheels. :)
cargo install --quiet \
    --git https://github.com/ferrous-systems/embedded-trainings-2020/ \
    --bins \
        dk-run \
        dongle-flash \
        serial-term \
        usb-list \
        change-channel
