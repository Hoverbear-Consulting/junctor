#[tracing::instrument(skip(_context))]
pub(crate) fn invoke(_context: crate::idle::Context) -> ! {
    crate::diagnostics::halt_message();
    loop {}
}
