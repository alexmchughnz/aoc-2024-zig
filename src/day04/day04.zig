const std = @import("std");

const build_options = @import("build_options");
const puzzle_input = @embedFile(build_options.input_file);

const array_grid = @import("array_grid");
const GridDirection = array_grid.GridDirection;

const XMAS_STR = "XMAS";
const CharGrid = array_grid.Grid(u8);

fn parse(grid: *CharGrid) !void {
    var lines = std.mem.splitScalar(u8, puzzle_input, '\n');
    while (lines.next()) |line| if (line.len > 0) try grid.rows.append(line);
}

fn part1(grid: CharGrid) u64 {
    var count: u64 = 0;

    var iterator = grid.iterator();
    while (iterator.next()) |index| {
        dir_loop: for (std.enums.values(GridDirection)) |direction| {
            var next = index;
            for (XMAS_STR) |target_char| {
                const char = grid.at(next) catch continue :dir_loop;
                if (char != target_char) continue :dir_loop;

                next = next.addDirection(direction);
            }
            count += 1;
        }
    }
    return count;
}

fn part2(grid: CharGrid) u64 {
    _ = grid;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = CharGrid.init(std.heap.page_allocator);
    parse(&input) catch unreachable;

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
