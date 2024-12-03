const std = @import("std");

const DAY = 3;
const INPUT = "input.txt";

fn parse() ![]u8 {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    return file;
}

fn part1(input: []const u8) u64 {
    std.debug.print("{s}\n", .{input});
    return 0;
}

fn part2(input: []const u8) u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    const input: []u8 = try parse();

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
