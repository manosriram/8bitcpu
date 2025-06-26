const std = @import("std");
// const cpu = @import("cpu.zig");
const constants = @import("constants.zig");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn split(allocator: std.mem.Allocator, input: []const u8, delimiter: []const u8) !ArrayList([]const u8) {
    var parts = std.ArrayList([]const u8).init(allocator);

    var iterator = std.mem.splitSequence(u8, input, delimiter);
    while (iterator.next()) |x| {
        try parts.append(x);
    }

    return parts;
}

pub fn instruction_vs_opcode() !std.StaticStringMap(u8) {
    return std.StaticStringMap(u8).initComptime(
        .{
            .{ "MOV", @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.MOV) },
            .{ "CMP", @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.CMP) },
            .{ "HLT", @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.HLT) },
            .{ "ADD", @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.ADD) },
            .{ "SUB", @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.SUB) },
        }
    );

}

pub fn opcode_vs_instruction(opcode: u8) ?[]const u8 {
    return switch (opcode) {
        0x1, 0x3 => "MOV",
        0x2 => "CMP",
        0x4 => "HLT",
        0x5 => "ADD",
        0x6 => "SUB",
        else => ""
    };
}

pub fn register_vs_opcode() !std.StaticStringMap(u8) {
    return std.StaticStringMap(u8).initComptime(
        .{
            .{ "A", 0x0 },
            .{ "B", 0x1 },
            .{ "C", 0x2 },
            .{ "D", 0x3 },
        }
    );
}

pub fn opcode_vs_register(opcode: u8) ?[]const u8 {
    return switch (opcode) {
        0x0 => "A",
        0x1 => "B",
        0x2 => "C",
        0x3 => "D",
        else => ""
    };
}

pub fn is_alpha(str: []const u8) bool {
    if (str.len == 0) return false; // Empty string is not alphabets only
    
    for (str) |char| {
        if (!std.ascii.isAlphabetic(char)) {
            return false;
        }
    }
    return true;
}
