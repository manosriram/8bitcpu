const std = @import("std");
const Program = @import("program.zig").Program;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var p = Program.new(gpa.allocator());
    try p.load();
    try p.run();
}
