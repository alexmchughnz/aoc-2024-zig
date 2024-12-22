const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const FileBlock = ?u64;
const FileBlockList = std.ArrayList(FileBlock);

const File = struct { id: ?u64, size: u64 };
const FileList = std.ArrayList(File);

fn part1(files: []FileBlock) u64 {
    var L: usize = 0;
    var R: usize = files.len - 1;

    while (true) {
        while (files[L] != null) L += 1;
        while (files[R] == null) R -= 1;
        if (L >= R) break;

        files[L] = files[R];
        files[R] = null;
    }

    var checksum: u64 = 0;
    for (0.., files) |index, file| {
        if (file) |id| {
            checksum += index * id;
        }
    }
    return checksum;
}

fn part2(files: *FileList) u64 {
    var R: usize = files.items.len - 1;

    while (R > 0) : (R -= 1) {
        var L: usize = 0;

        // Find a candidate file to move.
        while (files.items[R].id == null) R -= 1;

        // Find a large enough space for file at R.
        while (L < R) : (L += 1) {
            if (files.items[L].id == null and files.items[L].size >= files.items[R].size) {
                const unused_space = files.items[L].size - files.items[R].size;

                // "Move" file into empty space by swapping ids and sizes.
                files.items[L].id = files.items[R].id;
                files.items[L].size = files.items[R].size;
                files.items[R].id = null;

                // Add new empty space if required.
                if (unused_space > 0) {
                    files.insert(L + 1, File{ .id = null, .size = unused_space }) catch unreachable;
                    R += 1; // Increment R index to account for new item.
                }
                break;
            }
        }
    }

    var checksum: u64 = 0;
    var index: usize = 0;
    for (files.items) |file| {
        for (0..file.size) |_| {
            if (file.id) |id| checksum += index * id;
            index += 1;
        }
    }

    return checksum;
}

fn parseToBlocks(files: *FileBlockList) !void {
    var id: u64 = 0;

    for (0.., puzzle_input) |i, c| {
        const size = std.fmt.charToDigit(c, 10) catch continue;
        if (i % 2 == 0) {
            // Add files.
            try files.appendNTimes(id, size);
            id += 1;
        } else {
            // Add empty entries.
            if (size > 0) {
                try files.appendNTimes(null, size);
            }
        }
    }
}

fn parseToStructs(files: *FileList) !void {
    var next_id: u64 = 0;

    for (0.., puzzle_input) |i, c| {
        const size = std.fmt.charToDigit(c, 10) catch continue;
        var id: ?u64 = null;
        if (i % 2 == 0) {
            id = next_id;
            next_id += 1;
        }
        if (size > 0) {
            try files.append(File{ .id = id, .size = size });
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    {
        var files = FileBlockList.init(std.heap.page_allocator);
        defer files.clearAndFree();
        parseToBlocks(&files) catch unreachable;

        const start1 = std.time.Instant.now() catch unreachable;
        const answer1 = part1(files.items);
        const end1 = std.time.Instant.now() catch unreachable;
        const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
        try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });
    }

    {
        var files = FileList.init(std.heap.page_allocator);
        defer files.clearAndFree();
        parseToStructs(&files) catch unreachable;

        const start2 = std.time.Instant.now() catch unreachable;
        const answer2 = part2(&files);
        const end2 = std.time.Instant.now() catch unreachable;
        const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
        try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
    }
}
