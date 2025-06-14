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
    const registerOpcodes = try utils.initRegisterOpcodes();
    var c = cpu.CPU.new(allocator);
    // c.InstructionPointer = &c.Memory[0];

    while (try in_stream.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        const splits = try utils.split(allocator, line, " ");
        defer splits.deinit();

        if (opcodes.get(splits.items[0])) |opcode| {
            switch (opcode) {
                0x01 => {
                    const register = std.mem.trim(u8, splits.items[1], ",");
                    const val = splits.items[2];
                    
                    c.Memory[c.InstructionPointer] = opcode;
                    if (registerOpcodes.get(register)) |registerOpcode| {
                        c.Memory[c.InstructionPointer+1] = registerOpcode;
                    }
                    c.Memory[c.InstructionPointer+2] = try std.fmt.parseInt(u8, val, 10);
                    c.InstructionPointer += 3;

                    // if (registerOpcodes.get(register)) |registerOpcode| {
                        // switch (registerOpcode) {
                            // 0x00 => {
                                // c.Register.A = try std.fmt.parseInt(u8, val, 10);
                            // },
                            // 0x01 => {
                                // c.Register.B = try std.fmt.parseInt(u8, val, 10);
                            // },
                            // 0x10 => {
                                // c.Register.C = try std.fmt.parseInt(u8, val, 10);
                            // },
                            // 0x11 => {
                                // c.Register.D = try std.fmt.parseInt(u8, val, 10);
                            // },
                            // else => {}
                        // }
                    // }

                    std.debug.print("MOV from {s} to {s}\n", .{val, register});
                },
                0x02 => {
                    const register = std.mem.trim(u8, splits.items[1], ",");
                    const val = splits.items[2];
                    std.debug.print("CMP {s} to {s}\n", .{val, register});
                },
                else => {

                }
            }
        }

    }
        std.debug.print("registers -> {any} {any} {any} {any}\n", .{c.Register.A, c.Register.B, c.Register.C, c.Register.D});
        std.debug.print("memory -> {any}", .{c.Memory});
}
