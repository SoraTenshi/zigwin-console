const std = @import("std");
const win = std.os.windows;

const File = std.fs.File;

const zwin = @import("zigwin32").everything;

const CONSOLE_MODE = zwin.CONSOLE_MODE;
fn getSaneMode() CONSOLE_MODE {
    return CONSOLE_MODE.ENABLE_VIRTUAL_TERMINAL_INPUT | CONSOLE_MODE.ENABLE_AUTO_POSITION;
}

pub const WindowsConsoleStream = struct {
    const Self = @This();

    /// The handle to the console
    handle: win.HANDLE,

    pub const capable_io_mode = std.io.default_mode;
    pub const intended_io_mode = std.io.default_mode;

    pub fn init(handle: win.HANDLE) Self {
        var self = Self{
            .handle = handle,
        };

        _ = zwin.SetConsoleMode(self.handle, zwin.getSaneMode());
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
