const std = @import("std");
const math = std.math;
const time = std.time;

const build_options = @import("build_options");

const puzzle_input = @embedFile("input.txt");

const Stones = std.ArrayList(u64);
const BlinkResult = [2]?u64;

fn blink(stone: u64) BlinkResult {
    // If 0, set to 1.
    if (stone == 0) {
        return .{ 1, null };
    }

    // If even number of digits, split into two stones.
    const num_digits = math.log10_int(stone) + 1;
    if (num_digits % 2 == 0) {
        const half1 = stone / math.pow(u64, 10, num_digits / 2);
        const half2 = stone % math.pow(u64, 10, num_digits / 2);
        return .{ half1, half2 };
    }

    // No other rules apply.
    return .{ stone * 2024, null };
}

fn part1(input_stones: Stones) u64 {
    const num_blinks = 25;
    var stones = input_stones.clone() catch unreachable;

    for (0..num_blinks) |b| {
        std.debug.print("Blink {d}...\n", .{b + 1});

        var index: usize = 0;
        const length = stones.items.len;

        while (index < length) : (index += 1) {
            const stone: *u64 = &stones.items[index];
            const blink_result = blink(stone.*);

            stone.* = blink_result[0] orelse unreachable;
            if (blink_result[1]) |new_stone| {
                stones.append(new_stone) catch unreachable;
            }
        }
    }

    return stones.items.len;
}

fn part2(input_stones: Stones) u64 {
    const num_blinks = 75;
    var stones = input_stones.clone() catch unreachable;

    var blink_result_map = std.AutoHashMap(u64, BlinkResult).init(std.heap.page_allocator);

    for (0..num_blinks) |b| {
        std.debug.print("Blink {d}...\n", .{b + 1});

        var index: usize = 0;
        const length = stones.items.len;

        while (index < length) : (index += 1) {
            const stone: *u64 = &stones.items[index];

            const blink_result: *BlinkResult = blk: {
                const res = blink_result_map.getOrPut(stone.*) catch unreachable;
                if (!res.found_existing) res.value_ptr.* = blink(stone.*);
                break :blk res.value_ptr;
            };

            stone.* = blink_result[0] orelse unreachable;
            if (blink_result[1]) |new_stone| {
                stones.append(new_stone) catch unreachable;
            }
        }
    }

    return stones.items.len;
}

fn parse(buffer: *Stones) !void {
    var tokens = std.mem.tokenizeAny(u8, puzzle_input, " \n");
    while (tokens.next()) |token| {
        const num = try std.fmt.parseInt(u64, token, 10);
        try buffer.append(num);
    }
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
