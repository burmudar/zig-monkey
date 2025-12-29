const std = @import("std");
const expect = std.testing.expect;
pub const TokenKind = enum(u8) {
    SemiColon,
    Colon,
    LeftParen,
    RightParen,
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,
    Equals,
    Plus,
    Minus,
    Comma,
    Dot,
    GreaterThan,
    LessThan,

    pub fn repr(self: TokenKind) []const u8 {
        return switch (self) {
            .SemiColon => ";",
            .Colon => ":",
            .Dot => ".",
            .Comma => ",",
            .Equals => "=",
            .Plus => "+",
            .Minus => "-",
            .LeftParen => "(",
            .RightParen => ")",
            .LeftBracket => "[",
            .RightBracket => "]",
            .LeftBrace => "{",
            .RightBrace => "}",
            .LessThan => "<",
            .GreaterThan => ">",
        };
    }
};

pub const Token = struct { Type: TokenKind, Literal: []const u8 };

test "tokens" {
    const vals = [_]TokenKind{
        .SemiColon,
        .Colon,
        .LeftParen,
        .RightParen,
        .LeftBracket,
        .RightBracket,
        .LeftBrace,
        .RightBrace,
        .Equals,
        .Plus,
        .Minus,
        .Comma,
        .Dot,
        .LessThan,
        .GreaterThan,
    };
    const exp: []const []const u8 = &.{ ";", ":", "(", ")", "[", "]", "{", "}", "=", "+", "-", ",", ".", "<", ">" };
    for (vals, 0..) |v, idx| {
        if (!std.mem.eql(u8, v.repr(), exp[idx])) {
            std.debug.print("mismatch token - kind={s} kind.value={s} got.value={s}\n", .{ @tagName(v), v.repr(), exp[idx] });
            return error.TestUnexpectedResult;
        }
    }
}
