const std = @import("std");
const BoundedArray = std.BoundedArray;
const DefaultPrng = std.rand.DefaultPrng;
const Random = std.rand.Random;

const w4 = @import("wasm4.zig");

const lib = @import("lib.zig");
const Rocket = lib.Rocket;
const Alien = lib.Alien;

const Self = @This();

rocket: Rocket,
aliens: BoundedArray(Alien, 64),
frame_count: u32,
prng: DefaultPrng,
alien_spawn_rate: u32,
score: u32,
game_over: bool,
game_over_frames: u8,

pub fn init() Self {
    var self: Self = undefined;
    self.frame_count = 0;
    self.aliens = BoundedArray(Alien, 64).init(0) catch unreachable;
    self.prng = DefaultPrng.init(0);
    self.reset();
    return self;
}

pub fn reset(self: *Self) void {
    self.rocket = Rocket.init();
    self.aliens.resize(0) catch unreachable;
    self.prng.seed(self.frame_count);
    self.alien_spawn_rate = 120;
    self.score = 0;
    self.game_over = false;
}

fn spawnAlien(self: *Self) void {
    self.aliens.append(Alien.init(self.prng.random(), self.rocket.pos)) catch return;
}

fn gameOver(self: *Self) void {
    self.game_over = true;
    self.game_over_frames = game_over_frames;
}

pub fn step(self: *Self) void {
    self.frame_count += 1;

    if (self.game_over) {
        self.drawGameOver();
        if (self.game_over_frames > 0) {
            self.game_over_frames -= 1;
        } else {
            self.drawTryAgain();
            if (w4.GAMEPAD1.* != 0) self.reset();
        }
        return;
    }

    self.input();
    self.update();
    self.draw();
}

fn input(self: *Self) void {
    const pressed = w4.GAMEPAD1.*;

    self.rocket.still();
    if (pressed & w4.BUTTON_LEFT != 0) {
        self.rocket.left();
    }
    if (pressed & w4.BUTTON_RIGHT != 0) {
        self.rocket.right();
    }
    if (pressed & w4.BUTTON_UP != 0) {
        self.rocket.up();
    }
    if (pressed & w4.BUTTON_DOWN != 0) {
        self.rocket.down();
    }
}

fn update(self: *Self) void {
    self.rocket.update();

    if (self.frame_count % self.alien_spawn_rate == 0) self.spawnAlien();

    var to_remove = BoundedArray(usize, 64).init(0) catch unreachable;
    for (self.aliens.slice()) |*alien| alien.update();

    for (self.aliens.constSlice()) |alien, i| {
        if (alien.outOfBounds()) to_remove.append(i) catch unreachable;
    }

    for (to_remove.constSlice()) |_, i_inv| {
        const i = to_remove.len - i_inv - 1;
        _ = self.aliens.orderedRemove(i);
        self.score += 1;
    }

    for (self.aliens.constSlice()) |alien| {
        if (alien.collides(self.rocket)) {
            self.gameOver();
        }
    }

    if (self.frame_count % spawn_acceleration_rate == 0) self.alien_spawn_rate -= 1;
    if (self.alien_spawn_rate <= 10) self.alien_spawn_rate = 10;
}

fn draw(self: Self) void {
    for (self.aliens.constSlice()) |alien| alien.draw(self.rocket.pos);
    self.rocket.draw();

    { // score
        w4.DRAW_COLORS.* = 0x41;
        var buf: [64]u8 = undefined;
        const score = std.fmt.bufPrint(&buf, "Score: {d}", .{self.score}) catch unreachable;
        w4.text(score, 0, 0);
    }
}

fn drawGameOver(self: Self) void {
    w4.DRAW_COLORS.* = 0x40;
    var buf: [64]u8 = undefined;
    const score = std.fmt.bufPrint(&buf, "Score: {d}", .{self.score}) catch unreachable;
    w4.text(score, 0, 0);

    w4.DRAW_COLORS.* = 0x2;
    w4.text("Game Over!", 32, w4.CANVAS_SIZE / 2);
}

fn drawTryAgain(_: Self) void {
    w4.DRAW_COLORS.* = 0x4;
    w4.text("Press any key to\ntry again", 20, w4.CANVAS_SIZE / 2 + 40);
}

const spawn_acceleration_rate: u32 = 60;
const game_over_frames = 180;
