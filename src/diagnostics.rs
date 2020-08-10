#[tracing::instrument]
pub fn start_message() {
    tracing::event!(tracing::Level::INFO, package = crate::build_info::PKG_NAME);
    tracing::event!(tracing::Level::INFO, profile = crate::build_info::PROFILE);
    tracing::event!(
        tracing::Level::INFO,
        version = crate::build_info::PKG_VERSION
    );
    if let Some(sha) = crate::build_info::GIT_COMMIT_HASH {
        tracing::event!(tracing::Level::INFO, sha);
    }
    tracing::event!(
        tracing::Level::INFO,
        author = crate::build_info::PKG_AUTHORS
    );
    tracing::event!(
        tracing::Level::INFO,
        description = crate::build_info::PKG_DESCRIPTION
    );
    tracing::event!(
        tracing::Level::INFO,
        website = crate::build_info::PKG_HOMEPAGE
    );
    tracing::event!(tracing::Level::INFO, target = crate::build_info::TARGET);
    tracing::event!(
        tracing::Level::INFO,
        built_utc = crate::build_info::BUILT_TIME_UTC
    );
}

pub fn halt_message() {
    tracing::event!(
        tracing::Level::INFO,
        "This node in an idle, sleeping state."
    );
}
