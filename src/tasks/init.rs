#[tracing::instrument(skip(context))]
pub(crate) fn invoke(mut context: crate::init::Context) {
    unsafe { crate::ALLOCATOR.init(cortex_m_rt::heap_start() as usize, crate::HEAP_SIZE) }

    let rtt_channels = rtt_target::rtt_init! {
        up: {
            0: {
                size: 10240
                mode: BlockIfFull
                name: "Terminal"
            }
        }
    };
    let rtt_channels_logger = rtt_channels.up.0;
    let subscriber = crate::subscriber::rtt::Subscriber::new(
        rtt_channels_logger,
        tracing::level_filters::LevelFilter::TRACE,
    );
    tracing::subscriber::set_global_default(subscriber).expect("global default was already set!");

    crate::diagnostics::start_message();

    tracing::trace!(
        peripheral.name = "CLOCK",
        peripheral.group = "device",
        "Initializing the external oscillator high frequency clock source.",
    );
    let _clocks = nrf52840_hal::clocks::Clocks::new(context.device.CLOCK).enable_ext_hfosc();

    tracing::trace!(
        peripheral.name = "DCB",
        peripheral.group = "core",
        "Initializing the monotonic timer (CYCCNT)",
    );
    context.core.DCB.enable_trace();

    tracing::trace!(
        peripheral.name = "DWT",
        peripheral.group = "core",
        "Initializing cycle counter",
    );
    cortex_m::peripheral::DWT::unlock();
    context.core.DWT.enable_cycle_counter();
}
