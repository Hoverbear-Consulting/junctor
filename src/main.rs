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
#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

extern crate alloc;

/// The global allocator for the node.
#[global_allocator]
static ALLOCATOR: alloc_cortex_m::CortexMHeap = alloc_cortex_m::CortexMHeap::empty();

/// The configured heap size of the node.
const HEAP_SIZE: usize = 10 * 1024;

pub mod diagnostics;
pub mod subscriber;
pub mod tasks;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true, monotonic = rtic::cyccnt::CYCCNT)]
const JUNCTOR: () = {
    // All tasks have a common pattern:
    // 1. Prepare params.
    // 2. Pass params to the task module.

    /// The initialization phase.
    #[init]
    fn init(context: init::Context) {
        tasks::init::invoke(context);
    }

    /// The main phase.
    #[idle]
    fn idle(context: idle::Context) -> ! {
        tasks::idle::invoke(context)
    }
};

/// When facing an alloc error, we likely can't print. So we have to bail.
#[alloc_error_handler]
fn alloc_error(_layout: core::alloc::Layout) -> ! {
    loop {
        cortex_m::asm::bkpt()
    }
}

/// When panicking, attempt to log it, else bail.
#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    tracing::event!(tracing::Level::ERROR, ?info, "Panicked!");
    loop {
        cortex_m::asm::bkpt()
    }
}
