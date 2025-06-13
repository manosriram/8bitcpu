const std = @import("std");
const cpu = @import("cpu.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var c = cpu.CPU.new(allocator);
    defer c.Stack.deinit();

    try c.Stack.append(123);

    std.debug.print("{} {}", .{c.Memory[0], c.Stack.items.len});
}
