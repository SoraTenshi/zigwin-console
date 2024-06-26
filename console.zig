/// Make the whole library useable
pub usingnamespace @import("src/windows_console.zig");

test {
    const testing = @import("std").testing;
    testing.refAllDecls(@This());
    testing.refAllDeclsRecursive(@import("src/windows_console.zig"));
    testing.refAllDecls(@import("src/console_handler/stream.zig"));
}
