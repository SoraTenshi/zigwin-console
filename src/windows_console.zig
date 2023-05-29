const std = @import("std");
const win = std.os.windows;

const IOError = error{IOError};

const stream = @import("console_handler/stream.zig");

const zwin = @import("zigwin32").everything;

const Level = enum {
    info,
    good,
    bad,
};

pub const Console = struct {
    /// The handle to the console
    console_handle: stream.WindowsConsoleStream,

    pub fn init(comptime name: [*:0]const u8, use_stdout_fallback: bool) !Console {
        var handle: ?zwin.HANDLE = null;
        const new_console = zwin.AllocConsole();
        if (new_console == win.FALSE and use_stdout_fallback) {
            handle = std.io.getStdOut().handle;
        } else if (new_console == win.FALSE and !use_stdout_fallback) {
            return error.NoNewConsole;
        }

        _ = zwin.SetConsoleTitleA(name);

        return Console{
            .console_handle = stream.WindowsConsoleStream.init(zwin.GetStdHandle(zwin.STD_OUTPUT_HANDLE)),
        };
    }

    pub fn deinit(_: Console) void {
        _ = zwin.FreeConsole();
    }

    pub fn print(self: *Console, level: Level, comptime fmt: []const u8, args: anytype) IOError!void {
        return switch (level) {
            .info => printInfo(self, fmt, args),
            .good => printGood(self, fmt, args),
            .bad => printBad(self, fmt, args),
        };
    }

    fn printGood(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        return writer.print("\x1b[32m[+] \x1b[0m" ++ fmt, args) catch IOError.IOError;
    }

    fn printInfo(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        return writer.print("\x1b[34m[*] \x1b[0m" ++ fmt, args) catch IOError.IOError;
    }

    fn printBad(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        return writer.print("\x1b[31m[-] \x1b[0m" ++ fmt, args) catch IOError.IOError;
    }
};
