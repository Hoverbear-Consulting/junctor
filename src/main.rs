#![no_std]
#![no_main]

//! Right now, this is just a project that is slowly evolving as I learn through some material.
//!
//! > This is a project for [nRF52840-DK](https://www.mouser.ca/ProductDetail/Nordic-Semiconductor/nRF52840-DK?qs=F5EMLAvA7IA76ZLjlwrwMw%3D%3D).
//!
//! Eventual goals are some mesh networking, some sensor collection, and some data processing.
//!
//! ## Usage
//!
//! This project only supports Ubuntu 20.04 right now.
//!
//! You can emulate a full CI run, which will properly set up your machine, including installing all `apt` packages, bootstrapping Rustup, setting up the necessary tools, and getting Python untangled.
//!
//! ```bash
//! make ci
//! ```
//!
//! Once you've done that, I suggest you enjoy the `make help` command.
//!
//! If you're on Ubuntu 20.04, these should all just work and I'd love it if you reported a bug if they didn't.
//!
//! 😊

use cortex_m_rt::entry;
use log::Log;
use panic_halt as _;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    nrf52840_pac::Peripherals::take();

    rtt_init_print!();

    log::set_logger(&Logger).unwrap();

    if log::max_level() == log::LevelFilter::Off {
        log::set_max_level(log::LevelFilter::Info)
    }

    log::info!("Initializing the board");

    loop {
        // your code goes here
    }
}

struct Logger;

impl Log for Logger {
    fn enabled(&self, metadata: &log::Metadata) -> bool {
        metadata.level() <= log::STATIC_MAX_LEVEL
    }

    fn log(&self, record: &log::Record) {
        if !self.enabled(record.metadata()) {
            return;
        }

        rprintln!(
            "{}:{} -- {}",
            record.level(),
            record.target(),
            record.args()
        );
    }

    fn flush(&self) {}
}
