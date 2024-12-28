const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

fn part1(list1: []u64, list2: []u64) !u64 {
    std.mem.sort(u64, list1, {}, std.sort.asc(u64));
    std.mem.sort(u64, list2, {}, std.sort.asc(u64));

    var sum_of_differences: u64 = 0;
    for (0..list1.len) |i| {
        const n1: i64 = @intCast(list1[i]);
        const n2: i64 = @intCast(list2[i]);
        sum_of_differences += @intCast(@abs(n1 - n2));
    }

    return sum_of_differences;
}

fn part2(list1: []u64, list2: []u64) !u64 {
    var similarity_score: u64 = 0;

    for (list1) |num| {
        var count: u64 = 0;
        for (list2) |r| {
            if (r == num) count += 1;
        }
        similarity_score += (num * count);
    }

    return similarity_score;
}

fn parse(list1: *std.ArrayList(u64), list2: *std.ArrayList(u64)) !void {
    var lines = std.mem.splitScalar(u8, puzzle_input, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;
        var numbers = std.mem.splitSequence(u8, line, "   ");
        const number1 = try std.fmt.parseInt(u64, numbers.next().?, 10);
        const number2 = try std.fmt.parseInt(u64, numbers.next().?, 10);
        try list1.append(number1);
        try list2.append(number2);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var list1 = std.ArrayList(u64).init(std.heap.page_allocator);
    var list2 = std.ArrayList(u64).init(std.heap.page_allocator);
    parse(&list1, &list2) catch unreachable;

    const answer1 = try part1(list1.items, list2.items);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(list1.items, list2.items);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
