const std = @import("std");
const constants = @import("constants.zig");
const cpu = @import("cpu.zig").CPU;
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;

pub const Program = struct {
    file_path: []const u8,
    cpu: cpu,
    allocator: Allocator,
    instruction_vs_opcode: std.StaticStringMap(u8),
    register_vs_opcode: std.StaticStringMap(u8),

    pub fn new(allocator: Allocator, file_path: []const u8) Program {
        return .{
            .file_path = file_path,
            .cpu = cpu.new(allocator),
            .allocator = allocator,
            .instruction_vs_opcode = try utils.instruction_vs_opcode(),
            .register_vs_opcode = try utils.register_vs_opcode(),
        };
    }

    pub fn reg_or_address_or_constant(self: *Program, val: []const u8) constants.OPERANDS {
        if (self.register_vs_opcode.get(val) != null) {
            return constants.OPERANDS.REGISTER;
        } else if (std.mem.startsWith(u8, val, "[") and std.mem.endsWith(u8, val, "]")) {
            return constants.OPERANDS.ADDRESS;
        }
        return constants.OPERANDS.IMMEDIATE;
    }

    pub fn load(self: *Program) !void {
        const file = try std.fs.cwd().openFile(self.file_path, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();
        var file_buffer: [1024]u8 = undefined;

        while (try in_stream.readUntilDelimiterOrEof(file_buffer[0..], '\n')) |line| {
            const splits = try utils.split(self.allocator, line, " ");
            defer splits.deinit();

            if (self.instruction_vs_opcode.get(splits.items[0])) |opcode| {
                switch (opcode) {
                    @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.MOV) => { // MOV
                        // MOV reg, reg
                        // MOV reg, address
                        // MOV reg, constant
                        // MOV address, reg
                        // MOV address, constant

                        if (self.cpu.InstructionPointer + 3 >= constants.MAX_MEMORY) {
                            std.debug.panic("Memory exceeded 256 bytes", .{});
                            break;
                        }

                        var dest = std.mem.trim(u8, splits.items[1], ",");
                        var src = std.mem.trim(u8, splits.items[2], ",");

                        const dest_type = self.reg_or_address_or_constant(dest);
                        const src_type = self.reg_or_address_or_constant(src);

                        switch (dest_type) {
                            constants.OPERANDS.REGISTER => switch (src_type) {
                                // reg reg
                                constants.OPERANDS.REGISTER => {
                                    try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_REGISTER));
                                    if (self.register_vs_opcode.get(dest)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                    if (self.register_vs_opcode.get(src)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                },

                                // reg addr
                                constants.OPERANDS.ADDRESS => {
                                    try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_ADDRESS_TO_REGISTER));
                                    src = src[1..src.len-1];
                                    // try self.cpu.write_to_memory(register_opcode);
                                    if (self.register_vs_opcode.get(dest)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                    if (self.register_vs_opcode.get(src)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                },

                                // reg imm
                                constants.OPERANDS.IMMEDIATE => {
                                    try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_REGISTER));
                                    if (self.register_vs_opcode.get(dest)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                    try self.cpu.write_to_memory(try std.fmt.parseInt(u8, src, 10));
                                },
                            },
                            constants.OPERANDS.ADDRESS => switch (src_type) {
                                // addr reg
                                constants.OPERANDS.REGISTER => {
                                    try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_ADDRESS));
                                    dest = dest[1..dest.len-1];

                                    if (self.register_vs_opcode.get(dest)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                    if (self.register_vs_opcode.get(src)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                },

                                // addr imm
                                constants.OPERANDS.IMMEDIATE => {
                                    try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_ADDRESS));
                                    dest = dest[1..dest.len-1];

                                    if (self.register_vs_opcode.get(dest)) |register_opcode| {
                                        try self.cpu.write_to_memory(register_opcode);
                                    }
                                    try self.cpu.write_to_memory(try std.fmt.parseInt(u8, src, 10));
                                },
                                else => {}
                            },
                            else => {}
                        }
                    },
                    @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.CMP) => { // CMP
                        // TODO: handle all cmp cases
                        const register1 = std.mem.trim(u8, splits.items[1], ",");
                        const register2 = splits.items[2];

                        try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.CMP));
                        if (self.register_vs_opcode.get(register1)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
                        if (self.register_vs_opcode.get(register2)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
                    },
                    @intFromEnum(constants.ABSOLUTE_INSTRUCTION_OPCODE.HLT) => {
                        try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.HLT));
                    },
                    else => {

                    }
                }
            }
        }
        self.cpu.InstructionPointer = 0;
    }

    pub fn run(self: *Program) !void {
        while (self.cpu.InstructionPointer < constants.MAX_MEMORY) {
            const instruction = self.cpu.get_next_executable_instruction();
            self.cpu.increment_instruction_pointer();
            switch (instruction) {
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_REGISTER),
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_REGISTER),
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_ADDRESS_TO_REGISTER),
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_ADDRESS),
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_ADDRESS) => {
                    const dest = self.cpu.get_next_executable_instruction();
                    self.cpu.increment_instruction_pointer();

                    const src = self.cpu.get_next_executable_instruction();
                    self.cpu.increment_instruction_pointer();

                    if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_REGISTER)) {
                        self.cpu.set_register(dest, self.cpu.get_register(src));
                    } else if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REGISTER_TO_ADDRESS)) {
                        self.cpu.Memory[self.cpu.get_register(dest)] = self.cpu.get_register(src);
                    } else if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_ADDRESS_TO_REGISTER)) {
                        self.cpu.set_register(dest, self.cpu.Memory[self.cpu.get_register(src)]);
                    } else if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_ADDRESS)) {
                        self.cpu.set_register(self.cpu.Memory[self.cpu.get_register(dest)], src);
                    } else if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_REGISTER)) {
                        self.cpu.set_register(dest, src);
                    } else {
                        std.debug.panic("Unknown instruction\n", .{});
                    }
                },
                @intFromEnum(constants.INSTRUCTION_OPCODE.HLT) => {
                    return;
                },
                else => {
                    self.cpu.increment_instruction_pointer();
                }
            }
        }
    }

    pub fn deinit(self: *Program) void {
        self.cpu.Stack.deinit();
    }
};


test "program:load" {
    const allocator = std.testing.allocator;
    const expect = std.testing.expect;

    var p = Program.new(allocator, "./source.test.asm");
    try p.load();

    try expect(p.cpu.Memory[0] == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_REGISTER));
    try expect(p.cpu.Memory[1] == @intFromEnum(constants.REGISTER_OPCODE.A));
    try expect(p.cpu.Memory[2] == 0x1);

    try expect(p.cpu.Memory[3] == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_IMMEDIATE_TO_REGISTER));
    try expect(p.cpu.Memory[4] == @intFromEnum(constants.REGISTER_OPCODE.B));
    try expect(p.cpu.Memory[5] == 0x2);

    try expect(p.cpu.Memory[6] == @intFromEnum(constants.INSTRUCTION_OPCODE.CMP));
    try expect(p.cpu.Memory[7] == @intFromEnum(constants.REGISTER_OPCODE.A));
    try expect(p.cpu.Memory[8] == @intFromEnum(constants.REGISTER_OPCODE.B));
}

test "program:run" {
    const allocator = std.testing.allocator;
    const expect = std.testing.expect;

    var p = Program.new(allocator, "./source.test.asm");
    try p.load();
    try p.run();

    try expect(p.cpu.Register.A == 1);
    try expect(p.cpu.Register.B == 2);
    try expect(p.cpu.Register.C == 0);
    try expect(p.cpu.Register.D == 0);
}
