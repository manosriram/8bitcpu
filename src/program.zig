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
                    0x1 => { // MOV

                        // MOV reg, reg
                        // MOV reg, address
                        // MOV reg, constant
                        // MOV address, reg
                        // MOV address, constant

                        const register = std.mem.trim(u8, splits.items[1], ",");
                        var val = std.mem.trim(u8, splits.items[2], ",");

                        if (self.cpu.InstructionPointer + 3 >= constants.MAX_MEMORY) {
                            std.debug.panic("Memory exceeded 256 bytes", .{});
                            break;
                        }

                        std.debug.print("val = {any}\n", .{val});
                        if (self.register_vs_opcode.get(val) != null) {
                            try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_REG));
                        } else if (std.mem.startsWith(u8, val, "[") and std.mem.endsWith(u8, val, "]")) {
                            try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_ADDR));
                            val = val[1..val.len-1];
                            std.debug.print("got addr\n", .{});
                        } else {
                            try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_IMM));
                        }

                        if (self.register_vs_opcode.get(register)) |register_opcode| {
                            try self.cpu.write_to_memory(register_opcode);
                        }

                        // If val is a register
                        if (self.register_vs_opcode.get(val)) |register_opcode| {
                            try self.cpu.write_to_memory(register_opcode);
                        } else {
                            // TODO: handler [reg] and other cases
                            try self.cpu.write_to_memory(try std.fmt.parseInt(u8, val, 10));
                        }
                    },
                    0x2 => { // CMP
                        // TODO: handle all cmp cases
                        const register1 = std.mem.trim(u8, splits.items[1], ",");
                        const register2 = splits.items[2];
                        // std.debug.print("CMP {s} to {s}\n", .{register1, register2});

                        try self.cpu.write_to_memory(@intFromEnum(constants.INSTRUCTION_OPCODE.CMP));
                        if (self.register_vs_opcode.get(register1)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
                        if (self.register_vs_opcode.get(register2)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
                    },
                    @intFromEnum(constants.INSTRUCTION_OPCODE.HLT) => {
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
        // const instruction = utils.opcode_vs_instruction(0x001).?;
        while (self.cpu.InstructionPointer < constants.MAX_MEMORY) {
            const instruction = self.cpu.get_next_executable_instruction();
            self.cpu.increment_instruction_pointer();
            switch (instruction) {
                @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_IMM), @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_REG), @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_ADDR) => {
                    const reg = self.cpu.get_next_executable_instruction();

                    self.cpu.increment_instruction_pointer();
                    const value = self.cpu.get_next_executable_instruction();

                    self.cpu.increment_instruction_pointer();

                    if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_REG)) {
                        self.cpu.set_register(reg, self.cpu.get_register(value));
                    } else if (instruction == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_ADDR)) {
                        self.cpu.set_register(reg, self.cpu.Memory[self.cpu.get_register(value)]);
                    } else {
                        self.cpu.set_register(reg, value);
                    }
                },
                0x2 => {

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

    try expect(p.cpu.Memory[0] == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_IMM));
    try expect(p.cpu.Memory[1] == @intFromEnum(constants.REGISTER_OPCODE.A));
    try expect(p.cpu.Memory[2] == 0x1);

    try expect(p.cpu.Memory[3] == @intFromEnum(constants.INSTRUCTION_OPCODE.MOV_REG_TO_IMM));
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
