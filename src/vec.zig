const std = @import("std");
const sin = std.math.sin;
const cos = std.math.cos;
const sqrt = std.math.sqrt;

pub fn Vec(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn init(x: T, y: T) Self {
            return .{ .x = x, .y = y };
        }

        pub fn normalized(self: Self) Self {
            const norm = sqrt(self.x * self.x + self.y * self.y);
            return .{
                .x = self.x / norm,
                .y = self.y / norm,
            };
        }
    };
}
