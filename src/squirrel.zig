const std = @import("std");

pub const Ctx = enum(c_uint) { server, client, ui, _ };
pub const Result = enum(i32) { err = -1, null = 0, not_null = 1 };
pub const Type = struct {
    pub const Int = c_long;
    pub const UInt = c_ulong;
    pub const Float = f32;
    pub const Char = c_char;
    pub const Bool = Type.UInt;
};
pub const SQObjType = enum(c_int) {
    userptr = 0x800,
    vector = 0x40000,
    null = 0x1000001,
    bool = 0x1000008,
    int = 0x5000002,
    float = 0x5000004,
    string = 0x8000010,
    array = 0x8000040,
    closure = 0x8000100,
    nativeclosure = 0x8000200,
    asset = 0x8000400,
    thread = 0x8001000,
    protofn = 0x8002000,
    class = 0x8004000,
    strct = 0x8200000,
    weakref = 0x8010000,
    table = 0xA000020,
    userdata = 0xA000080,
    instance = 0xA008000,
    entity = 0xA400000,
};
pub const SQObj = extern struct {
    Type: SQObjType,
    StructNumber: c_int,
    Value: extern union { userdata: ?*anyopaque },
};
pub const SQReturnType = enum(c_int) {
    Float = 0x1,
    Vector = 0x3,
    Integer = 0x5,
    Boolean = 0x6,
    Entity = 0xD,
    String = 0x21,
    Default = 0x20,
    Array = 0x25,
    Asset = 0x28,
    Table = 0x26,
};
pub const VM = extern struct {
    vtable: ?*anyopaque,
    sqvm: ?*anyopaque,
    gap_10: [8]u8,
    unkObj: SQObj,
    unk: i64,
    gap_30: [12]u8,
    context: Ctx,
    gap_40: [648]u8,
    formatString: ?*const fn (i64, [*:0]const u8, ...) callconv(.C) [*:0]u8,
    gap_2D0: [24]u8,
};

pub fn SQFunc(T: type) type {
    return extern struct {
        squirrelFuncName: [*:0]const u8,
        cppFuncName: [*:0]const u8,
        helpText: [*:0]const u8,
        returnTypeString: [*:0]const u8,
        argTypes: [*:0]const u8,
        unknown1: u32,
        devLevel: u32,
        shortNameMaybe: [*:0]const u8,
        unknown2: u32,
        returnType: SQReturnType,
        externalBufferPointer: *allowzero u32,
        externalBufferSize: u64,
        unknown3: u64,
        unknown4: u64,
        funcPtr: *const T,
    };
}
