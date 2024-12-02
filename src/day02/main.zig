const std = @import("std");

const DAY = 1;
const INPUT = "input.txt";

const ReportList = std.ArrayList([]u64);

fn parse(report_list: *ReportList) !void {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    var lines = std.mem.splitScalar(u8, file, '\n');

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

fn part1(report_list: ReportList) !u64 {
    var num_safe_reports: u64 = 0;

    for (report_list.items) |levels| {
        const num_diffs = levels.len - 1;
        var diffs = try std.ArrayList(i64).initCapacity(std.heap.page_allocator, num_diffs);
        defer diffs.clearAndFree();

        var is_safe = false;
        for (0..num_diffs) |i| {
            const a: i64 = @intCast(levels[i]);
            const b: i64 = @intCast(levels[i + 1]);
            const diff = b - a;
            try diffs.append(diff);

            is_safe = ((std.math.sign(diff) == std.math.sign(diffs.items[0])) and
                (@abs(diff) > 0) and
                (@abs(diff) <= 3));
            if (!is_safe) break;
        }

        if (is_safe) num_safe_reports += 1;
    }

    return num_safe_reports;
}

fn part2(input: ReportList) u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    var input = ReportList.init(std.heap.page_allocator);
    defer input.clearAndFree();
    try parse(&input);

    const answer1 = try part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
