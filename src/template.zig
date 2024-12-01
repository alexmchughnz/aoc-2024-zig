const std = @import("std");

const DAY = 1;

fn part1() i64 {
    return 0;
}

fn part2() i64 {
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    const answer1 = part1();
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2();
    try stdout.print("Part Two = {d}\n", .{answer2});
}
