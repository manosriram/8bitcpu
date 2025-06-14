const std = @import("std");
const ArrayList = std.ArrayList;

pub fn split(allocator: std.mem.Allocator, input: []const u8, delimiter: []const u8) !ArrayList([]const u8) {
    var parts = std.ArrayList([]const u8).init(allocator);

    var iterator = std.mem.splitSequence(u8, input, delimiter);
    while (iterator.next()) |x| {
        try parts.append(x);
    }

    return parts;
}

pub fn initOpcodes() !std.StaticStringMap(u8) {
    return std.StaticStringMap(u8).initComptime(
        .{
            .{ "MOV", 0x01 },
            .{ "CMP", 0x10 },
        }
    );
}

pub fn initRegisterOpcodes() !std.StaticStringMap(u8) {
    return std.StaticStringMap(u8).initComptime(
        .{
            .{ "A", 0x00 },
            .{ "B", 0x01 },
            .{ "C", 0x10 },
            .{ "D", 0x11 },
        }
    );
}
