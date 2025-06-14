const std = @import("std");
const cpu = @import("cpu.zig").CPU;
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;

pub const Program = struct {
    cpu: cpu,
    allocator: Allocator,
    instruction_vs_opcode: std.StaticStringMap(u8),
    register_vs_opcode: std.StaticStringMap(u8),
    // opcode_vs_instruction: std.AutoHashMap(u8, []const u8),

    pub fn new(allocator: Allocator) Program {
        return .{
            .cpu = cpu.new(allocator),
            .allocator = allocator,
            .instruction_vs_opcode = try utils.instruction_vs_opcode(),
            .register_vs_opcode = try utils.register_vs_opcode(),
            // .opcode_vs_instruction = try utils.opcode_vs_instruction(allocator),
        };
    }

    pub fn load(self: *Program) !void {
        const file = try std.fs.cwd().openFile("./source.asm", .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var file_buffer: [1024]u8 = undefined;

        // const instruction_vs_opcode = 
        // const register_vs_opcode = try utils.register_vs_opcode();
        // const opcode_vs_instruction = try utils.opcode_vs_instruction(self.allocator);

        while (try in_stream.readUntilDelimiterOrEof(file_buffer[0..], '\n')) |line| {
            const splits = try utils.split(self.allocator, line, " ");
            defer splits.deinit();

            if (self.instruction_vs_opcode.get(splits.items[0])) |opcode| {
                switch (opcode) {
                    0x1 => { // MOV
                        const register = std.mem.trim(u8, splits.items[1], ",");
                        const val = splits.items[2];

                        if (self.cpu.InstructionPointer + 3 >= utils.MAX_MEMORY) {
                            std.debug.panic("Memory exceeded 256 bytes", .{});
                            break;
                        }

                        try self.cpu.write_to_memory(0x1);
                            // std.debug.print("opcode {s}\n", .{register});
                        if (self.register_vs_opcode.get(register)) |register_opcode| {
                            std.debug.print("opcode {}", .{register_opcode});
                            try self.cpu.write_to_memory(register_opcode);
                        }
                        try self.cpu.write_to_memory(try std.fmt.parseInt(u8, val, 10));

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
                    0x2 => { // CMP
                               // TODO: handle all cmp cases
                        const register1 = std.mem.trim(u8, splits.items[1], ",");
                        const register2 = splits.items[2];
                        std.debug.print("CMP {s} to {s}\n", .{register1, register2});

                        try self.cpu.write_to_memory(0x2);
                        if (self.register_vs_opcode.get(register1)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
                        if (self.register_vs_opcode.get(register2)) |registerOpcode| {
                            try self.cpu.write_to_memory(registerOpcode);
                        }
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
        while (self.cpu.InstructionPointer < utils.MAX_MEMORY) {
            const instruction = self.cpu.get_next_executable_instruction();
            self.cpu.increment_instruction_pointer();
            switch (instruction) {
                0x1 => {
                    const reg = self.cpu.get_next_executable_instruction();
                    std.debug.print("mov from {}\n", .{reg});

                    self.cpu.increment_instruction_pointer();
                    const value = self.cpu.get_next_executable_instruction();
                    self.cpu.increment_instruction_pointer();

                    self.cpu.set_register(reg, value);

                    std.debug.print("register = {}, value = {}\n", .{reg, value});
                },
                0x2 => {

                },
                else => {
                    self.cpu.increment_instruction_pointer();
                }
            }
        }
        std.debug.print("memory -> {any}\n", .{self.cpu.Memory});
        std.debug.print("registers -> {any}\n", .{self.cpu.Register});
    }
};


test "program:load" {
    const allocator = std.testing.allocator;
    const expect = std.testing.expect;

    var p = Program.new(allocator);
    try p.load();

    try expect(p.cpu.Memory[0] == @intFromEnum(utils.INSTRUCTION_OPCODE.MOV));
    try expect(p.cpu.Memory[1] == @intFromEnum(utils.REGISTER_OPCODE.A));
    try expect(p.cpu.Memory[2] == 0x1);

    try expect(p.cpu.Memory[3] == @intFromEnum(utils.INSTRUCTION_OPCODE.MOV));
    try expect(p.cpu.Memory[4] == @intFromEnum(utils.REGISTER_OPCODE.B));
    try expect(p.cpu.Memory[5] == 0x2);

    try expect(p.cpu.Memory[6] == @intFromEnum(utils.INSTRUCTION_OPCODE.CMP));
    try expect(p.cpu.Memory[7] == @intFromEnum(utils.REGISTER_OPCODE.A));
    try expect(p.cpu.Memory[8] == @intFromEnum(utils.REGISTER_OPCODE.B));
}

test "program:run" {
    const allocator = std.testing.allocator;
    const expect = std.testing.expect;

    var p = Program.new(allocator);
    try p.load();
    try p.run();

    try expect(p.cpu.Register.A == 1);
    try expect(p.cpu.Register.B == 2);
    try expect(p.cpu.Register.C == 0);
    try expect(p.cpu.Register.D == 0);
}
