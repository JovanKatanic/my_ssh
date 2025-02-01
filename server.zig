const std = @import("std");
const HOST_ADDR = "127.0.0.1";
const PORT = 8081;
const BUFFER_SIZE = 4096;

const protocol_version = "SSH-2.0-SSHServer";
const protocol_version_comments = "Ubuntu20.04";

pub fn main() !void {
    const address = try std.net.Address.parseIp4(HOST_ADDR, PORT);
    var server = try address.listen(std.net.Address.ListenOptions{ .reuse_address = true, .reuse_port = true }); //TODO should add NO_DELAY to sockets
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
        if (std.mem.eql(u8, recv_buf[0..bytes_read], "CONNECT")) { //TODO should not be bytes read
            try conn.writer().writeAll(protocol_version ++ " " ++ protocol_version_comments ++ "\r\n");
        } else {
            try conn.writer().writeAll(response_body);
        }
    }

    std.debug.print("EXITED SERVER THREAD", .{});
}
