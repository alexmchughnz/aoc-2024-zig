const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const PageRule = struct { a: u64, b: u64 };
const PageList = []u64;

fn part1(rules: std.ArrayList(PageRule), lists: std.ArrayList(PageList)) u64 {
    var correct_list_indices = std.ArrayList(usize).init(std.heap.page_allocator);
    list_loop: for (0.., lists.items) |i_list, list| {

        // Iterate over each `page` in `list` and check each `rule` is followed.
        for (0.., list) |i_page, page| {
            rule_loop: for (rules.items) |rule| {
                const other_page: ?u64 = if (page == rule.a) rule.b else if (page == rule.b) rule.a else null;
                if (other_page == null) continue :rule_loop; // Ignore rule: `page` not in `rule`.

                const other_result = std.mem.indexOfScalar(u64, list, other_page.?);
                if (other_result) |i_other| {
                    if (page == rule.a) {
                        // Assert b does NOT appear earlier in `list` than a.
                        if (i_other < i_page) continue :list_loop; // This `list` breaks a rule!
                    }

                    if (page == rule.b) {
                        // Assert a does NOT appear later in `list` than b.
                        if (i_other > i_page) continue :list_loop;
                    }
                } else continue :rule_loop; // Ignore rule: `other_page` not in `list`

            }
        }
        // All relevant rules successfully passed!
        correct_list_indices.append(i_list) catch unreachable;
    }

    for (correct_list_indices.items) |i| std.debug.print("{d}: {any}\n", .{ i, lists.items[i] });
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
        if (line.len == 0) break;
        var page_tokens = std.mem.tokenizeScalar(u8, line, ',');
        var list = std.ArrayList(u64).init(std.heap.page_allocator);
        while (page_tokens.next()) |page_str| {
            const page = std.fmt.parseInt(u64, page_str, 10) catch unreachable;
            try list.append(page);
        }
        try lists.append(try list.toOwnedSlice());
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
