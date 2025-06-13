const std = @import("std");
const cpu = @import("cpu.zig");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();


    const file = try std.fs.cwd().openFile("./source.asm", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    // TODO: parse line and handle opcodes
    while (try in_stream.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
