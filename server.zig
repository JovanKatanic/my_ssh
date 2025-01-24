const std = @import("std");
const HOST_ADDR = "127.0.0.1";
const PORT = 8080;
pub fn main() !void {
    const address = try std.net.Address.parseIp4(HOST_ADDR, PORT);

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

    const response_body = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n" ** 100;

    try req.respond(response_body, std.http.Server.Request.RespondOptions{ .transfer_encoding = .chunked });
    std.debug.print("EXITED SERVER THREAD", .{});
}
