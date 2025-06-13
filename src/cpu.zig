const std = @import("std");
const Allocator = std.mem.Allocator;

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
    Memory: [256]u8,
    InstructionPointer: ?*u8,
    Flags: Flags = .{},
    Stack: std.ArrayList(u8),
    StackPtr: ?*u8 = null,
    Allocator: Allocator,

    pub fn new(allocator: Allocator) CPU {
        const memory = std.mem.zeroes([256]u8);
        return .{
            .Stack = std.ArrayList(u8).init(allocator),
            .Allocator = allocator,
            .InstructionPointer = null,
            .Memory = memory,
        };
    }

    pub fn push(self: *CPU, item: u8) !void {
        try self.Stack.append(item);
        self.StackPtr = if (self.Stack.items.len > 0) &self.Stack.items[self.Stack.items.len - 1] else null;
    }

    pub fn pop(self: *CPU) !void {
        _ = self.Stack.pop();
        self.StackPtr = if (self.Stack.items.len > 0) &self.Stack.items[self.Stack.items.len - 1] else null;
    }
};
