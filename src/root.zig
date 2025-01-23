const std = @import("std");
const squirrel = @import("./squirrel.zig");
const interfaces = @import("interfaces.zig");
const config = @import("config");
const windows = std.os.windows;

var idintf: interfaces.IdInterface = undefined;
var cbintf: interfaces.CallbackInterface = undefined;

export fn CreateInterface(name: [*:0]const u8, status: ?*interfaces.Plugin.Status) ?*const anyopaque {
    if (std.mem.eql(u8, std.mem.span(name), "PluginId001")) {
        if (status) |ptr| {
            ptr.* = interfaces.Plugin.Status.ok;
        }
        idintf = interfaces.IdInterface.new(config.name, config.logName, config.depName);
        const ptr: *interfaces.IdInterface = &idintf;
        return ptr;
    }
    if (std.mem.eql(u8, std.mem.span(name), "PluginCallbacks001")) {
        if (status) |ptr| {
            ptr.* = interfaces.Plugin.Status.ok;
        }
        cbintf = interfaces.CallbackInterface.new();
        const ptr: *interfaces.CallbackInterface = &cbintf;
        return ptr;
    }
    if (status) |ptr| {
        ptr.* = interfaces.Plugin.Status.err;
    }
    return null;
}
