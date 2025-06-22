const std = @import("std");
const Program = @import("program.zig").Program;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var p = Program.new(gpa.allocator(), "./source.asm");
    defer _ = p.deinit();
    try p.load();
    try p.run();

    std.debug.print("memory -> {any}\n", .{p.cpu.Memory});
    std.debug.print("registers -> {any}\n", .{p.cpu.Register});
    std.debug.print("flags -> {any}\n", .{p.cpu.Flags});
}
