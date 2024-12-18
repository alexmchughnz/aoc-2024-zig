const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile("input.txt");

const FileBlock = ?u64;
const FileBlockList = std.ArrayList(FileBlock);

fn part1(files: FileBlockList) u64 {
    var L: usize = 0;
    var R: usize = files.items.len - 1;

    while (true) {
        while (files.items[L] != null) L += 1;
        while (files.items[R] == null) R -= 1;
        if (R <= L) break;

        files.items[L] = files.items[R];
        files.items[R] = null;
        // std.debug.print("{any}\n", .{files.items});
    }

    var checksum: u64 = 0;
    for (0.., files.items) |index, file| {
        if (file) |id| {
            checksum += index * id;
        }
    }
    return checksum;
}

fn part2(files: FileBlockList) u64 {
    _ = files;
    return 0;
}

fn parse(files: *FileBlockList) !void {
    var id: u64 = 0;

    for (0.., puzzle_input) |i, c| {
        const size = std.fmt.charToDigit(c, 10) catch continue;
        if (i % 2 == 0) {
            // Add files.
            try files.appendNTimes(id, size);
            id += 1;
        } else {
            // Add empty entries.
            try files.appendNTimes(null, size);
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var files = FileBlockList.init(std.heap.page_allocator);
    defer files.clearAndFree();
    parse(&files) catch unreachable;

    const start1 = std.time.Instant.now() catch unreachable;
    const answer1 = part1(files);
    const end1 = std.time.Instant.now() catch unreachable;
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = std.time.Instant.now() catch unreachable;
    const answer2 = part2(files);
    const end2 = std.time.Instant.now() catch unreachable;
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
