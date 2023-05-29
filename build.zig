const std = @import("std");

pub fn build(b: *std.Build) void {
    var zigwin32 = b.dependency("zigwin32", .{});

    _ = b.addModule(
        "zigwin-console",
        .{
            .source_file = .{ .path = "console.zig" },
            .dependencies = &.{
                .{ .name = "zigwin32", .module = zigwin32.module("zigwin32") },
            },
        },
    );
}
