const std = @import("std");
const expect = std.testing.expect;

pub const FileReader = struct {
    alloc: std.mem.Allocator,
    buffer: []const u8,
    pos: usize,

    pub fn init(alloc: std.mem.Allocator, path: []const u8) !FileReader {
        var file = std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        // We're reading the full file into memory here, which is ok for now
        // but later on we should really consider making this more efficient
        const file_size = (try file.stat()).size;
        const content = try alloc.alloc(u8, file_size);
        var file_reader = file.reader(content);
        try file_reader.interface.fill(file_size);
        return .{
            .alloc = alloc,
            .buffer = content,
            .pos = 0,
        };
    }

    pub fn deinit(self: FileReader) void {
        try self.alloc.free(self.buffer);
    }

    pub fn peek(self: FileReader) !u8 {
        if (self.pos + 1 >= self.buffer.len) {
            return error.EndOfFile;
        }
        return self.buffer[self.pos + 1];
    }

    pub fn advance(self: *FileReader) !void {
        if (self.pos + 1 > self.buffer.len) {
            return error.EndOfFile;
        }

        self.pos = self.pos + 1;
    }

    pub fn curr(self: FileReader) u8 {
        return self.buffer[self.pos];
    }

    pub fn consume(self: *FileReader) !u8 {
        const c = self.curr();
        try self.advance();
        return c;
    }

    pub fn readUntil(self: *FileReader, delim: u8) ![]const u8 {
        const start = self.pos;
        while (self.curr() != delim) try self.advance();
        return self.buffer[start..self.pos];
    }
};

test "FileReader readChar" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    var r = FileReader{
        .alloc = gpa.allocator(),
        .buffer = &.{ 'H', 'e', 'l', 'l', 'o', ';' },
        .pos = 0,
    };

    var actual: [6]u8 = undefined;
    for (0..actual.len) |i| {
        actual[i] = try r.consume();
    }

    if (!std.mem.eql(u8, r.buffer, &actual)) {
        std.debug.print("incorrect content from FileReader - expected '{s}' got '{s}'", .{ r.buffer, actual });
        return error.TestUnexpectedResult;
    }
}

test "FileReader readUntil" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    var r = FileReader{
        .alloc = gpa.allocator(),
        .buffer = &.{ 'H', 'e', 'l', 'l', 'o', ';' },
        .pos = 0,
    };

    const actual = try r.readUntil(';');

    if (r.pos != 5) {
        std.debug.print("expected position to be before the delimter but was {d} = '{d}'", .{ r.pos, r.buffer[r.pos] });
        return error.TestUnexpectedResult;
    }

    const c = try r.consume();
    try std.testing.expectEqual(';', c);

    try std.testing.expectEqualStrings("Hello", actual);
}

// pub const Lexer = struct {
//     alloc: std.mem.Allocator,
//     fd: std.fs.File,
//     file_pos: usize,
//
//     pub fn init(alloc: std.mem.Allocator, path: []const u8) !Lexer {}
//
//     pub fn deinit(self: *Lexer) void {}
//
//     pub fn readChar(self: *Lexer) !u8 {}
// };
