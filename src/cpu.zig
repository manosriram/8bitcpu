const std = @import("std");
const utils = @import("utils.zig");
const constants = @import("constants.zig");
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
    InstructionPointer: usize,
    Flags: Flags = .{},
    Stack: std.ArrayList(u8),
    StackPtr: ?*u8 = null,
    Allocator: Allocator,

    pub fn new(allocator: Allocator) CPU {
        const memory = std.mem.zeroes([256]u8);
        return .{
            .Stack = std.ArrayList(u8).init(allocator),
            .Allocator = allocator,
            .InstructionPointer = 0,
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

    pub fn write_to_memory(self: *CPU, item: u8) !void {
        self.Memory[self.InstructionPointer] = item;
        self.InstructionPointer += 1;
    }

    pub fn get_next_executable_instruction(self: *CPU) u8 {
        if (self.InstructionPointer > 255) {
            return 0;
        }
        const instruction = self.Memory[self.InstructionPointer];
        switch (instruction) {
            0x1, 0x2 => {
                // TODO: return Instruction
            },
            else => {}
        }
        return instruction;
    }

    pub fn increment_instruction_pointer(self: *CPU) void {
        self.InstructionPointer += 1;
    }

    pub fn set_register(self: *CPU, register_opcode: u8, value: u8) void {
        const register_str = utils.opcode_vs_register(register_opcode);

        if (std.mem.eql(u8, register_str.?, "A")) {
            self.Register.A = value;
        } else if (std.mem.eql(u8, register_str.?, "B")) {
            self.Register.B = value;
        } else if (std.mem.eql(u8, register_str.?, "C")) {
            self.Register.C = value;
        } else if (std.mem.eql(u8, register_str.?, "D")) {
            self.Register.D = value;
        }
    }

    pub fn get_register(self: *CPU, register_opcode: u8) u8 {
        const register_str = utils.opcode_vs_register(register_opcode);

        if (std.mem.eql(u8, register_str.?, "A")) {
            return self.Register.A;
        } else if (std.mem.eql(u8, register_str.?, "B")) {
            return self.Register.B;
        } else if (std.mem.eql(u8, register_str.?, "C")) {
            return self.Register.C;
        } else if (std.mem.eql(u8, register_str.?, "D")) {
            return self.Register.D;
        }
        return 0;
    }

    pub fn set_carry_flag(self: *CPU) void {
        self.Flags.carry = true;
    }

    pub fn set_zero_flag(self: *CPU) void {
        self.Flags.zero = true;
    }
};
