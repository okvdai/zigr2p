const std = @import("std");
const squirrel = @import("squirrel.zig");
const interfaces = @import("interfaces.zig");
const config = @import("config");
const windows = std.os.windows;

export fn CreateInterface(name: [*:0]const u8, status: ?*interfaces.Plugin.Status) ?*const anyopaque {
    if (std.mem.eql(u8, std.mem.span(name), "PluginId001")) {
        if (status) |ptr| {
            ptr.* = interfaces.Plugin.Status.ok;
        }
        interfaces.id = interfaces.IdInterface.new(config.name, config.logName, config.depName);
        const ptr: *interfaces.IdInterface = &interfaces.id;
        return ptr;
    }
    if (std.mem.eql(u8, std.mem.span(name), "PluginCallbacks001")) {
        if (status) |ptr| {
            ptr.* = interfaces.Plugin.Status.ok;
        }
        interfaces.cb = interfaces.CbInterface.new();
        const ptr: *interfaces.CbInterface = &interfaces.cb;
        return ptr;
    }
    if (status) |ptr| {
        ptr.* = interfaces.Plugin.Status.err;
    }
    return null;
}
