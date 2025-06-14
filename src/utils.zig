const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

// TODO: move constants to a separate file
pub const MAX_MEMORY = 0x100; // 256 bytes

pub const INSTRUCTION_OPCODE = enum(u8) {
    MOV_REG_TO_IMM = 0x1,
    CMP = 0x2,
    MOV_REG_TO_REG = 0x3,
};

pub const REGISTER_OPCODE = enum(u8) {
    A = 0x0,
    B = 0x1,
    C = 0x2,
    D = 0x3,
};

pub const MOV_OPCODE = 0x1;
pub const CMP_OPCODE = 0x2;

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
            .{ "MOV", MOV_OPCODE },
            .{ "CMP", CMP_OPCODE },
        }
    );

}

pub fn opcode_vs_instruction(opcode: u8) ?[]const u8 {
    return switch (opcode) {
        0x1 => "MOV",
        0x2 => "CMP",
        else => ""
    };
    // var map = std.AutoHashMap(u8, []const u8).init(allocator);
    // try map.put(MOV_OPCODE, "MOV");
    // try map.put(CMP_OPCODE, "CMP");
    // return map;
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
