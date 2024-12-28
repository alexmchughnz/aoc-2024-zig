const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const Report = []u64;

fn has_problem(levels: []u64) bool {
    var sign: ?i64 = null;

    for (0..levels.len - 1) |i| {
        const a: i64 = @intCast(levels[i]);
        const b: i64 = @intCast(levels[i + 1]);
        const diff = b - a;

        if (sign == null) sign = std.math.sign(diff);

        const problem = ((std.math.sign(diff) != sign) or
            (diff == 0) or
            (@abs(diff) > 3));

        if (problem) return true;
    }

    return false;
}

fn part1(report_list: []Report) !u64 {
    var num_safe_reports: u64 = 0;

    for (report_list) |levels| {
        if (!has_problem(levels)) num_safe_reports += 1;
    }

    return num_safe_reports;
}

fn part2(report_list: []Report) !u64 {
    var num_safe_reports: u64 = 0;

    for (report_list) |levels| {
        var is_safe = true;

        if (has_problem(levels)) {
            // Need to try each sub-list made by removing one item.
            // Report is safe if ANY of these sub-lists are safe.
            is_safe = for (0..levels.len) |remove_index| {
                var reduced_levels = std.ArrayList(u64).init(std.heap.page_allocator);
                defer reduced_levels.clearAndFree();

                try reduced_levels.appendSlice(levels);
                _ = reduced_levels.orderedRemove(remove_index);
                if (!has_problem(reduced_levels.items)) {
                    break true;
                }
            } else false;
        }

        if (is_safe) num_safe_reports += 1;
    }

    return num_safe_reports;
}

fn parse(report_list: *std.ArrayList(Report)) !void {
    var lines = std.mem.splitScalar(u8, puzzle_input, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var level_list = std.ArrayList(u64).init(std.heap.page_allocator);

        var level_strings = std.mem.splitScalar(u8, line, ' ');
        while (level_strings.next()) |str| {
            const n = try std.fmt.parseInt(u64, str, 10);
            try level_list.append(n);
        }

        try report_list.*.append(try level_list.toOwnedSlice());
    }
}
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = std.ArrayList(Report).init(std.heap.page_allocator);
    defer input.clearAndFree();
    try parse(&input);

    const answer1 = try part1(input.items);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(input.items);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
