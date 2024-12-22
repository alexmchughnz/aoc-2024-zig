const std = @import("std");
const expect = std.testing.expect;

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

    pub fn add(self: GridIndex, addend: GridIndex) GridIndex {
        return GridIndex{ .x = self.x + addend.x, .y = self.y + addend.y };
    }

    pub fn move(self: *GridIndex, dir: GridDirection) void {
        self.* = self.add(dir.toIndex());
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

test "GridIndex.move" {
    var index = GridIndex{};

    index.move(GridDirection.Down);
    try expect(index.x == 0 and index.y == 1);
    index.move(GridDirection.Right);
    try expect(index.x == 1 and index.y == 1);
    index.move(GridDirection.Up);
    try expect(index.x == 1 and index.y == 0);
    index.move(GridDirection.Left);
    try expect(index.x == 0 and index.y == 0);

    index.move(GridDirection.DownRight);
    try expect(index.x == 1 and index.y == 1);
    index.move(GridDirection.DownLeft);
    try expect(index.x == 0 and index.y == 2);
    index.move(GridDirection.UpLeft);
    try expect(index.x == -1 and index.y == 1);
    index.move(GridDirection.UpRight);
    try expect(index.x == 0 and index.y == 0);
}
