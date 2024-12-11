const std = @import("std");
const build_options = @import("build_options");

const puzzle_input = @embedFile("input.txt");

const MUL_TOKEN = "mul(";
const DO_TOKEN = "do()";
const DONT_TOKEN = "don't()";

const ReadError = error{ InvalidToken, EndOfInput };

fn read_mul(input: []const u8, chars_read: *usize) ReadError!u64 {
    var i: usize = 0;
    defer chars_read.* = i;

    // Find "mul("...
    i += std.mem.indexOf(u8, input, MUL_TOKEN) orelse return ReadError.EndOfInput;
    i += MUL_TOKEN.len;

    // ...followed by digits until ',' is found
    const i_num1: usize = i;
    while (input[i] != ',') : (i += 1) {
        if (!std.ascii.isDigit(input[i])) return ReadError.InvalidToken;
    }
    const num1 = std.fmt.parseInt(u64, input[i_num1..i], 10) catch unreachable;
    i += 1;

    // ...followed by digits until ')' is found
    const i_num2: usize = i;
    while (input[i] != ')') : (i += 1) {
        if (!std.ascii.isDigit(input[i])) return ReadError.InvalidToken;
    }
    const num2 = std.fmt.parseInt(u64, input[i_num2..i], 10) catch unreachable;
    i += 1;

    // Valid mul instruction! Return product.
    return num1 * num2;
}

fn part1(input: []const u8) u64 {
    var sum_of_mul_instructions: u64 = 0;

    var index: usize = 0;
    var chars_read: usize = undefined;
    while (index < input.len) : (index += chars_read) {
        const product = read_mul(input[index..], &chars_read) catch |err| {
            switch (err) {
                ReadError.InvalidToken => continue,
                ReadError.EndOfInput => break,
                else => unreachable,
            }
        };

        sum_of_mul_instructions += product;
    }

    return sum_of_mul_instructions;
}

fn part2(input: []const u8) u64 {
    var sum_of_mul_instructions: u64 = 0;

    var read_enabled = true;

    var index: usize = 0;
    var chars_read: usize = undefined;
    while (index < input.len) : (index += chars_read) {
        // Find which token occurs next.
        const chars_until_mul = std.mem.indexOf(u8, input[index..], MUL_TOKEN) orelse break;
        const chars_until_do = std.mem.indexOf(u8, input[index..], DO_TOKEN) orelse std.math.maxInt(usize);
        const chars_until_dont = std.mem.indexOf(u8, input[index..], DONT_TOKEN) orelse std.math.maxInt(usize);

        // Go to the next relevant instruction.
        if (read_enabled) {
            if (chars_until_mul < chars_until_dont) {
                // Parse mul and execute if valid.
                const product = read_mul(input[index..], &chars_read) catch |err| {
                    switch (err) {
                        ReadError.InvalidToken => continue,
                        else => unreachable,
                    }
                };
                sum_of_mul_instructions += product;
            } else {
                // Parse don't().
                read_enabled = false;
                chars_read = chars_until_dont + DONT_TOKEN.len;
            }
        } else {
            // Parse do().
            read_enabled = true;
            chars_read = chars_until_do + DO_TOKEN.len;
        }
    }

    return sum_of_mul_instructions;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{build_options.day});

    const answer1 = part1(puzzle_input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = part2(puzzle_input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
