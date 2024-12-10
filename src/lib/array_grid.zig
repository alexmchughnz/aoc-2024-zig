const std = @import("std");
const expect = std.testing.expect;

pub const GridError = error{OutOfBounds};

pub const GridIndex = struct {
    x: isize,
    y: isize,

    fn add(self: GridIndex, addend: GridIndex) GridIndex {
        return GridIndex{ .x = self.x + addend.x, .y = self.y + addend.y };
    }
};

pub const GridDirection = enum {
    Up,
    Down,
    Left,
    Right,
    UpLeft,
    UpRight,
    DownLeft,
    DownRight,

    fn getDeltaIndex(self: GridDirection) GridIndex {
        return switch (self) {
            GridDirection.Up => .{ .x = 0, .y = -1 },
            GridDirection.Down => .{ .x = 0, .y = 1 },
            GridDirection.Left => .{ .x = -1, .y = 0 },
            GridDirection.Right => .{ .x = 1, .y = 0 },
            GridDirection.UpLeft => .{ .x = -1, .y = -1 },
            GridDirection.UpRight => .{ .x = 1, .y = -1 },
            GridDirection.DownLeft => .{ .x = -1, .y = 1 },
            GridDirection.DownRight => .{ .x = 1, .y = -1 },
        };
    }
};

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

        pub fn at(self: ArrayGrid(T), index: GridIndex) GridError!T {
            if (index.x < 0 or index.x >= self.width()) return GridError.OutOfBounds;
            if (index.y < 0 or index.y >= self.height()) return GridError.OutOfBounds;

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
