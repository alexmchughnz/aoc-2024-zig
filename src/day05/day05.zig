const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const PageRule = struct {
    a: u64,
    b: u64,
};
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
        sum_of_middles += middle;
    }
    return sum_of_middles;
}

const Ordering = enum {
    GoesBefore,
    GoesAfter,
};

fn getOrdering(p1: u64, p2: u64, rules: []PageRule) ?Ordering {
    const result: ?Ordering = for (rules) |rule| {
        if (std.mem.eql(u64, &.{ rule.a, rule.b }, &.{ p1, p2 })) break Ordering.GoesBefore;
        if (std.mem.eql(u64, &.{ rule.a, rule.b }, &.{ p2, p1 })) break Ordering.GoesAfter;
    } else null;

    std.debug.print("{d} {s} [{d}]!\n", .{
        p1,
        if (result == .GoesAfter) "is after" else "is before",
        p2,
    });

    return result;
}

fn part2(rules: []PageRule, lists: []PageList) u64 {
    var corrected_lists = std.ArrayList(PageList).init(std.heap.page_allocator);
    for (lists) |list| {
        if (!is_list_valid(list, rules)) {
            std.debug.print("\n\nFound invalid list! {any}\n", .{list});

            // Do the reordering.
            var new_list = std.ArrayList(u64).init(std.heap.page_allocator);

            page_loop: for (list) |page| {
                if (new_list.items.len == 0) {
                    new_list.append(page) catch unreachable;
                    continue;
                }

                std.debug.print("\nNew list = {any}\n", .{new_list.items});
                std.debug.print("Inserting {d}... \n", .{page});

                const initial_order = getOrdering(page, new_list.items[0], rules).?;

                var order = initial_order;
                var index: u64 = 0;
                while (order == initial_order) {

                    // Move index.
                    switch (order) {
                        .GoesAfter => index += 1,
                        .GoesBefore => index -|= 1,
                    }

                    // Bounds check.
                    if (index == 0) {
                        new_list.insert(0, page) catch unreachable;
                        std.debug.print("Inserted at start. \n", .{});
                        continue :page_loop;
                    }
                    if (index >= new_list.items.len) {
                        new_list.append(page) catch unreachable;
                        std.debug.print("Inserted at end. \n", .{});
                        continue :page_loop;
                    }

                    // Compare with next item.
                    order = getOrdering(page, new_list.items[index], rules).?;
                }

                // Insert item within existing items.
                new_list.insert(index, page) catch unreachable;
                std.debug.print("Inserted at index {d}. \n", .{index});
            }

            // All pages have been added in the correct order.
            std.debug.assert(list.len == new_list.items.len);
            corrected_lists.append(new_list.toOwnedSlice() catch unreachable) catch unreachable;
        }
    }

    var sum_of_middles: u64 = 0;
    for (corrected_lists.items) |list| {
        const middle = list[list.len / 2];
        sum_of_middles += middle;
    }
    return sum_of_middles;
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
