const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile("example.txt");

const Machine = struct {
    Ax: u64 = 0,
    Ay: u64 = 0,
    Bx: u64 = 0,
    By: u64 = 0,
    X: u64 = 0,
    Y: u64 = 0,
};

const INPUT_DELIMITERS = "=+, ";

fn parseNumbers(line: []const u8) [2]u64 {
    var numbers: [2]u64 = undefined;
    var i: usize = 0;

    var tokens = std.mem.tokenizeAny(u8, line, INPUT_DELIMITERS);
    while (tokens.next()) |t| {
        const n = std.fmt.parseInt(u64, t, 10) catch continue;
        numbers[i] = n;
        i += 1;
    }

    std.debug.assert(i == 2);
    return numbers;
}

fn parse(machines: *std.ArrayList(Machine)) !void {
    var lines = std.mem.splitScalar(u8, puzzle_input, '\n');

    while (lines.peek() != null) {
        const a = parseNumbers(lines.next().?);
        const b = parseNumbers(lines.next().?);
        const prize = parseNumbers(lines.next().?);

        try machines.append(.{
            .Ax = a[0],
            .Ay = a[1],
            .Bx = b[0],
            .By = b[1],
            .X = prize[0],
            .Y = prize[1],
        });

        _ = lines.next(); // discard empty line
    }
}

fn part1(machines: std.ArrayList(Machine)) u64 {
    std.debug.print("{any}\n", .{machines.items});
    return 0;
}

fn part2(machines: std.ArrayList(Machine)) u64 {
    _ = machines;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    var machines = std.ArrayList(Machine).init(std.heap.page_allocator);
    parse(&machines) catch unreachable;

    const start1 = std.time.Instant.now() catch unreachable;
    const answer1 = part1(machines);
    const end1 = std.time.Instant.now() catch unreachable;
    const elapsed1 = end1.since(start1) / std.time.ns_per_ms;
    try stdout.print("Part One = {d} ({d:.1} ms)\n", .{ answer1, elapsed1 });

    const start2 = std.time.Instant.now() catch unreachable;
    const answer2 = part2(machines);
    const end2 = std.time.Instant.now() catch unreachable;
    const elapsed2 = end2.since(start2) / std.time.ns_per_ms;
    try stdout.print("Part Two = {d} ({d:.1} ms)\n", .{ answer2, elapsed2 });
}
