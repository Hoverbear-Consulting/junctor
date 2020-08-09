[![Crates.io](https://img.shields.io/crates/v/junctor.svg)](https://crates.io/crates/junctor)
[![Workflow Status](https://github.com/hoverbear-consulting/junctor/workflows/Suite/badge.svg)](https://github.com/hoverbear-consulting/junctor/actions?query=workflow%3A%22Suite%22)

# junctor

Right now, this is just a project that is slowly evolving as I learn through some material.

> This is a project for [nRF52840-DK](https://www.mouser.ca/ProductDetail/Nordic-Semiconductor/nRF52840-DK?qs=F5EMLAvA7IA76ZLjlwrwMw%3D%3D).

Eventual goals are some mesh networking, some sensor collection, and some data processing.

### Usage

This project only supports Ubuntu 20.04 right now.

You can emulate a full CI run, which will properly set up your machine, including installing all `apt` packages, bootstrapping Rustup, setting up the necessary tools, and getting Python untangled.

```bash
make ci
```

Once you've done that, I suggest you enjoy the `make help` command.

If you're on Ubuntu 20.04, these should all just work and I'd love it if you reported a bug if they didn't.

😊
