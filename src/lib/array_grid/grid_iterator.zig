const std = @import("std");
const expect = std.testing.expect;

const grid_module = @import("grid.zig");
const Grid = grid_module.Grid;

const grid_index = @import("grid_index.zig");
const GridIndex = grid_index.GridIndex;
const GridDirection = grid_index.GridDirection;

pub fn GridIterator(T: type) type {
    return struct {
        grid: *const Grid(T),
        index: GridIndex = .{ .x = 0, .y = 0 },

        pub fn next(self: *GridIterator(T)) ?GridIndex {
            var next_index = self.index.addDirection(GridDirection.Right);

            if (next_index.x >= self.grid.width()) {
                // Move to start of next row.
                next_index.y += 1;
                next_index.x = 0;
            }

            if (next_index.y >= self.grid.height()) {
                // End of grid reached.
                return null;
            }

            self.index = next_index;
            return next_index;
        }
    };
}

test "GridIterator.next" {
    var grid = grid_module.testingGrid();
    defer grid.free();

    var it = GridIterator(u8){ .grid = &grid };

    try std.testing.expectEqual(it.next().?, GridIndex{ .x = 1, .y = 0 });
    try std.testing.expectEqual(it.next().?, GridIndex{ .x = 2, .y = 0 });
    try std.testing.expectEqual(it.next().?, GridIndex{ .x = 0, .y = 1 });
    try std.testing.expectEqual(it.next().?, GridIndex{ .x = 1, .y = 1 });
    try std.testing.expectEqual(it.next().?, GridIndex{ .x = 2, .y = 1 });
    try expect(it.next() == null);
}
