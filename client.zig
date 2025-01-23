const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var buf: [2048]u8 = undefined;
    const uri = try std.Uri.parse("http://127.0.0.1:8081");
    var request = try client.open(.POST, uri, .{
        .server_header_buffer = &buf,
    });
    defer request.deinit();
    const message = "a" ** 800;
    request.transfer_encoding = .{ .content_length = message.len };
    try request.send();
    _ = try request.writer().write(message);
    try request.finish();
    try request.wait();

    const body = try request.reader().readAllAlloc(allocator, 256);
    defer allocator.free(body);
    std.debug.print("{s}", .{body});
}
