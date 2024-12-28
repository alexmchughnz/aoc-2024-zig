const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const PageRule = struct { a: u64, b: u64 };
const PageList = []u64;

// For each `page` in `list`, check every `rule`.
// If any rules are violated, the list is invalid.
fn is_list_valid(list: PageList, rules: []PageRule) bool {
    for (0.., list) |i_page, page| {
        for (rules) |rule| {
            if (rule.a == page) {
                if (std.mem.indexOfScalar(u64, list, rule.b)) |i_b| {
                    // Invalid if b appears earlier in `list` than a.
                    if (i_b < i_page) return false;
                }
            }
            if (rule.b == page) {
                if (std.mem.indexOfScalar(u64, list, rule.a)) |i_a| {
                    // Invalid if a appears later in `list` than b.
                    if (i_a > i_page) return false;
                }
            }
        }
    }

    // Every `page` has been checked, with zero rule violations!
    return true;
}

fn part1(rules: []PageRule, lists: []PageList) u64 {
    var correct_lists = std.ArrayList(PageList).init(std.heap.page_allocator);

    for (lists) |list| {
        if (is_list_valid(list, rules)) {
            correct_lists.append(list) catch unreachable;
        }
    }

    var sum_of_middles: u64 = 0;
    for (correct_lists.items) |list| {
        const middle = list[list.len / 2];
        std.debug.print("{any} => {d}\n", .{ list, middle });
        sum_of_middles += middle;
    }
    return sum_of_middles;
}

fn part2(rules: []PageRule, lists: []PageList) u64 {
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
    const answer1 = part1(input_rules.items, input_lists.items);
    const end1 = std.time.Instant.now() catch unreachable;
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = std.time.Instant.now() catch unreachable;
    const answer2 = part2(input_rules.items, input_lists.items);
    const end2 = std.time.Instant.now() catch unreachable;
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
