use core::{
    fmt::{self, Write},
    sync::atomic::Ordering,
};
use tracing::{field, span, Event, Level, Metadata};

pub struct Subscriber {
    max_level: tracing::level_filters::LevelFilter,
    terminal_channel: core::cell::RefCell<rtt_target::UpChannel>,
    next_id: core::sync::atomic::AtomicUsize,
}

unsafe impl Sync for Subscriber {}

impl Subscriber {
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

    fn enabled(&self, level: &Level) -> bool {
        level <= &self.max_level
    }
}

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

        let _ = (*self.terminal_channel.borrow_mut()).write_str("\n");
        span::Id::from_u64(id as u64)
    }

    fn record(&self, _span: &span::Id, _values: &span::Record) {
        // TODO: nop for now
    }

    fn record_follows_from(&self, _span: &span::Id, _follows: &span::Id) {
        // TODO: nop for now
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
        // TODO: noop
    }

    fn exit(&self, _span: &span::Id) {
        // TODO: noop
    }
}
