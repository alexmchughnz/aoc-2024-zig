const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const Type = []const u8;

fn part1(inputs: []Type) !u64 {
    _ = inputs;
    return 0;
}

fn part2(inputs: []Type) !u64 {
    _ = inputs;
    return 0;
}

fn parse(buffer: *std.ArrayList(Type)) !void {
    try buffer.append(std.mem.splitScalar(u8, puzzle_input, '\n').rest());
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var input_list = Type.init(std.heap.page_allocator);
    try parse(&input_list);

    const start1 = try std.time.Instant.now();
    const answer1 = try part1(input_list.items);
    const end1 = try std.time.Instant.now();
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = try std.time.Instant.now();
    const answer2 = try part2(input_list.items);
    const end2 = try std.time.Instant.now();
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
