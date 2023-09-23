const std = @import("std");
const ecs = @import("zig-ecs");
const ui = @import("ui.zig");

const Paddle = @import("paddle.zig");
const Ball = @import("ball.zig");

var ball: Ball = undefined;
var paddle: Paddle = undefined;

pub fn init(reg: *ecs.Registry) void {
    paddle.init(reg);
    ball.init(reg);
}

pub fn update(reg: *ecs.Registry) void {
    ball.move(reg);
    paddle.move(reg);
    paddle.confine(reg);
    paddle.score(reg);
}

pub fn render(allocator: std.mem.Allocator, reg: *ecs.Registry) !void {
    ball.spawn(reg);
    paddle.spawn(reg);
    ui.draw_line();
    ui.show_score(allocator, reg) catch unreachable;
}
