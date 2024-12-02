const std = @import("std");

const DAY = 1;
const INPUT = "input.txt";

const InputList = std.ArrayList(u8);

fn parse(input_list: *InputList) !void {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    var lines = std.mem.splitScalar(u8, file, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;
    }
}

fn part1(input: InputList) u64 {
    return 0;
}

fn part2(input: InputList) u64 {
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    var input = InputList.init(std.heap.page_allocator);
    try parse(&input);

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
