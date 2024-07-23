/// Make the whole library useable
const win_console = @import("src/windows_console.zig");
pub const Console = win_console.Console;

test {
    const testing = @import("std").testing;
    testing.refAllDecls(@This());
    testing.refAllDeclsRecursive(@import("src/windows_console.zig"));
    testing.refAllDecls(@import("src/console_handler/stream.zig"));
}
