const std = @import("std");

const w4 = @import("wasm4.zig");

const lib = @import("lib.zig");
const Vec = lib.Vec;

const Self = @This();

pub const collision_width = 14;
pub const collision_height = 14;

pos: Vec(f64),
vel: Vec(f64),

pub fn init() Self {
    return .{
        .pos = Vec(f64).init(
            @intToFloat(f64, w4.CANVAS_SIZE / 2),
            @intToFloat(f64, w4.CANVAS_SIZE / 2),
        ),
        .vel = Vec(f64).init(0, 0),
    };
}

pub fn left(self: *Self) void {
    self.vel.x -= speed;
}

pub fn right(self: *Self) void {
    self.vel.x += speed;
}

pub fn up(self: *Self) void {
    self.vel.y -= speed;
}

pub fn down(self: *Self) void {
    self.vel.y += speed;
}

pub fn still(self: *Self) void {
    self.vel.x = 0;
    self.vel.y = 0;
}

pub fn update(self: *Self) void {
    if (self.vel.x != 0 and self.vel.y != 0) {
        self.vel.x *= std.math.sqrt1_2;
        self.vel.y *= std.math.sqrt1_2;
    }
    self.pos.x += self.vel.x;
    self.pos.y += self.vel.y;
}

pub fn draw(self: Self) void {
    w4.DRAW_COLORS.* = 0x2341;
    w4.blit(
        &sprite,
        @floatToInt(i32, self.pos.x) - sprite_width / 2,
        @floatToInt(i32, self.pos.y) - sprite_height / 2,
        sprite_width,
        sprite_height,
        w4.BLIT_2BPP,
    );
}

const sprite = [64]u8{
    0x00, 0x01, 0x00, 0x00, 0x00, 0x05, 0x40, 0x00,
    0x00, 0x16, 0x50, 0x00, 0x00, 0x19, 0x90, 0x00,
    0x00, 0x16, 0x50, 0x00, 0x00, 0x19, 0x90, 0x00,
    0x00, 0x16, 0x50, 0x00, 0x00, 0x19, 0x90, 0x00,
    0x00, 0x16, 0x50, 0x00, 0x00, 0x55, 0x54, 0x00,
    0x01, 0x5a, 0x95, 0x00, 0x01, 0x3e, 0xf1, 0x00,
    0x00, 0x0f, 0xc0, 0x00, 0x00, 0x03, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};
const sprite_width = 16;
const sprite_height = 16;

const speed = 1.5;
