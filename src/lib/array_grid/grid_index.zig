const std = @import("std");
const expect = std.testing.expect;

const grid_module = @import("grid.zig");
const Grid = grid_module.Grid;
const GridError = grid_module.GridError;

pub const GridDirection = enum {
    Up,
    Down,
    Left,
    Right,
    UpLeft,
    UpRight,
    DownLeft,
    DownRight,

    pub fn opposite(self: GridDirection) GridDirection {
        return switch (self) {
            .Up => .Down,
            .Down => .Up,
            .Left => .Right,
            .Right => .Left,
            .UpLeft => .DownRight,
            .UpRight => .DownLeft,
            .DownLeft => .UpRight,
            .DownRight => .UpLeft,
        };
    }

    pub fn toIndex(self: GridDirection) GridIndex {
        return switch (self) {
            .Up => .{ .x = 0, .y = -1 },
            .Down => .{ .x = 0, .y = 1 },
            .Left => .{ .x = -1, .y = 0 },
            .Right => .{ .x = 1, .y = 0 },
            .UpLeft => .{ .x = -1, .y = -1 },
            .UpRight => .{ .x = 1, .y = -1 },
            .DownLeft => .{ .x = -1, .y = 1 },
            .DownRight => .{ .x = 1, .y = 1 },
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
