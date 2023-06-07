# zigwin-console
A simple console-spawner for Windows. Usually used for debugging DLLs

## Example usage:
```zig
const c = @import("zigwin-console");

pub fn main() !void {
  const console = try c.Console.init("My new console!", true);
  // Always free your console!
  defer console.deinit();

  try console.print(.info, "Coffee's here commander!\n", .{});
  try console.print(.bad, "Oh no! i forgot the milk!\n", .{});
  try console.print(.good, "Don't worry!~\n", .{});
}
```
