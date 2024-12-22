const std = @import("std");
const expect = std.testing.expect;

const grid_index = @import("grid_index.zig");
const GridIndex = grid_index.GridIndex;
const GridDirection = grid_index.GridDirection;

pub const ArrayGridError = error{OutOfBounds};

pub fn ArrayGrid(T: type) type {
    return struct {
        rows: std.ArrayList([]const T),

        pub fn init(alloc: std.mem.Allocator) ArrayGrid(T) {
            return ArrayGrid(T){ .rows = std.ArrayList([]const T).init(alloc) };
        }

        pub fn free(self: *ArrayGrid(T)) void {
            self.rows.clearAndFree();
        }

        pub fn width(self: ArrayGrid(T)) usize {
            return self.rows.getLast().len;
        }

        pub fn height(self: ArrayGrid(T)) usize {
            return self.rows.items.len;
        }

        pub fn contains(self: ArrayGrid(T), index: GridIndex) bool {
            const contains_x = (0 <= index.x) and (index.x < self.width());
            const contains_y = (0 <= index.y) and (index.y < self.height());
            return contains_x and contains_y;
        }

        pub fn at(self: ArrayGrid(T), index: GridIndex) ArrayGridError!T {
            if (!self.contains(index)) return ArrayGridError.OutOfBounds;

            const x: usize = @intCast(index.x);
            const y: usize = @intCast(index.y);
            return self.rows.items[y][x];
        }
    };
}

test "ArrayGrid.init" {
    const grid = ArrayGrid(u8).init(std.testing.allocator);
    try expect(@TypeOf(grid) == ArrayGrid(u8));
}

test "ArrayGrid.width" {
    var grid = ArrayGrid(u8).init(std.testing.allocator);
    defer grid.free();

    const row = [_]u8{ 1, 2, 3 };
    try grid.rows.append(&row);

    try expect(grid.width() == 3);
}

test "ArrayGrid.height" {
    var grid = ArrayGrid(u8).init(std.testing.allocator);
    defer grid.free();

    const col = [_]u8{ 1, 2, 3 };
    for (&col) |*n| try grid.rows.append(n[0..1]);

    try expect(grid.height() == 3);
}

test "ArrayGrid.contains" {
    var grid = ArrayGrid(u8).init(std.testing.allocator);
    defer grid.free();

    const row = [_]u8{ 1, 2, 3 };
    for (0..3) |_| try grid.rows.append(&row);

    try expect(grid.contains(.{ .x = 0, .y = 0 }));
    try expect(grid.contains(.{ .x = 2, .y = 2 }));
    try expect(!grid.contains(.{ .x = 5, .y = 5 }));
    try expect(!grid.contains(.{ .x = -1, .y = -1 }));
}

test "ArrayGrid.at" {
    var grid = ArrayGrid(u8).init(std.testing.allocator);
    defer grid.free();

    const rows = [3][3]u8{ [_]u8{ 1, 2, 3 }, [_]u8{ 4, 5, 6 }, [_]u8{ 7, 8, 9 } };
    for (&rows) |*row| {
        try grid.rows.append(row);
    }

    try expect(try grid.at(.{ .x = 0, .y = 0 }) == 1);
    try expect(try grid.at(.{ .x = 1, .y = 0 }) == 2);
    try expect(try grid.at(.{ .x = 2, .y = 0 }) == 3);
    try expect(try grid.at(.{ .x = 0, .y = 1 }) == 4);
    try expect(try grid.at(.{ .x = 1, .y = 1 }) == 5);
    try expect(try grid.at(.{ .x = 2, .y = 1 }) == 6);
    try expect(try grid.at(.{ .x = 0, .y = 2 }) == 7);
    try expect(try grid.at(.{ .x = 1, .y = 2 }) == 8);
    try expect(try grid.at(.{ .x = 2, .y = 2 }) == 9);
}
