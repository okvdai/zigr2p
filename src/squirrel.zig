pub const Ctx = enum(i64) { server, client, ui };
pub const Result = enum(u32) { err = -1, null = 0, not_null = 1 };
pub const Type = struct {
    pub const Int = c_long;
    pub const UInt = c_ulong;
    pub const Float = f32;
    pub const Char = c_char;
    pub const Bool = Type.UInt;
};
pub const ObjType = enum(u32) { userptr = 0x800, vector = 0x40000, null = 0x1000001, bool = 0x1000008, int = 0x5000002, float = 0x5000004, string = 0x8000010, array = 0x8000040, closure = 0x8000100, nativeclosure = 0x8000200, asset = 0x8000400, thread = 0x8001000, protofn = 0x8002000, class = 0x8004000, strct = 0x8200000, weakref = 0x8010000, table = 0xA000020, userdata = 0xA000080, instance = 0xA008000, entity = 0xA400000 };
pub const Obj = struct {
    pub const Type = ObjType;
    pub const StructNumber = c_int;
    pub const Value = union { userdata: *void };
};
