const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile("input.txt");

const Stones = std.ArrayList(u64);

fn parse(buffer: *Stones) !void {
    var tokens = std.mem.tokenizeAny(u8, puzzle_input, " \n");
    while (tokens.next()) |token| {
        const num = try std.fmt.parseInt(u64, token, 10);
        try buffer.append(num);
    }
}

fn part1(stones: Stones) u64 {
    std.debug.print("{any}\n", .{stones.items});
    return 0;
}

fn part2(stones: Stones) u64 {
    _ = stones;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = Stones.init(std.heap.page_allocator);
    parse(&input) catch unreachable;

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
