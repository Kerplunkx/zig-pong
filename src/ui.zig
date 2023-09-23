const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const ecs = @import("zig-ecs");
const components = @import("ecs/components/components.zig");

pub fn draw_line() void {
    const window_width = @as(f32, @floatFromInt(aya.window.width()));
    const window_height = @as(f32, @floatFromInt(aya.window.height()));
    aya.draw.line(math.Vec2.init(window_width / 2.0, 0.0), math.Vec2.init(window_width / 2.0, window_height), 3.0, math.Color.white);
}

pub fn show_score(allocator: std.mem.Allocator, reg: *ecs.Registry) !void {
    var view = reg.basicView(components.Player);
    var iter = view.entityIterator();

    const window_width = @as(f32, @floatFromInt(aya.window.width()));

    while (iter.next()) |p| {
        const player = view.getConst(p);
        const id = player.id;
        const size = @as(usize, @intCast(std.fmt.count("{d}", .{player.score})));
        const buf = try allocator.alloc(u8, size);
        defer allocator.free(buf);
        const score = try std.fmt.bufPrint(buf, "{d}", .{player.score});

        switch (id) {
            1 => aya.gfx.draw.text(score, window_width / 4.0, 40, null),
            2 => aya.gfx.draw.text(score, ((3.0 / 4.0) * window_width), 40, null),
            else => break,
        }
    }
}
