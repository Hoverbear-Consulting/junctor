#![no_std]
#![no_main]

use cortex_m_rt::entry;
use log::Log;
use nrf52840_pac;
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
