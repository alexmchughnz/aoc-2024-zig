const std = @import("std");
const math = std.math;
const time = std.time;

const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const StoneFreq = struct { stone: u64, freq: u64 };
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

fn part1(input_stones: std.ArrayList(u64)) !u64 {
    const num_blinks = 25;
    var stones = try input_stones.clone();

    for (0..num_blinks) |b| {
        std.log.debug("Blink {d}...\n", .{b + 1});

        var index: usize = 0;
        const length = stones.items.len;

        while (index < length) : (index += 1) {
            const stone: *u64 = &stones.items[index];
            const blink_result = blink(stone.*);

            stone.* = blink_result[0] orelse unreachable;
            if (blink_result[1]) |new_stone| {
                try stones.append(new_stone);
            }
        }
    }

    return stones.items.len;
}

fn part2(input_stones: std.ArrayList(u64)) !u64 {
    const num_blinks = 75;

    var stone_freq_map = std.AutoHashMap(u64, u64).init(std.heap.page_allocator);
    for (input_stones.items) |stone| {
        const res = try stone_freq_map.getOrPutValue(stone, 0);
        res.value_ptr.* = 1;
    }

    for (0..num_blinks) |b| {
        std.log.debug("Blink {d}...\n", .{b + 1});

        var additions = std.ArrayList(StoneFreq).init(std.heap.page_allocator);
        defer additions.clearAndFree();

        var it = stone_freq_map.iterator();
        while (it.next()) |entry| {
            const stone = entry.key_ptr.*;
            const freq = entry.value_ptr.*;

            // Clear stone count from map.
            entry.value_ptr.* = 0;

            // Add each new stone, with frequency of the input stone, to additions list.
            const blink_result = blink(stone);
            for (blink_result) |n| {
                if (n) |new_stone| {
                    const addition = StoneFreq{ .stone = new_stone, .freq = freq };
                    try additions.append(addition);
                }
            }
        }

        // Add additions list into map for next blink.
        for (additions.items) |sf| {
            const res = try stone_freq_map.getOrPutValue(sf.stone, 0);
            res.value_ptr.* += sf.freq;
        }
    }

    var totalFreq: u64 = 0;
    var it = stone_freq_map.valueIterator();
    while (it.next()) |freq| totalFreq += freq.*;
    return totalFreq;
}

fn parse(buffer: *std.ArrayList(u64)) !void {
    var tokens = std.mem.tokenizeAny(u8, puzzle_input, " \n");
    while (tokens.next()) |token| {
        const num = try std.fmt.parseInt(u64, token, 10);
        try buffer.append(num);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input = std.ArrayList(u64).init(std.heap.page_allocator);
    try parse(&input);

    const start1 = try std.time.Instant.now();
    const answer1 = try part1(input);
    const end1 = try std.time.Instant.now();
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = try std.time.Instant.now();
    const answer2 = try part2(input);
    const end2 = try std.time.Instant.now();
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
