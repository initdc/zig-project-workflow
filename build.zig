const std = @import("std");
const Pkg = std.build.Pkg;

const hello = Pkg{ 
    .name = "hello", 
    .source = .{
        .path = "lib/hello.zig",
    }
};

const world = Pkg{ 
    .name = "world", 
    .source = .{
        .path = "lib/world.zig",
    }, 
    .dependencies = &[_]Pkg{hello} 
};

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    b.setPreferredReleaseMode(.Debug);
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    // add src and test files
    // lib part
    const lib_hello = b.addStaticLibrary("hello", "lib/hello.zig");
    lib_hello.setBuildMode(mode);
    lib_hello.install();

    const lib_world = b.addStaticLibrary("world", "lib/world.zig");
    lib_world.setBuildMode(mode);
    lib_hello.install();

    const lib_hello_tests = b.addTest("lib/hello.zig");
    lib_hello_tests.setBuildMode(mode);

    const lib_world_tests = b.addTest("lib/world.zig");
    lib_world_tests.addPackage(hello);
    lib_world_tests.setBuildMode(mode);

    // exe part
    const exe = b.addExecutable("zig-demo", "src/main.zig");
    exe.addPackage(world);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.addPackage(world);
    exe_tests.setBuildMode(mode);

    // integ test
    const integ_tests = b.addTest("test/integ_hello.zig");
    integ_tests.addPackage(hello);
    integ_tests.addPackage(world);
    integ_tests.setBuildMode(mode);

    // run exe
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // run steps
    const lib_hello_step = b.step("test-hello", "Run unit hello tests");
    lib_hello_step.dependOn(&lib_hello_tests.step);

    const lib_world_step = b.step("test-world", "Run unit world tests");
    lib_world_step.dependOn(&lib_world_tests.step);

    const exe_test_step = b.step("test", "Run main tests");
    exe_test_step.dependOn(&exe_tests.step);

    const integ_test_step = b.step("test-integ", "Run integ tests");
    integ_test_step.dependOn(&integ_tests.step);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
