//! A simple, ultra-minimal subscriber based off [a mushroomy example](https://github.com/hawkw/mycelium/blob/0f9a544063a8a24cb70f1b5c6ece58403d7adfab/hal-x86_64/src/tracing.rs).
//!
//! For now, this module is deliberately very lightly implemented and mostly just stubs.
//! It's much more desirable to explore adding `#[no_std]` support to `tracing-subscriber`.

use core::{
    fmt::{self, Write},
    sync::atomic::Ordering,
};
use tracing::{field, span, Event, Level, Metadata};

/// An rtt_target based subscriber.
///
/// # Safety
///
/// This is not thread safe!
pub struct Subscriber {
    /// The maximum level this subscriber will print.
    max_level: tracing::level_filters::LevelFilter,
    /// A channel to the host.

    /// # Safety
    ///
    /// This is not thread safe!
    terminal_channel: core::cell::RefCell<rtt_target::UpChannel>,
    /// The next span ID to be used.
    next_id: core::sync::atomic::AtomicUsize,
}

/// # Safety
///
/// This is not thread safe!
unsafe impl Sync for Subscriber {}

impl Subscriber {
    /// Create a new subscriber for a given [`rtt_target::UpChannel`].
    pub fn new(
        writer: rtt_target::UpChannel,
        max_level: tracing::level_filters::LevelFilter,
    ) -> Self {
        Self {
            max_level,
            terminal_channel: core::cell::RefCell::from(writer),
            next_id: core::sync::atomic::AtomicUsize::new(1),
        }
    }
    /// Report if the subscriber is enabled, given some level.
    fn enabled(&self, level: &Level) -> bool {
        level <= &self.max_level
    }
}

/// A minimal visitor for [`Subscriber`].
struct Visitor<'a, W> {
    writer: &'a mut W,
    seen: bool,
}

impl<'a, W: Write> field::Visit for Visitor<'a, W> {
    fn record_debug(&mut self, field: &field::Field, val: &dyn fmt::Debug) {
        if field.name() == "message" {
            if self.seen {
                let _ = write!(self.writer, ", {:?}", val);
            } else {
                let _ = write!(self.writer, "{:?}", val);
                self.seen = true;
            }
        } else if self.seen {
            let _ = write!(self.writer, ", {}= {:?}", field, val);
        } else {
            let _ = write!(self.writer, "{} = {:?}", field, val);
            self.seen = true;
        }
    }
}

impl tracing::Subscriber for Subscriber {
    fn enabled(&self, metadata: &Metadata) -> bool {
        let level = metadata.level();
        self.enabled(level)
    }

    fn new_span(&self, span: &span::Attributes) -> span::Id {
        let meta = span.metadata();
        let level = meta.level();

        let _ = write!(*self.terminal_channel.borrow_mut(), "{} ", level);
        let _ = write!(*self.terminal_channel.borrow_mut(), "{}", meta.name());
        {
            let mut visitor = Visitor {
                writer: &mut *self.terminal_channel.borrow_mut(),
                seen: true,
            };
            span.record(&mut visitor);
        }

        // Overflowing is fine here... We've almost certainly handled the other span.
        let id = self.next_id.fetch_add(1, Ordering::Acquire);
        // But if we do overflow, we need to increment again to make sure our SpanID isn't 0.
        let id = if id == 0 {
            self.next_id.fetch_add(1, Ordering::Acquire)
        } else {
            id
        };

        let _ = (*self.terminal_channel.borrow_mut()).write_str("\n");
        span::Id::from_u64(id as u64)
    }

    fn record(&self, _span: &span::Id, _values: &span::Record) {
        // TODO
        // let _ = write!(*self.terminal_channel.borrow_mut(), "record");
    }

    fn record_follows_from(&self, _span: &span::Id, _follows: &span::Id) {
        // TODO
        // let _ = write!(*self.terminal_channel.borrow_mut(), "record_follows_from");
    }

    fn event(&self, event: &Event) {
        let meta = event.metadata();
        let level = meta.level();

        let _ = write!(*self.terminal_channel.borrow_mut(), "{} ", level);

        let _ = write!(*self.terminal_channel.borrow_mut(), "{}: ", meta.target());
        {
            let mut visitor = Visitor {
                writer: &mut *self.terminal_channel.borrow_mut(),
                seen: false,
            };
            event.record(&mut visitor);
        }
        let _ = (*self.terminal_channel.borrow_mut()).write_str("\n");
    }

    fn enter(&self, _span: &span::Id) {
        // TODO
        // let _ = write!(*self.terminal_channel.borrow_mut(), "enter");
    }

    fn exit(&self, _span: &span::Id) {
        // TODO
        // let _ = write!(*self.terminal_channel.borrow_mut(), "exit");
    }
}
