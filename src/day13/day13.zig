const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile(build_options.input_file);

const Vec2 = [2]i64;

const VecError = error{ NoSolution, NonIntegerSolution };

const Machine = struct {
    Ax: i64 = 0,
    Ay: i64 = 0,
    Bx: i64 = 0,
    By: i64 = 0,
    X: i64 = 0,
    Y: i64 = 0,
};

const INPUT_DELIMITERS = "=+, ";
const A_COST = 3;
const B_COST = 1;

fn parseNumbers(line: []const u8) Vec2 {
    var numbers: Vec2 = undefined;
    var i: usize = 0;

    var tokens = std.mem.tokenizeAny(u8, line, INPUT_DELIMITERS);
    while (tokens.next()) |t| {
        const n = std.fmt.parseInt(i64, t, 10) catch continue;
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

fn solve(m: Machine) !Vec2 {
    const det = m.Ax * m.By - m.Bx * m.Ay;
    if (det == 0) return VecError.NoSolution;

    // Solutions via Cramer's rule.
    const a = std.math.divExact(i64, (m.X * m.By - m.Bx * m.Y), det) catch return VecError.NonIntegerSolution;
    const b = std.math.divExact(i64, (m.Ax * m.Y - m.X * m.Ay), det) catch return VecError.NonIntegerSolution;
    return .{ a, b };
}

fn part1(machines: std.ArrayList(Machine)) i64 {
    var total_cost: i64 = 0;

    for (1.., machines.items) |i, m| {
        //  |Ax Bx| [a]  = [X]
        //  |Ay By| [b]  = [Y]

        std.debug.print("Machine #{d}: ", .{i});
        const sol = solve(m) catch {
            std.debug.print("Impossible!\n", .{});
            continue;
        };

        const a = sol[0];
        const b = sol[1];
        const cost = a * A_COST + b * B_COST;

        std.debug.print("{d} A presses + {d} B presses == {d} tokens.\n", .{ a, b, cost });
        total_cost += cost;
    }

    return total_cost;
}

fn part2(machines: std.ArrayList(Machine)) i64 {
    var total_cost: i64 = 0;

    for (1.., machines.items) |i, m| {
        //  |Ax Bx| [a]  = [X + 10000000000000]
        //  |Ay By| [b]  = [Y + 10000000000000]

        var m2 = m;
        m2.X += 10000000000000;
        m2.Y += 10000000000000;

        std.debug.print("Machine #{d}: ", .{i});
        const sol = solve(m2) catch {
            std.debug.print("Impossible!\n", .{});
            continue;
        };

        const a = sol[0];
        const b = sol[1];
        const cost = a * A_COST + b * B_COST;

        std.debug.print("{d} A presses + {d} B presses == {d} tokens.\n", .{ a, b, cost });
        total_cost += cost;
    }

    return total_cost;
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
