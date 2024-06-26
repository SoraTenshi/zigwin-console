const std = @import("std");
const win = std.os.windows;

const IOError = error{IOError};

const stream = @import("console_handler/stream.zig");

const zwin = @import("zigwin32");
const HANDLE = zwin.foundation.HANDLE;
const console = zwin.system.console;

const Level = enum {
    info,
    good,
    bad,
};

const Color = union(enum) {
    red,
    blue,
    green,
    default,
};

fn colorToVariant(self: Color) console.CONSOLE_CHARACTER_ATTRIBUTES {
    return switch (self) {
        .red => console.FOREGROUND_RED,
        .blue => console.FOREGROUND_BLUE,
        .green => console.FOREGROUND_GREEN,
        .default => console.CONSOLE_CHARACTER_ATTRIBUTES{},
    };
}

/// The Console object, all the annoying parts are
pub const Console = struct {
    /// The handle to the console
    console_handle: stream.WindowsConsoleStream,
    /// Whether to use ansi escape commands
    use_ansi_escape: bool,

    /// Initializes (and allocates) a new windows console
    ///
    /// name: The Window-title of the Console
    /// use_stdout_fallback: When `AllocConsole()` fails, this is most likely an indicator that
    /// there already exists a console (e.g. you're controlling from a subprocess)
    /// if you just want to share the same stdout handle as the host-process, just feed it `true`
    pub fn init(comptime name: [*:0]const u8, use_stdout_fallback: bool, use_ansi_escape: bool) !Console {
        var handle: ?HANDLE = null;
        const new_console = console.AllocConsole();
        if (new_console == win.FALSE and use_stdout_fallback) {
            handle = std.io.getStdOut().handle;
        } else if (new_console == win.FALSE and !use_stdout_fallback) {
            return error.NoNewConsole;
        }

        _ = console.SetConsoleTitleA(name);

        return Console{
            .console_handle = stream.WindowsConsoleStream.init(console.GetStdHandle(console.STD_OUTPUT_HANDLE)),
            .use_ansi_escape = use_ansi_escape,
        };
    }

    pub fn deinit(_: Console) void {
        _ = console.FreeConsole();
    }

    /// Prints an string.
    /// level takes either of those 3 values:
    ///   - .info -> blue and marked with [*]
    ///   - .good -> green and marked with [+]
    ///   - .bad -> red and marked with [-]
    /// May return an error on failure
    pub fn printChecked(self: *Console, level: Level, comptime fmt: []const u8, args: anytype) IOError!void {
        return switch (level) {
            .info => printInfo(self, fmt, args),
            .good => printGood(self, fmt, args),
            .bad => printBad(self, fmt, args),
        };
    }

    /// Prints an string with a newline at the end.
    /// level takes either of those 3 values:
    ///   - .info -> blue and marked with [*]
    ///   - .good -> green and marked with [+]
    ///   - .bad -> red and marked with [-]
    /// May return an error on failure
    pub fn printLineChecked(self: *Console, level: Level, comptime fmt: []const u8, args: anytype) IOError!void {
        return self.printChecked(level, fmt ++ "\n", args);
    }

    /// Prints an string.
    /// level takes either of those 3 values:
    ///   - .info -> blue and marked with [*]
    ///   - .good -> green and marked with [+]
    ///   - .bad -> red and marked with [-]
    pub fn print(self: *Console, level: Level, comptime fmt: []const u8, args: anytype) void {
        switch (level) {
            .info => printInfo(self, fmt, args) catch {},
            .good => printGood(self, fmt, args) catch {},
            .bad => printBad(self, fmt, args) catch {},
        }
    }

    /// Prints an string with a newline at the end.
    /// level takes either of those 3 values:
    ///   - .info -> blue and marked with [*]
    ///   - .good -> green and marked with [+]
    ///   - .bad -> red and marked with [-]
    pub fn printLine(self: *Console, level: Level, comptime fmt: []const u8, args: anytype) void {
        return self.print(level, fmt ++ "\n", args);
    }

    fn setConsoleAttribute(self: *Console, color: Color) void {
        _ = console.SetConsoleTextAttribute(self.console_handle.handle, colorToVariant(color));
    }

    fn printGood(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        if (self.use_ansi_escape) {
            return writer.print("\x1b[32m[+] \x1b[0m" ++ fmt, args) catch IOError.IOError;
        } else {
            self.setConsoleAttribute(Color.green);
            writer.print("[+] ", .{}) catch return IOError.IOError;
            self.setConsoleAttribute(Color.default);
            return writer.print(fmt, args) catch IOError.IOError;
        }
    }

    fn printInfo(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        if (self.use_ansi_escape) {
            return writer.print("\x1b[34m[*] \x1b[0m" ++ fmt, args) catch IOError.IOError;
        } else {
            self.setConsoleAttribute(Color.blue);
            writer.print("[*] ", .{}) catch return IOError.IOError;
            self.setConsoleAttribute(Color.default);
            return writer.print(fmt, args) catch IOError.IOError;
        }
    }

    fn printBad(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        if (self.use_ansi_escape) {
            return writer.print("\x1b[31m[-] \x1b[0m" ++ fmt, args) catch IOError.IOError;
        } else {
            self.setConsoleAttribute(Color.red);
            writer.print("[-] ", .{}) catch return IOError.IOError;
            self.setConsoleAttribute(Color.default);
            return writer.print(fmt, args) catch IOError.IOError;
        }
    }
};
