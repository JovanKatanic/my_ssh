const std = @import("std");

pub fn main() !void {
    const address = try std.net.Address.parseIp4("127.0.0.1", 8081);

    var server = try address.listen(std.net.Address.ListenOptions{});
    defer server.deinit();

    while (true) {
        const conn = try server.accept();
        _ = try std.Thread.spawn(.{}, handleConnection, .{conn});
    }
}

fn handleConnection(conn: std.net.Server.Connection) !void {
    defer conn.stream.close();
    var buffer: [1024]u8 = undefined;
    var http_server = std.http.Server.init(conn, &buffer);
    var req = try http_server.receiveHead();
    const body_len = req.head.content_length orelse 0;
    std.debug.print("Received user data: {s}\n", .{buffer[req.head_end .. req.head_end + body_len]});

    const response_body = "a" ** 1026;

    const chunk_size: u64 = 200;
    var start_index: u64 = 0;
    while (start_index < response_body.len) {
        const end_index: u64 = @min(start_index + chunk_size, response_body.len);
        const chunk = response_body[start_index..end_index];
        try req.respond(chunk, std.http.Server.Request.RespondOptions{
            .transfer_encoding = .chunked,
        });
        start_index = end_index;
    }

    // Send the final chunk (with length 0 to signal the end)
    try req.respond(&[_]u8{}, std.http.Server.Request.RespondOptions{
        .transfer_encoding = .chunked,
    });
}
