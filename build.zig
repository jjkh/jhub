const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const log_level = b.option(std.log.Level, "log-level", "Override the default log level");

    const options = b.addOptions();
    // options.contents.appendSlice(b.allocator, "const log = @import(\"std\").log;\n") catch @panic("OOM");
    options.addOption(?u2, "log_level", if (log_level) |ll| @intFromEnum(ll) else null);

    const jhub_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .root_source_file = b.path("src/main.zig"),
    });
    jhub_mod.addOptions("options", options);

    const hidapi_dep = b.dependency("hidapi", .{});
    addHidApiSources(b, jhub_mod, hidapi_dep);

    const args_dep = b.dependency("args", .{ .target = target, .optimize = optimize });
    jhub_mod.addImport("args", args_dep.module("args"));

    const jhub_exe = b.addExecutable(.{
        .name = "jhub",
        .root_module = jhub_mod,
    });
    b.installArtifact(jhub_exe);

    const run_cmd = b.addRunArtifact(jhub_exe);
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run jhub").dependOn(&run_cmd.step);
}

fn addHidApiSources(b: *std.Build, mod: *std.Build.Module, hidapi_dep: *std.Build.Dependency) void {
    const os = mod.resolved_target.?.result.os.tag;

    // add source files for hidapi
    if (os.isDarwin()) {
        mod.linkFramework("CoreFoundation", .{});
        mod.linkFramework("IOKit", .{});
        mod.addCSourceFile(.{ .file = hidapi_dep.path("mac/hid.c") });
    } else if (os == .windows) {
        mod.addCSourceFile(.{ .file = hidapi_dep.path("windows/hid.c") });
    } else {
        // TODO: support the libudev backend for Linux
        if (b.lazyDependency("libusb", .{
            .target = mod.resolved_target,
            .optimize = mod.optimize,
            .@"system-libudev" = false,
        })) |libusb_dep|
            mod.linkLibrary(libusb_dep.artifact("usb"));
        mod.addCSourceFile(.{ .file = hidapi_dep.path("libusb/hid.c") });
    }

    // add include path for hidapi.h
    mod.addIncludePath(hidapi_dep.path("hidapi"));
}
