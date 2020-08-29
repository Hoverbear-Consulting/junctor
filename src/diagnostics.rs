//! A collection of diagnostic messages.

/// Print the start message for the node.
#[tracing::instrument]
pub fn start_message() {
    tracing::event!(
        tracing::Level::INFO,
        package = env!("CARGO_PKG_NAME"),
        version = env!("CARGO_PKG_VERSION"),
        author = env!("CARGO_PKG_AUTHORS"),
        website = env!("CARGO_PKG_HOMEPAGE"),
        description = env!("CARGO_PKG_DESCRIPTION"),
    );
}

/// Print the halt message for when the node has chosen to halt.
#[tracing::instrument]
pub fn halt_message() {
    tracing::event!(
        tracing::Level::INFO,
        "This node in an idle, sleeping state."
    );
}
