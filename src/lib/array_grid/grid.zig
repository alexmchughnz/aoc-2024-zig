const std = @import("std");
const expect = std.testing.expect;

const GridIndex = @import("grid_index.zig").GridIndex;

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

test "Grid.init" {
    const grid = Grid(u8).init(std.testing.allocator);
    try expect(@TypeOf(grid) == Grid(u8));
}

test "Grid.width" {
    var grid = Grid(u8).init(std.testing.allocator);
    defer grid.free();

    const row = [_]u8{ 1, 2, 3 };
    try grid.rows.append(&row);

    try expect(grid.width() == 3);
}

test "Grid.height" {
    var grid = Grid(u8).init(std.testing.allocator);
    defer grid.free();

    const col = [_]u8{ 1, 2, 3 };
    for (&col) |*n| try grid.rows.append(n[0..1]);

    try expect(grid.height() == 3);
}

test "Grid.contains" {
    var grid = Grid(u8).init(std.testing.allocator);
    defer grid.free();

    const row = [_]u8{ 1, 2, 3 };
    for (0..3) |_| try grid.rows.append(&row);

    try expect(grid.contains(.{ .x = 0, .y = 0 }));
    try expect(grid.contains(.{ .x = 2, .y = 2 }));
    try expect(!grid.contains(.{ .x = 5, .y = 5 }));
    try expect(!grid.contains(.{ .x = -1, .y = -1 }));
}

test "Grid.at" {
    var grid = Grid(u8).init(std.testing.allocator);
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
