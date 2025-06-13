const std = @import("std");

const RegisterPool = struct {
    A: u8 = 0,
    B: u8 = 0,
    C: u8 = 0,
    D: u8 = 0,
};

const Flags = packed struct {
    zero: bool = false,
    carry: bool = false,
    fault: bool = false,
};

pub const CPU = struct {
    Register: RegisterPool = .{},
    Memory: [256]u8 = std.mem.zeroes([256]u8),
    InstructionPointer: u8 = 0,
    Flags: Flags = .{},
    Stack: std.ArrayList(u8),
    Allocator: std.mem.Allocator,

    pub fn new(allocator: std.mem.Allocator) CPU {
        return .{
            .Stack = std.ArrayList(u8).init(allocator),
            .Allocator = allocator,
        };
    }
};
