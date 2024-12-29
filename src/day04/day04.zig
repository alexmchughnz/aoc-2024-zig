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

fn part1(grid: CharGrid) !u64 {
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

fn part2(grid: CharGrid) !u64 {
    var count: u64 = 0;

    var iterator = grid.iterator();
    while (iterator.next()) |index| {
        const current_char = try grid.at(index);
        if (current_char != 'A') continue;

        const valid_xmas = inline for (.{ GridDirection.UpLeft, GridDirection.DownLeft }) |dir| {
            const first = grid.at(index.addDirection(dir)) catch break false;
            const last = grid.at(index.addDirection(dir.opposite())) catch break false;

            switch (first) {
                'M' => if (last != 'S') break false,
                'S' => if (last != 'M') break false,
                else => break false,
            }
        } else true;

        if (valid_xmas) count += 1;
    }

    return count;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = CharGrid.init(std.heap.page_allocator);
    try parse(&input);

    const answer1 = try part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
