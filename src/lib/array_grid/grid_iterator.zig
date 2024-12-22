const std = @import("std");
const expect = std.testing.expect;

const Grid = @import("grid.zig").Grid;

const grid_index = @import("grid_index.zig");
const GridIndex = grid_index.GridIndex;
const GridDirection = grid_index.GridDirection;

pub fn GridIterator(T: type) type {
    return struct {
        grid: *const Grid(T),
        index: GridIndex = .{ .x = 0, .y = 0 },

        fn next(self: *GridIterator(T)) ?GridIndex {
            self.index.move(GridDirection.Right);

            if (self.index.x >= self.grid.width()) {
                // Move to start of next row.
                self.index.y += 1;
                self.index.x = 0;
            }

            if (self.index.y >= self.grid.height()) {
                // End of grid reached.
                return null;
            }

            return self.index;
        }
    };
}

test "GridIterator.next" {
    var grid = Grid(u8).init(std.testing.allocator);
    defer grid.free();

    const row = [_]u8{ 1, 2, 3 };
    for (0..3) |_| try grid.rows.append(&row);

    var it = GridIterator(u8){ .grid = &grid };

    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 1, .y = 0 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 2, .y = 0 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 0, .y = 1 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 1, .y = 1 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 2, .y = 1 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 0, .y = 2 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 1, .y = 2 }));
    try expect(std.meta.eql(it.next().?, GridIndex{ .x = 2, .y = 2 }));
    try expect(it.next() == null);
}
