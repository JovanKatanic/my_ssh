const std = @import("std");
const BUFFER_SIZE = 4096;
const SERVER_ADDR = "http://127.0.0.1:8080";
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var buf: [BUFFER_SIZE]u8 = undefined;
    const uri = try std.Uri.parse(SERVER_ADDR);
    var request = try client.open(.POST, uri, .{
        .server_header_buffer = &buf,
    });
    defer request.deinit();
    const message = "hej";
    request.transfer_encoding = .{ .content_length = message.len };
    try request.send();
    _ = try request.writer().write(message);
    try request.finish();
    try request.wait();

    var chunk_buf: [BUFFER_SIZE]u8 = undefined;
    while (true) {
        const chunk_size = try request.reader().read(&chunk_buf);
        if (chunk_size == 0) {
            break;
        }
        try std.io.getStdOut().writer().writeAll(chunk_buf[0..chunk_size]);
    }

    std.debug.print("EXITED CLIENT\n", .{});
}
