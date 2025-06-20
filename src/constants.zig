pub const MAX_MEMORY = 0x100; // 256 bytes
                              //
pub const INSTRUCTION_OPCODE = enum(u8) {
    MOV_REG_TO_IMM = 0x1,
    CMP = 0x2,
    MOV_REG_TO_REG = 0x3,
    HLT = 0x4,
    MOV_REG_TO_ADDR = 0x5,
    MOV_ADDR_TO_REG = 0x6,
    MOV_ADDR_TO_IMM = 0x7,
};

pub const REGISTER_OPCODE = enum(u8) {
    A = 0x0,
    B = 0x1,
    C = 0x2,
    D = 0x3,
};

pub const OPERANDS = enum(u8) {
    REGISTER,
    ADDRESS,
    IMMEDIATE, // constant
};
