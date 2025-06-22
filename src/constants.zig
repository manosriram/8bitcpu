pub const MAX_MEMORY = 0x100; // 256 bytes

pub const SEPARATOR = ';';

pub const INSTRUCTION_OPCODE = enum(u8) {
    MOV_REGISTER_TO_REGISTER = 0x01,
    MOV_ADDRESS_TO_REGISTER = 0x02,
    MOV_IMMEDIATE_TO_REGISTER = 0x03,
    MOV_REGISTER_TO_ADDRESS = 0x04,
    MOV_IMMEDIATE_TO_ADDRESS = 0x05,

    CMP_REGISTER_TO_REGISTER = 0x06,
    CMP_ADDRESS_TO_REGISTER = 0x07,
    CMP_IMMEDIATE_TO_REGISTER = 0x08,
    CMP_REGISTER_TO_ADDRESS = 0x09,
    CMP_IMMEDIATE_TO_ADDRESS = 0x0A,

    ADD_REGISTER_TO_REGISTER = 0x0B,
    ADD_ADDRESS_TO_REGISTER = 0x0C,
    ADD_IMMEDIATE_TO_REGISTER = 0x0D,
    ADD_REGISTER_TO_ADDRESS = 0x0E,
    ADD_IMMEDIATE_TO_ADDRESS = 0x0F,

    HLT = 0x10,
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
