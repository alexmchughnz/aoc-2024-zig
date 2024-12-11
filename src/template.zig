const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile("input.txt");

const Lines = std.ArrayList([]const u8);

fn parse(buffer: *Lines) !void {
    try buffer.append(std.mem.splitScalar(u8, puzzle_input, '\n').rest());
}

fn part1(input_list: Lines) u64 {
    _ = input_list;
    return 0;
}

fn part2(input_list: Lines) u64 {
    _ = input_list;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = Lines.init(std.heap.page_allocator);
    parse(&input) catch unreachable;

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
