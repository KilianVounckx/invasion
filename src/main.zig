const w4 = @import("wasm4.zig");

const lib = @import("lib.zig");
const Game = lib.Game;

var game: Game = undefined;

export fn start() void {
    w4.PALETTE.* = .{
        0x0c1445, // sky
        0xda3330, // fire red
        0xf9c73f, // fire yellow
        0x8e8e8e, // grey
    };

    game = Game.init();
}

export fn update() void {
    game.step();
}
