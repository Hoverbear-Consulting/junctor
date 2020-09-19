[![Crates.io](https://img.shields.io/crates/v/junctor.svg)](https://crates.io/crates/junctor)
[![Workflow Status](https://github.com/hoverbear-consulting/junctor/workflows/Suite/badge.svg)](https://github.com/hoverbear-consulting/junctor/actions?query=workflow%3A%22Suite%22)

# junctor

Right now, this is just a project that is slowly evolving as I learn through some material.

> This is a project for [nRF52840-DK](https://www.mouser.ca/ProductDetail/Nordic-Semiconductor/nRF52840-DK?qs=F5EMLAvA7IA76ZLjlwrwMw%3D%3D).

Eventual goals are some mesh networking, some sensor collection, and some data processing.

### Setup

This project only supports Ubuntu 20.04 and Windows 10 Pro right now.

#### Ubuntu 20.04

You can emulate a full automated CI run, which will properly set up your
machine, including installing all `apt` packages, bootstrapping Rustup, setting up the necessary
tools, and getting Python untangled.

```bash
make ci PREREQS=true
```

#### Windows 10 Pro

> **Note:** Windows support is preliminary.

You'll need to install [Zadig](https://zadig.akeo.ie/]) and [scoop](https://scoop.sh) yourself.

Then, please bootstrap your toolchain in Powershell:

```powershell
scoop install rustup busybox make gawk python
make ci PREREQS=true
```

### Usage

Once you've done that, I suggest you enjoy the `make help` command.

these should all just work and I'd love it if you reported a bug if they didn't.

😊
