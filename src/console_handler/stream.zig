const std = @import("std");
const win = std.os.windows;

const File = std.fs.File;

const zwin = @import("zigwin32");
const HANDLE = zwin.foundation.HANDLE;
const console = zwin.system.console;

pub const WindowsConsoleStream = struct {
    const Self = @This();

    /// The handle to the console
    handle: HANDLE,

    /// Apparently, the ModeOverride setting is not there anymore?
    // capable_io_mode: std.io.ModeOverride = std.io.default_mode,
    // intended_io_mode: std.io.ModeOverride = std.io.default_mode,

    pub fn init(handle: HANDLE) Self {
        const self = Self{
            .handle = handle,
        };

        // Enable the option for ANSI Escape sequences
        _ = console.SetConsoleMode(self.handle, console.ENABLE_VIRTUAL_TERMINAL_INPUT);
        return self;
    }

    pub fn getConsoleOut(self: Self) File {
        return File{
            .handle = self.handle,
            // .capable_io_mode = self.capable_io_mode,
            // .intended_io_mode = self.intended_io_mode,
        };
    }
};
