const std = @import("std");
const build_options = @import("build_options");

const input = @embedFile("input.txt");

const XMAS_STR = "XMAS";
const CharGrid = std.ArrayList([]const u8);

fn parse(grid: *CharGrid) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| try grid.append(line);
}

fn part1(grid: CharGrid) u64 {
    for (grid.items) |line| {
        std.debug.print("{s}", .{line});
    }

    return 0;
}

fn part2(grid: CharGrid) u64 {
    _ = grid;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input_grid = CharGrid.init(std.heap.page_allocator);
    parse(&input_grid) catch unreachable;

    const answer1 = part1(input_grid);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input_grid);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
