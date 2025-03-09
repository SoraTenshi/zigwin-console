const std = @import("std");

pub fn build(b: *std.Build) void {
    var zigwin32 = b.dependency("zigwin32", .{});

    const zigwin_console = b.addModule("zigwin-console", .{
        .root_source_file = b.path("console.zig"),
    });
    zigwin_console.addImport("zigwin32", zigwin32.module("win32"));

    const optimize = b.standardOptimizeOption(.{});
    const zigwin_console_test = b.addTest(.{
        .root_source_file = b.path("console.zig"),
        .target = b.resolveTargetQuery(.{ .os_tag = .windows }),
        .optimize = optimize,
    });
    zigwin_console_test.root_module.addImport("zigwin32", zigwin32.module("win32"));

    const run_lib_tests = b.addRunArtifact(zigwin_console_test);
    const test_step = b.step("test", "Run the library tests");
    test_step.dependOn(&run_lib_tests.step);
}
