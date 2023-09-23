// Two coordinates only since this is a 2D game.
pub const Translation = struct { x: f32, y: f32 };

pub const Velocity = struct { x: f32, y: f32 };

// We don't really need rotation and scale for pong.
pub const Transform = struct { translation: Translation };

pub const Player = struct { id: u8, score: u8 };
