const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const ecs = @import("zig-ecs");

const Ball = @import("ball.zig");
const Paddle = @import("paddle.zig");

var reg: ecs.Registry = undefined;
var ball: Ball = undefined;
var paddle: Paddle = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

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
    ball.init(&reg);
    paddle.init(&reg);
}

fn update() !void {
    ball.move(&reg);
    paddle.move(&reg);
    paddle.confine(&reg);
}

fn render() !void {
    aya.gfx.beginPass(.{ .color = math.Color.black });
    ball.spawn(&reg);
    paddle.spawn(&reg);
    aya.gfx.endPass();
}
