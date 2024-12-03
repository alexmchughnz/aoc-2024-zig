const std = @import("std");

const DAY = 1;
const INPUT = "input.txt";

const LinesList = std.ArrayList([]const u8);

fn parse(buffer: *LinesList) !void {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    const lines = std.mem.splitScalar(u8, file, '\n');
    try buffer.append(lines.rest());
}

fn part1(input: LinesList) !u64 {
    _ = input;
    return 0;
}

fn part2(input: LinesList) !u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    var input = LinesList.init(std.heap.page_allocator);
    try parse(&input);

    const answer1 = try part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
