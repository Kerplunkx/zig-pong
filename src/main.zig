const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const ecs = @import("zig-ecs");

const game = @import("game.zig");

var allocator: std.mem.Allocator = undefined;

var reg: ecs.Registry = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    allocator = gpa.allocator();

    reg = ecs.Registry.init(allocator);
    defer reg.deinit();

    try aya.run(.{
        .init = init,
        .render = render,
        .update = update,
        .window = .{
            .title = "Pong",
            .width = 1000,
            .height = 600,
            .resizable = false,
        },
    });
}

fn init() !void {
    game.init(&reg);
}

fn update() !void {
    game.update(&reg);
}

fn render() !void {
    aya.gfx.beginPass(.{ .color = math.Color.black });
    try game.render(allocator, &reg);
    aya.gfx.endPass();
}
