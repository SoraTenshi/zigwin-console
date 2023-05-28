const std = @import("std");
const win = std.os.windows;

const IOError = std.io.Writer.Error;

const stream = @import("console_handler/stream.zig");

const zwin = @import("zigwin32").everything;

const Level = enum {
    info,
    good,
    bad,
};

const Console = struct {
    /// The handle to the console
    console_handle: stream.WindowsConsoleHandler,

    pub fn init(comptime name: []const u8) !Console {
        _ = zwin.AllocConsole();
        _ = zwin.SetConsoleTitle(name);

        return Console{
            .console_handle = stream.WindowsConsoleHandler.init(try zwin.GetStdHandle(zwin.STD_OUTPUT_HANDLE)),
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
        return writer.print("[+] " ++ fmt, args);
    }

    fn printInfo(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        return writer.print("[*] " ++ fmt, args);
    }

    fn printBad(self: *Console, comptime fmt: []const u8, args: anytype) IOError!void {
        const writer = self.console_handle.getConsoleOut().writer();
        return writer.print("[-] " ++ fmt, args);
    }
};
