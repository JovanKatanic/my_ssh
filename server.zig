const std = @import("std");
const HOST_ADDR = "127.0.0.1";
const PORT = 8080;
const BUFFER_SIZE = 4096;
pub fn main() !void {
    const address = try std.net.Address.parseIp4(HOST_ADDR, PORT);
    var server = try address.listen(std.net.Address.ListenOptions{});
    defer server.deinit();

    while (true) {
        const conn = try server.accept();
        _ = try std.Thread.spawn(.{}, handleConnection, .{conn.stream});
    }
}

fn handleConnection(conn: std.net.Stream) !void {
    defer conn.close();
    var recv_buf: [BUFFER_SIZE]u8 = undefined;

    const response_body = "a" ** 200;

    while (true) {
        const bytes_read = try conn.reader().read(&recv_buf);
        if (bytes_read == 0) {
            std.debug.print("Break loop\n", .{});
            break;
        }
        //TODO execute command

        std.debug.print("Server: {s}\n", .{recv_buf[0..bytes_read]});
        try conn.writer().writeAll(response_body);
    }

    std.debug.print("EXITED SERVER THREAD", .{});
}
