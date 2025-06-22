pub const MAX_MEMORY = 0x100; // 256 bytes
                              //
pub const INSTRUCTION_OPCODE = enum(u8) {
    MOV_REGISTER_TO_REGISTER = 0x1,
    MOV_ADDRESS_TO_REGISTER = 0x2,
    MOV_IMMEDIATE_TO_REGISTER = 0x3,
    MOV_REGISTER_TO_ADDRESS = 0x4,
    MOV_IMMEDIATE_TO_ADDRESS = 0x5,

    CMP_REGISTER_TO_REGISTER = 0x6,
    CMP_ADDRESS_TO_REGISTER = 0x7,
    CMP_IMMEDIATE_TO_REGISTER = 0x8,
    CMP_REGISTER_TO_ADDRESS = 0x9,
    CMP_IMMEDIATE_TO_ADDRESS = 0xA,

    HLT = 0xB,
    ADD = 0xC,
};

pub const ABSOLUTE_INSTRUCTION_OPCODE = enum(u8) {
    MOV = 0x1,
    CMP = 0x2,
    HLT = 0x3,
    ADD = 0x4,
};

pub const REGISTER_OPCODE = enum(u8) {
    A = 0x0,
    B = 0x1,
    C = 0x2,
    D = 0x3,
};

pub const REGISTER_ADDRESS = enum(u8) {
    A = 0xFB,
    B = 0xFC,
    C = 0xFD,
    D = 0xFE,
};


// 100
pub const OPERANDS = enum(u8) {
    REGISTER = 0x0,
    ADDRESS = 0x1,
    IMMEDIATE = 0x2, // constant
};
