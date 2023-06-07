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

/// The Console object, all the annoying parts are
pub const Console = struct {
    /// The handle to the console
    console_handle: stream.WindowsConsoleStream,

    /// Initializes (and allocates) a new windows console
    ///
    /// name: The Window-title of the Console
    /// use_stdout_fallback: When `AllocConsole()` fails, this is most likely an indicator that
    /// there already exists a console (e.g. you're controlling from a subprocess)
    /// if you just want to share the same stdout handle as the host-process, just feed it `true`
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

    /// Print an ANSI-escaped (for colours) string.
    /// level takes either of those 3 values:
    ///   - .info -> blue and marked with [*]
    ///   - .good -> green and marked with [+]
    ///   - .bad -> red and marked with [-]
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
