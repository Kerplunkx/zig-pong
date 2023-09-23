const aya = @import("aya");
const math = aya.math;
const ecs = @import("zig-ecs");
const components = @import("ecs/components/components.zig");
const paddle = @import("paddle.zig");

pub const size: f32 = 20;
pub const velocity: f32 = 400;

/// Creates a ball entity.
pub fn init(_: @This(), reg: *ecs.Registry) void {
    const half_width = @divExact(aya.window.width(), 2);
    const half_height = @divExact(aya.window.height(), 2);

    var entity = reg.create();
    reg.add(entity, components.Velocity{ .x = velocity, .y = 0 });
    reg.add(entity, components.Transform{
        .translation = .{
            .x = @as(f32, @floatFromInt(half_width)) - size / 2.0,
            .y = @as(f32, @floatFromInt(half_height)),
        },
    });
}

/// Renders the ball.
pub fn spawn(_: @This(), reg: *ecs.Registry) void {
    var view = reg.view(.{ components.Velocity, components.Transform }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        const translation = view.getConst(components.Transform, e).translation;
        aya.gfx.draw.rect(math.Vec2.init(translation.x, translation.y), size, size, math.Color.white);
    }
}

/// Handles ball movement.
pub fn move(_: @This(), reg: *ecs.Registry) void {
    // Not the cleanest code ever 🗿
    var ball_view = reg.view(.{components.Velocity}, .{components.Player});
    var ball_iter = ball_view.entityIterator();
    var paddle_view = reg.view(.{ components.Player, components.Transform }, .{});
    var paddle_iter = paddle_view.entityIterator();

    var dt = aya.time.dt();

    const window_width = @as(f32, @floatFromInt(aya.window.width()));
    _ = window_width;
    const window_height = @as(f32, @floatFromInt(aya.window.height()));

    while (ball_iter.next()) |b| {
        var vel = reg.get(components.Velocity, b);
        var ball_transform = reg.get(components.Transform, b);
        ball_transform.*.translation.x += vel.*.x * dt;
        ball_transform.*.translation.y += vel.*.y * dt;

        if (ball_transform.*.translation.y <= 0 or ball_transform.*.translation.y >= window_height) {
            vel.*.y *= -1;
        }

        while (paddle_iter.next()) |p| {
            const paddle_transform = paddle_view.getConst(components.Transform, p);
            const id = paddle_view.getConst(components.Player, p).id;
            switch (id) {
                1 => {
                    if ((ball_transform.*.translation.x <= paddle_transform.translation.x + paddle.width) and
                        (paddle_transform.translation.y) <= ball_transform.*.translation.y and
                        ball_transform.*.translation.y <= (paddle_transform.translation.y + paddle.height))
                    {
                        vel.*.x *= -1;
                        if ((paddle_transform.translation.y <= ball_transform.*.translation.y) and
                            (ball_transform.*.translation.y <= paddle_transform.translation.y + paddle.height / 2.0))
                        {
                            vel.*.y = velocity;
                        } else {
                            vel.*.y = -velocity;
                        }
                    }
                },
                2 => {
                    if ((ball_transform.*.translation.x + size >= paddle_transform.translation.x) and
                        (paddle_transform.translation.y) <= ball_transform.*.translation.y and
                        ball_transform.*.translation.y <= (paddle_transform.translation.y + paddle.height))
                    {
                        vel.*.x *= -1;
                        if ((paddle_transform.translation.y <= ball_transform.*.translation.y) and
                            (ball_transform.*.translation.y <= paddle_transform.translation.y + paddle.height / 2.0))
                        {
                            vel.*.y = velocity;
                        } else {
                            vel.*.y = -velocity;
                        }
                    }
                },
                else => break,
            }
        }
    }
}
