const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const ecs = @import("zig-ecs");
const components = @import("ecs/components/components.zig");

pub const padding: f32 = 30;
pub const width: f32 = 30;
pub const height: f32 = 180;
const velocity: f32 = 400;

/// Creates the paddle entities.
pub fn init(_: @This(), reg: *ecs.Registry) void {
    const window_width = aya.window.width();
    const half_window_height = @divExact(aya.window.height(), 2);

    var paddle_1 = reg.create();
    var paddle_2 = reg.create();
    reg.add(paddle_1, components.Transform{
        .translation = .{ .x = padding, .y = @as(f32, @floatFromInt(half_window_height)) - height / 2.0 },
    });
    reg.add(paddle_1, components.Player{ .id = 1 });
    reg.add(paddle_2, components.Transform{
        .translation = .{ .x = @as(f32, @floatFromInt(window_width)) - (padding + width), .y = @as(f32, @floatFromInt(half_window_height)) - height / 2.0 },
    });
    reg.add(paddle_2, components.Player{ .id = 2 });
}

/// Renders both paddles.
pub fn spawn(_: @This(), reg: *ecs.Registry) void {
    var view = reg.view(.{components.Transform}, .{components.Velocity});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const translation = view.getConst(components.Transform, e).translation;
        aya.gfx.draw.rect(math.Vec2.init(translation.x, translation.y), width, height, math.Color.white);
    }
}

/// Handles player input to control the individual paddles.
pub fn move(_: @This(), reg: *ecs.Registry) void {
    var view = reg.view(.{components.Transform}, .{components.Velocity});
    var iter = view.entityIterator();
    var dt = aya.time.dt();

    while (iter.next()) |e| {
        var transform = view.get(components.Transform, e);
        const id = view.getConst(components.Player, e).id;

        // I hate this piece of code. Any ideas on how to do it cleaner?
        switch (id) {
            1 => {
                if (aya.input.keyDown(.w)) {
                    transform.*.translation.y -= velocity * dt;
                }
                if (aya.input.keyDown(.s)) {
                    transform.*.translation.y += velocity * dt;
                }
            },
            2 => {
                if (aya.input.keyDown(.up)) {
                    transform.*.translation.y -= velocity * dt;
                }
                if (aya.input.keyDown(.down)) {
                    transform.*.translation.y += velocity * dt;
                }
            },
            else => unreachable,
        }
    }
}

/// Restricts the paddles to the window's height.
pub fn confine(_: @This(), reg: *ecs.Registry) void {
    // This "query" also works :)
    var view = reg.view(.{components.Player}, .{components.Velocity});
    var iter = view.entityIterator();
    const window_height = @as(f32, @floatFromInt(aya.window.height()));

    while (iter.next()) |e| {
        var transform = view.get(components.Transform, e);
        if (transform.*.translation.y <= 0) {
            transform.*.translation.y = 0;
        }
        if (transform.*.translation.y >= window_height - height) {
            transform.*.translation.y = window_height - height;
        }
    }
}
