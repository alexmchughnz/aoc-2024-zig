const std = @import("std");
const expect = std.testing.expect;

const Grid = @import("grid.zig").Grid;
const GridError = @import("grid.zig").GridError;

pub const GridDirection = enum {
    Up,
    Down,
    Left,
    Right,
    UpLeft,
    UpRight,
    DownLeft,
    DownRight,

    pub fn toIndex(self: GridDirection) GridIndex {
        return switch (self) {
            GridDirection.Up => .{ .x = 0, .y = -1 },
            GridDirection.Down => .{ .x = 0, .y = 1 },
            GridDirection.Left => .{ .x = -1, .y = 0 },
            GridDirection.Right => .{ .x = 1, .y = 0 },
            GridDirection.UpLeft => .{ .x = -1, .y = -1 },
            GridDirection.UpRight => .{ .x = 1, .y = -1 },
            GridDirection.DownLeft => .{ .x = -1, .y = 1 },
            GridDirection.DownRight => .{ .x = 1, .y = 1 },
        };
    }
};

pub const GridIndex = struct {
    x: isize = 0,
    y: isize = 0,

    pub fn add(self: GridIndex, other: GridIndex) GridIndex {
        return GridIndex{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn addDirection(self: GridIndex, direction: GridDirection) GridIndex {
        return self.add(direction.toIndex());
    }

    pub fn moveDirection(self: *GridIndex, T: type, grid: Grid(T), dir: GridDirection) GridError!void {
        const dest = self.addDirection(dir);
        if (!grid.contains(dest)) return GridError.OutOfBounds;
        self.* = dest;
    }
};

test "GridIndex.add" {
    const index = GridIndex{ .x = 2, .y = 2 };
    var result = GridIndex{};

    result = index.add(.{ .x = 1, .y = 2 });
    try expect(result.x == 3 and result.y == 4);
    result = index.add(.{ .x = -2, .y = -2 });
    try expect(result.x == 0 and result.y == 0);
    result = index.add(.{ .x = -4, .y = -4 });
    try expect(result.x == -2 and result.y == -2);
}

test "GridIndex.addDirection" {
    var index = GridIndex{};

    index = index.addDirection(GridDirection.Down);
    try expect(index.x == 0 and index.y == 1);
    index = index.addDirection(GridDirection.Right);
    try expect(index.x == 1 and index.y == 1);
    index = index.addDirection(GridDirection.Up);
    try expect(index.x == 1 and index.y == 0);
    index = index.addDirection(GridDirection.Left);
    try expect(index.x == 0 and index.y == 0);

    index = index.addDirection(GridDirection.DownRight);
    try expect(index.x == 1 and index.y == 1);
    index = index.addDirection(GridDirection.DownLeft);
    try expect(index.x == 0 and index.y == 2);
    index = index.addDirection(GridDirection.UpLeft);
    try expect(index.x == -1 and index.y == 1);
    index = index.addDirection(GridDirection.UpRight);
    try expect(index.x == 0 and index.y == 0);
}

test "GridIndex.moveDirection" {
    var grid = Grid(u8).init(std.testing.allocator);
    defer grid.free();
    const row = [_]u8{ 1, 2, 3 };
    for (0..3) |_| try grid.rows.append(&row);

    var index = GridIndex{};
    try index.moveDirection(u8, grid, GridDirection.Down);
    try expect(index.x == 0 and index.y == 1);
    try index.moveDirection(u8, grid, GridDirection.UpRight);
    try expect(index.x == 1 and index.y == 0);
    index.moveDirection(u8, grid, GridDirection.Up) catch |err| {
        try expect(err == GridError.OutOfBounds);
    };
}
