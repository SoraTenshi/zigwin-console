const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule(
        "zigwin-console",
        .{
            .source_file = .{ .path = "console.zig" },
            .dependencies = .{
                .name = "zigwin32",
                .module = b.dependency("zigwin32", .{}),
            },
        },
    );
}
