# Junctor

Right now, this is just a project that is slowly evolving as I learn through some material.

> This is a project for [nRF52840-DK](https://www.mouser.ca/ProductDetail/Nordic-Semiconductor/nRF52840-DK?qs=F5EMLAvA7IA76ZLjlwrwMw%3D%3D).

Eventual goals are some mesh networking, some sensor collection, and some data processing.

## Usage

This project only supports Ubuntu 20.04 right now.

You can emulate a full CI run, which will properly set up your machine, including installing all `apt` packages, bootstrapping Rustup, setting up the necessary tools, and getting Python untangled.

```bash
make ci
```

Once you've done that, I suggest you enjoy the `make help` command.

If you're on Ubuntu 20.04, these should all just work and I'd love it if you reported a bug if they didn't.

😊

## Mentoring Available / Requested

I'm learning at my own pace on this through [The Embedded Trainings 2020](https://github.com/ferrous-systems/embedded-trainings-2020) series from Ferrous Systems.

If you're someone who doesn't really know what all this is, and you want to learn about it with me, let me know. You can [email me](mailto:operator@hoverbear.org) if you don't want to post publicly on issues.

If you want to mentor me and/or others who might get involved, I'd love it if you opened an issue and said hi! I frequently like to rubber ducky debug against live humans, and people seeing that they might have some help beyond me might encourage them to try things out.

## Contributing

* Please commit using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). I provide Git hooks and Make targets to help you, please use them!
* Please don't get mad if I say something isn't in scope and close it! I'm just hacking!

## Code of Conduct / Licensing

You're welcome to try out, interact with, or contribute to, or derive from this repo anything you wish, but if you make this project not fun for anyone working on it, you will be immediately banned without recourse or discussion.

## License

```
Copyright 2020 Ana Hobden (Hoverbear Consulting)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
This software is not used to oppress or detain living creatures.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```