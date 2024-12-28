const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const PageRule = struct { a: u64, b: u64 };
const PageList = std.ArrayList(u64);

fn part1(rules: std.ArrayList(PageRule), lists: std.ArrayList(PageList)) u64 {
    std.debug.print("{any}\n", .{rules.items});
    std.debug.print("{any}\n", .{lists.items});
    return 0;
}

fn part2(rules: std.ArrayList(PageRule), lists: std.ArrayList(PageList)) u64 {
    _ = rules;
    _ = lists;
    return 0;
}

fn parse(rules: *std.ArrayList(PageRule), lists: *std.ArrayList(PageList)) !void {
    var lines = std.mem.splitScalar(u8, puzzle_input, '\n');

    // Parse rules.
    while (lines.next()) |line| {
        if (line.len == 0) break;

        var page_tokens = std.mem.tokenizeScalar(u8, line, '|');
        var rule: [2]u64 = undefined;
        for (0..rule.len) |i| {
            const page_str = page_tokens.next() orelse unreachable;
            rule[i] = std.fmt.parseInt(u64, page_str, 10) catch unreachable;
        }
        try rules.append(PageRule{ .a = rule[0], .b = rule[1] });
    }

    // Parse page lists.
    while (lines.next()) |line| {
        var page_tokens = std.mem.tokenizeScalar(u8, line, ',');
        var list = PageList.init(std.heap.page_allocator);
        while (page_tokens.next()) |page_str| {
            const page = std.fmt.parseInt(u64, page_str, 10) catch unreachable;
            try list.append(page);
        }
        try lists.append(list);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input_rules = std.ArrayList(PageRule).init(std.heap.page_allocator);
    var input_lists = std.ArrayList(PageList).init(std.heap.page_allocator);
    parse(&input_rules, &input_lists) catch unreachable;

    const start1 = std.time.Instant.now() catch unreachable;
    const answer1 = part1(input_rules, input_lists);
    const end1 = std.time.Instant.now() catch unreachable;
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = std.time.Instant.now() catch unreachable;
    const answer2 = part2(input_rules, input_lists);
    const end2 = std.time.Instant.now() catch unreachable;
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
