const std = @import("std");
const PluginCtx = @import("src/interfaces.zig").Plugin.Ctx;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const name = b.option([]const u8, "name", "Plugin name") orelse {
        std.debug.print("Missing required parameter: 'name'\n", .{});
        std.process.exit(1);
    };
    const logName = b.option([]const u8, "logName", "Plugin log name (displayed in the Northstar console)") orelse name;
    const depName = b.option([]const u8, "depName", "Plugin dependency name (other plugins use this to identify your plugin)") orelse name;

    const ctx = b.option(PluginCtx, "ctx", "Sets the context of the plugin.") orelse {
        std.debug.print("Missing required parameter: 'ctx'", .{});
        std.process.exit(1);
    };

    const options = b.addOptions();

    options.addOption([]const u8, "name", name);
    options.addOption([]const u8, "logName", logName);
    options.addOption([]const u8, "depName", depName);
    options.addOption(PluginCtx, "ctx", ctx);

    const lib = b.addSharedLibrary(.{ .name = name, .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize, .version = .{ .major = 0, .minor = 0, .patch = 0 } });
    lib.root_module.addOptions("config", options);
    b.installArtifact(lib);
    const run_cmd = b.addRunArtifact(lib);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
