const std = @import("std");
const squirrel = @import("squirrel.zig");
const HMODULE = std.os.windows.HMODULE;

pub const Plugin = struct {
    pub const Status = enum(u32) { ok, err };
    pub const String = enum(u32) { name, log_name, dep_name, _ };
    pub const Field = enum(u32) { ctx, color, _ };
    pub const Ctx = enum(u32) { dedicated = 0x1, client = 0x2, both = 0x3 };
};

pub const Sys = extern struct {
    const Self = @This();
    vtable: *const VTable,
    const VTable = extern struct {};
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
            Plugin.Field.ctx => @intFromEnum(Plugin.Ctx.client),
            Plugin.Field.color => 0,
            else => 0,
        };
    }

    pub fn new(name: [*:0]u8, logName: [*:0]u8, depName: [*:0]u8) IdInterface {
        return IdInterface{ .name = name, .logName = logName, .depName = depName, .vtable = &.{} };
    }
};

pub const CallbackInterface = extern struct {
    const Self = @This();
    vtable: *const VTable,

    const VTable = extern struct {
        Init: @TypeOf(&Init) = &Init,
        Finalize: @TypeOf(&Finalize) = &Finalize,
        Unload: @TypeOf(&Unload) = &Unload,
        OnSqvmCreated: @TypeOf(&OnSqvmCreated) = &OnSqvmCreated,
        OnSqvmDestroying: @TypeOf(&OnSqvmDestroying) = &OnSqvmDestroying,
        OnLibraryLoaded: @TypeOf(&OnLibraryLoaded) = &OnLibraryLoaded,
        RunFrame: @TypeOf(&RunFrame) = &RunFrame,
    };

    export fn Init(_: HMODULE, _: *const PluginNorthstarData, _: bool) void {}
    export fn Finalize() void {}
    export fn Unload() void {}
    export fn OnSqvmCreated(_: *anyopaque) void {}
    export fn OnSqvmDestroying(_: *anyopaque) void {}
    export fn OnLibraryLoaded(_: HMODULE, _: [*:0]u8) void {}
    export fn RunFrame() void {}

    pub const PluginNorthstarData = struct {
        pluginHandle: HMODULE,
    };

    pub fn new() CallbackInterface {
        return CallbackInterface{ .vtable = &.{} };
    }
};
