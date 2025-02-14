const std = @import("std");
const PluginCtx = @import("src/interfaces.zig").Plugin.Ctx;

pub fn build(b: *std.Build) void {
    var buf: [1024]u8 = undefined;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const name = b.option([]const u8, "name", "Plugin name") orelse {
        std.debug.print("Missing required parameter: 'name'\n", .{});
        std.process.exit(1);
    };
    const logName = b.option([]const u8, "logName", "Plugin log name (displayed in the Northstar console)") orelse std.ascii.upperString(&buf, name);
    const depName = b.option([]const u8, "depName", "Plugin dependency name (other plugins use this to identify your plugin)") orelse name;

    const ctx = b.option(PluginCtx, "ctx", "Sets the context of the plugin.") orelse {
        std.debug.print("Missing required parameter: 'ctx'", .{});
        std.process.exit(1);
    };
    const color = b.option(u32, "color", "Plugin log color") orelse 0;

    const options = b.addOptions();

    options.addOption([]const u8, "name", name);
    options.addOption([]const u8, "logName", logName);
    options.addOption([]const u8, "depName", depName);
    options.addOption(PluginCtx, "ctx", ctx);
    options.addOption(u32, "color", color);

    const lib = b.addSharedLibrary(.{ .name = name, .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize, .version = .{ .major = 0, .minor = 0, .patch = 1 } });
    lib.root_module.addOptions("config", options);
    b.installArtifact(lib);
}
