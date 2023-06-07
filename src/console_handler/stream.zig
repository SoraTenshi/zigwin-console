const std = @import("std");
const win = std.os.windows;

const File = std.fs.File;

const zwin = @import("zigwin32").everything;

pub const WindowsConsoleStream = struct {
    const Self = @This();

    /// The handle to the console
    handle: win.HANDLE,

    capable_io_mode: std.io.ModeOverride = std.io.default_mode,
    intended_io_mode: std.io.ModeOverride = std.io.default_mode,

    pub fn init(handle: zwin.HANDLE) Self {
        var self = Self{
            .handle = handle,
        };

        // Enable the option for ANSI Escape sequences
        _ = zwin.SetConsoleMode(self.handle, zwin.ENABLE_VIRTUAL_TERMINAL_INPUT);
        return self;
    }

    pub fn getConsoleOut(self: Self) File {
        return File{
            .handle = self.handle,
            .capable_io_mode = self.capable_io_mode,
            .intended_io_mode = self.intended_io_mode,
        };
    }
};
