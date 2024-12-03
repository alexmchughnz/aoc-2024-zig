const std = @import("std");

const DAY = 3;
const INPUT = "input.txt";

const SIZE = 128;

const MUL_TOKEN = "mul";

fn parse() ![]u8 {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    return file;
}

fn part1(input: []const u8) !u64 {
    var sum_of_mul_instructions: u64 = 0;
    var i: usize = 0;

    mul_loop: while (i < input.len) {
        // Find "mul"...
        const remaining_input = input[i..];
        i += std.mem.indexOf(u8, remaining_input, MUL_TOKEN) orelse break;

        // ...followed by '('
        i += MUL_TOKEN.len;
        if (input[i] != '(') continue;

        // ...followed by digits until ',' is found
        i += 1;
        var n: usize = i;
        while (input[n] != ',') : (n += 1) {
            if (!std.ascii.isDigit(input[n])) continue :mul_loop; // Invalid mul instruction.
        }
        const num1 = try std.fmt.parseInt(u64, input[i..n], 10);

        // ...followed by digits until ')' is found
        i = n + 1;
        var m: usize = i;
        while (input[m] != ')') : (m += 1) {
            if (!std.ascii.isDigit(input[m])) continue :mul_loop; // Invalid mul instruction.
        }
        const num2 = try std.fmt.parseInt(u64, input[i..m], 10);

        // Valid mul instruction! Increment i and add result to total.
        i = m + 1;
        sum_of_mul_instructions += num1 * num2;
    }

    return sum_of_mul_instructions;
}

fn part2(input: []const u8) !u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    const input: []u8 = try parse();

    const answer1 = try part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
