const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    // Create an executable for each day.
    var day: u8 = 1;
    while (day <= 25) : (day += 1) {
        const day_title = b.fmt("day{:0>2}", .{day});
        const day_file = b.fmt("src/{s}/{s}.zig", .{day_title} ** 2);

        const exe = b.addExecutable(.{ .name = day_title, .root_source_file = b.path(day_file), .target = target });

        // Add build options.
        const options = b.addOptions();
        options.addOption(u8, "day", day);
        exe.root_module.addOptions("build_options", options);

        // Add lib modules.
        const array_grid = b.addModule("array_grid", .{ .root_source_file = b.path("src/lib/array_grid.zig") });
        exe.root_module.addImport("array_grid", array_grid);

        // Add install step.
        const install_cmd = b.addInstallArtifact(exe, .{});

        const install_step_name = b.fmt("install_{s}", .{day_title});
        const install_step_desc = b.fmt("Install {s}.exe", .{day_title});
        const install_step = b.step(install_step_name, install_step_desc);
        install_step.dependOn(&install_cmd.step);

        // Add run step.
        const run_cmd = b.addRunArtifact(exe);

        const run_step_name = b.fmt("{s}", .{day_title});
        const run_step_desc = b.fmt("Run {s}", .{day_title});
        const run_step = b.step(run_step_name, run_step_desc);
        run_step.dependOn(&run_cmd.step);
    }

    // `zig build clean`
    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(b.install_path).step);
    clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot(".zig-cache")).step);
}
