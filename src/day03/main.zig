const std = @import("std");

const DAY = 3;
const INPUT = "input.txt";

const SIZE = 128;

fn parse() ![]u8 {
    const file = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, INPUT, std.math.maxInt(usize));
    return file;
}

const ReadError = error{ InvalidToken, EndOfInput };

fn read_mul(input_slice: []const u8, chars_read: *usize) ReadError!u64 {
    var i: usize = 0;
    defer chars_read.* = i;

    const MUL_TOKEN = "mul(";

    // Find "mul("...
    i += std.mem.indexOf(u8, input_slice, MUL_TOKEN) orelse return ReadError.EndOfInput;
    i += MUL_TOKEN.len;

    // ...followed by digits until ',' is found
    const i_num1: usize = i;
    while (input_slice[i] != ',') : (i += 1) {
        if (!std.ascii.isDigit(input_slice[i])) return ReadError.InvalidToken;
    }
    const num1 = std.fmt.parseInt(u64, input_slice[i_num1..i], 10) catch unreachable;
    i += 1;

    // ...followed by digits until ')' is found
    const i_num2: usize = i;
    while (input_slice[i] != ')') : (i += 1) {
        if (!std.ascii.isDigit(input_slice[i])) return ReadError.InvalidToken;
    }
    const num2 = std.fmt.parseInt(u64, input_slice[i_num2..i], 10) catch unreachable;
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

fn part2(input: []const u8) !u64 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n*** DAY {d} ***\n", .{DAY});

    const input: []u8 = try parse();

    const answer1 = part1(input);
    try stdout.print("Part One = {d}\n", .{answer1});

    const answer2 = try part2(input);
    try stdout.print("Part Two = {d}\n", .{answer2});
}
