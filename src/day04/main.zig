const std = @import("std");

const DAY = 4;
const INPUT = "example.txt";

const XMAS_STR = "XMAS";
const CharGrid = std.ArrayList([]const u8);

fn parse(grid: *CharGrid) !void {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    var lines = std.mem.splitScalar(u8, file, '\n');
    while (lines.next()) |line| try grid.append(line);
}

fn part1(grid: CharGrid) u64 {
    for (grid.items) |line| {
        std.debug.print("{any}", .{line});
    }

    return 0;
}

fn part2(input: CharGrid) u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    var input = CharGrid.init(std.heap.page_allocator);
    parse(&input) catch unreachable;

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
