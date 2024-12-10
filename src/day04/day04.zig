const std = @import("std");
const array_grid = @import("array_grid");

const build_options = @import("build_options");

const input = @embedFile("input.txt");

const XMAS_STR = "XMAS";
const CharGrid = array_grid.ArrayGrid(u8);

fn parse(grid: *CharGrid) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| try grid.rows.append(line);
}

fn part1(grid: CharGrid) u64 {
    for (grid.rows.items) |line| {
        std.debug.print("{s}\n", .{line});
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
