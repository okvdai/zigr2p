const interfaces = @import("interfaces.zig");
const squirrel = @import("squirrel.zig");
const std = @import("std");

pub const Declaration = struct {
    name: []u8,
    funcPtr: *const fn () callconv(.C) squirrel.Result,
    argTypes: [*:0]const u8,
    returnType: squirrel.SQReturnType,
    returnTypeString: [*:0]const u8,
    ctx: squirrel.Ctx,
};

pub var Declarations: std.ArrayListAligned(Declaration, null) = undefined;

pub fn Register(sqvm: *squirrel.VM) void {
    switch (sqvm.context) {
        squirrel.Ctx.client, squirrel.Ctx.ui => {
            for (Declarations.items) |decl| {
                if (decl.ctx == squirrel.Ctx.client or decl.ctx == squirrel.Ctx.ui) {
                    interfaces.clRelay.register(sqvm, squirrel.SQFunc.New(decl.name, decl.funcPtr, decl.argTypes, decl.returnType, decl.returnTypeString), 0);
                    interfaces.sysintf.vtable.Log(interfaces.sysintf, interfaces.cbHandle, interfaces.Sys.LogLevel.INFO, decl.name);
                }
            }
        },
        squirrel.Ctx.server => {
            for (Declarations.items) |decl| {
                if (decl.ctx == squirrel.Ctx.server) {
                    interfaces.svRelay.register(sqvm, squirrel.SQFunc.New(decl.name, decl.funcPtr, decl.argTypes, decl.returnType, decl.returnTypeString), 0);
                }
            }
        },
        else => {},
    }
}
