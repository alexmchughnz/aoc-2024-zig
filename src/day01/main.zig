const std = @import("std");

const DAY = 1;
const INPUT = "input.txt";

fn parse(list1: *std.ArrayList(i64), list2: *std.ArrayList(i64)) !void {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    var lines = std.mem.splitScalar(u8, file, '\n');

    while (lines.next()) |line| {
        var numbers = std.mem.splitSequence(u8, line, "   ");
        const number1 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const number2 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        try list1.append(number1);
        try list2.append(number2);
    }
}

fn part1() !u64 {
    var list1 = std.ArrayList(i64).init(std.heap.page_allocator);
    var list2 = std.ArrayList(i64).init(std.heap.page_allocator);
    parse(&list1, &list2) catch |err| {
        std.debug.print("{any}", .{err});
    };

    std.mem.sort(i64, list1.items, {}, std.sort.asc(i64));
    std.mem.sort(i64, list2.items, {}, std.sort.asc(i64));

    var sum_of_differences: u64 = 0;
    for (0..list1.items.len) |i| {
        const diff: i64 = list1.items[i] - list2.items[i];
        sum_of_differences += @abs(diff);
    }

    return sum_of_differences;
}

fn part2() !i64 {
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    const answer1 = try part1();
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2();
    try stdout.print("Part Two = {d}\n", .{answer2});
}
