const std = @import("std");
const expect = std.testing.expect;

const grid_index = @import("grid_index.zig");
const GridIndex = grid_index.GridIndex;

pub const GridError = error{OutOfBounds};

pub fn Grid(T: type) type {
    return struct {
        rows: std.ArrayList([]const T),

        pub fn init(allocator: std.mem.Allocator) Grid(T) {
            return Grid(T){ .rows = std.ArrayList([]const T).init(allocator) };
        }

        pub fn free(self: *Grid(T)) void {
            self.rows.clearAndFree();
        }

        pub fn width(self: Grid(T)) usize {
            return self.rows.getLast().len;
        }

        pub fn height(self: Grid(T)) usize {
            return self.rows.items.len;
        }

        pub fn contains(self: Grid(T), index: GridIndex) bool {
            const contains_x = (0 <= index.x) and (index.x < self.width());
            const contains_y = (0 <= index.y) and (index.y < self.height());
            return contains_x and contains_y;
        }

        pub fn at(self: Grid(T), index: GridIndex) GridError!T {
            if (!self.contains(index)) return GridError.OutOfBounds;

            const x: usize = @intCast(index.x);
            const y: usize = @intCast(index.y);
            return self.rows.items[y][x];
        }
    };
}

pub fn testingGrid() Grid(u8) {
    // 2x3 grid for tests.
    var grid = Grid(u8).init(std.testing.allocator);
    grid.rows.append(&[_]u8{ 1, 2, 3 }) catch unreachable;
    grid.rows.append(&[_]u8{ 4, 5, 6 }) catch unreachable;

    return grid;
}

test "Grid.init" {
    const grid = Grid(u8).init(std.testing.allocator);
    try expect(@TypeOf(grid) == Grid(u8));
}

test "Grid.width" {
    var grid = testingGrid();
    defer grid.free();

    try expect(grid.width() == 3);
}

test "Grid.height" {
    var grid = testingGrid();
    defer grid.free();

    try expect(grid.height() == 2);
}

test "Grid.contains" {
    var grid = testingGrid();
    defer grid.free();

    try expect(grid.contains(.{ .x = 0, .y = 0 }));
    try expect(grid.contains(.{ .x = 2, .y = 1 }));
    try expect(!grid.contains(.{ .x = 5, .y = 5 }));
    try expect(!grid.contains(.{ .x = -1, .y = -1 }));
}

test "Grid.at" {
    var grid = testingGrid();
    defer grid.free();

    try expect(try grid.at(.{ .x = 0, .y = 0 }) == 1);
    try expect(try grid.at(.{ .x = 1, .y = 0 }) == 2);
    try expect(try grid.at(.{ .x = 2, .y = 0 }) == 3);
    try expect(try grid.at(.{ .x = 0, .y = 1 }) == 4);
    try expect(try grid.at(.{ .x = 1, .y = 1 }) == 5);
    try expect(try grid.at(.{ .x = 2, .y = 1 }) == 6);
}
