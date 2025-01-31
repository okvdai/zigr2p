const std = @import("std");
const config = @import("config");
const squirrel = @import("squirrel.zig");

pub var id: IdInterface = undefined;
pub var cb: CbInterface = undefined;

var cbHandle: HMODULE = undefined;

const test_fn = squirrel.SQFunc(@TypeOf(testsqfunc)){
    .squirrelFuncName = "testsqfunc",
    .cppFuncName = "testsqfunc",
    .helpText = "placeholder text",
    .returnTypeString = "void",
    .argTypes = "",
    .unknown1 = 0,
    .devLevel = 0,
    .shortNameMaybe = "testsqfunc",
    .unknown2 = 0,
    .returnType = squirrel.SQReturnType.Default,
    .externalBufferPointer = @ptrFromInt(0),
    .externalBufferSize = 0,
    .unknown3 = 0,
    .unknown4 = 0,
    .funcPtr = &testsqfunc,
};

const HMODULE = std.os.windows.HMODULE;
var NSCreateInterface: *const fn (name: [*:0]const u8, status: ?*Plugin.Status) callconv(.C) ?*const anyopaque = undefined;
var sysintf: *const Sys = undefined;
var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

pub const Plugin = struct {
    pub const Status = enum(u32) { ok, err };
    pub const String = enum(u32) { name, log_name, dep_name, _ };
    pub const Field = enum(u32) { ctx, color, _ };
    pub const Ctx = enum(u32) { dedicated = 0x1, client = 0x2, both = 0x3 };
};

pub const Sys = extern struct {
    const Self = @This();
    vtable: *const VTable,
    const VTable = extern struct {
        Log: *const fn (*const Sys, Module: HMODULE, Level: LogLevel, Message: [*:0]u8) callconv(.C) void,
        Unload: *const fn (*const Sys, Module: HMODULE) callconv(.C) void,
        Reload: *const fn (*const Sys, Module: HMODULE) callconv(.C) void,
    };
    const LogLevel = enum(i32) { INFO, WARN, ERR };
};

pub const IdInterface = extern struct {
    const Self = @This();
    vtable: *const VTable,

    name: [*:0]u8,
    logName: [*:0]u8,
    depName: [*:0]u8,

    const VTable = extern struct {
        GetString: @TypeOf(&GetString) = &GetString,
        GetField: @TypeOf(&GetField) = &GetField,
    };

    export fn GetString(self: *const Self, string: Plugin.String) [*:0]u8 {
        return switch (string) {
            Plugin.String.name => self.name,
            Plugin.String.log_name => self.logName,
            Plugin.String.dep_name => self.depName,
            else => @constCast("ERROR"),
        };
    }
    export fn GetField(_: *const Self, field: Plugin.Field) i64 {
        return switch (field) {
            Plugin.Field.ctx => @intFromEnum(config.ctx),
            Plugin.Field.color => config.color,
            else => 0,
        };
    }

    pub fn new(name: []const u8, logName: []const u8, depName: []const u8) IdInterface {
        const nameZ = std.mem.Allocator.dupeZ(gpa.allocator(), u8, name) catch unreachable;
        const logNameZ = std.mem.Allocator.dupeZ(gpa.allocator(), u8, logName) catch unreachable;
        const depNameZ = std.mem.Allocator.dupeZ(gpa.allocator(), u8, depName) catch unreachable;

        return IdInterface{ .name = nameZ.ptr, .logName = logNameZ.ptr, .depName = depNameZ.ptr, .vtable = &.{} };
    }
};

pub const CbInterface = extern struct {
    const Self = @This();
    vtable: *const VTable,
    var data: PluginNorthstarData = undefined;

    const VTable = extern struct {
        Init: @TypeOf(&Init) = &Init,
        Finalize: @TypeOf(&Finalize) = &Finalize,
        Unload: @TypeOf(&Unload) = &Unload,
        OnSqvmCreated: @TypeOf(&OnSqvmCreated) = &OnSqvmCreated,
        OnSqvmDestroying: @TypeOf(&OnSqvmDestroying) = &OnSqvmDestroying,
        OnLibraryLoaded: @TypeOf(&OnLibraryLoaded) = &OnLibraryLoaded,
        RunFrame: @TypeOf(&RunFrame) = &RunFrame,
    };

    pub const Register = struct {
        pub var Client: *const fn (sqvm: *squirrel.VM, func: @TypeOf(&test_fn), bUnknown: u8) *anyopaque = undefined;
        pub var Server: *const fn (sqvm: *squirrel.VM, func: @TypeOf(&test_fn), bUnknown: u8) *anyopaque = undefined;
    };

    export fn Init(_: *const Self, nsmodule: HMODULE, initData: *const PluginNorthstarData, _: bool) void {
        data = initData.*;
        cbHandle = data.pluginHandle;
        NSCreateInterface = @as(@TypeOf(NSCreateInterface), @ptrCast(std.os.windows.kernel32.GetProcAddress(nsmodule, "CreateInterface")));
        sysintf = @alignCast(@ptrCast(NSCreateInterface("NSSys001", null)));
        sysintf.vtable.Log(sysintf, data.pluginHandle, Sys.LogLevel.INFO, @constCast("Loaded plugin!"));
    }
    export fn Finalize() void {}
    export fn Unload() void {
        sysintf.vtable.Log(sysintf, data.pluginHandle, Sys.LogLevel.INFO, @constCast("Unloading plugin..."));
        _ = gpa.deinit();
    }
    export fn OnSqvmCreated(_: *const Self, sqvm: *squirrel.VM) void {
        switch (sqvm.context) {
            squirrel.Ctx.client => {
                sysintf.vtable.Log(sysintf, data.pluginHandle, Sys.LogLevel.INFO, @constCast("Registering CLIENT function testsqfunc"));
                _ = Register.Client(sqvm, &test_fn, 0);
            },
            squirrel.Ctx.ui => {
                sysintf.vtable.Log(sysintf, data.pluginHandle, Sys.LogLevel.INFO, @constCast("Registering UI function testsqfunc"));
                _ = Register.Client(sqvm, &test_fn, 0);
            },
            squirrel.Ctx.server => {},
            else => {},
        }
    }
    export fn OnSqvmDestroying(_: *const Self, _: *squirrel.VM) void {}
    export fn OnLibraryLoaded(_: *const Self, module: HMODULE, name: [*:0]u8) void {
        if (std.mem.eql(u8, std.mem.span(name), "client.dll")) {
            Register.Client = @ptrFromInt(@intFromPtr(module) + 0x108E0);
        }
        if (std.mem.eql(u8, std.mem.span(name), "server.dll")) {
            Register.Server = @ptrFromInt(@intFromPtr(module) + 0x1DD10);
        }
    }
    export fn RunFrame() void {}

    pub const PluginNorthstarData = struct {
        pluginHandle: HMODULE,
    };

    pub fn new() CbInterface {
        return CbInterface{ .vtable = &.{} };
    }
};

export fn testsqfunc() squirrel.Result {
    sysintf.vtable.Log(sysintf, cbHandle, Sys.LogLevel.INFO, @constCast("Testing..."));
    return squirrel.Result.null;
}
