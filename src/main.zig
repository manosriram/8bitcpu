const std = @import("std");
const cpu = @import("cpu.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("./source.asm", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;

    const allocator = gpa.allocator();

    const opcodes = try utils.initOpcodes();
    // var c = cpu.CPU.new(allocator);

    while (try in_stream.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        const splits = try utils.split(allocator, line, " ");
        defer splits.deinit();

        if (opcodes.get(splits.items[0])) |opcode| {
            switch (opcode) {
                0x01 => {
                    const register = splits.items[1];
                    const val = splits.items[2];
                    std.debug.print("MOV from {s} to {s}\n", .{val, register});
                },
                0x02 => {
                    std.debug.print("CMP!!\n", .{});
                },
                else => {

                }
            }
        }
    }
}
