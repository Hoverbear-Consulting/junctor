//! A collection of diagnostic messages.

/// Print the start message for the node.
#[tracing::instrument]
pub fn start_message() {
    tracing::event!(
        tracing::Level::INFO,
        package = crate::build_info::PKG_NAME,
        version = crate::build_info::PKG_VERSION,
        author = crate::build_info::PKG_AUTHORS,
        website = crate::build_info::PKG_HOMEPAGE,
        description = crate::build_info::PKG_DESCRIPTION,
        build.profile = crate::build_info::PROFILE,
        build.utc = crate::build_info::BUILT_TIME_UTC,
        build.rustc = crate::build_info::RUSTC_VERSION,
        build.opt = crate::build_info::OPT_LEVEL,
        build.sha = crate::build_info::GIT_COMMIT_HASH.unwrap_or("None"),
    );
}

/// Print the halt message for when the node has chosen to halt.
pub fn halt_message() {
    tracing::event!(
        tracing::Level::INFO,
        "This node in an idle, sleeping state."
    );
}
