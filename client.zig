const std = @import("std");
const packet = @import("./packet.zig");

const BUFFER_SIZE = 4096;
const HOST_ADDR = "127.0.0.1";
const PORT = 8081;

var completed_version_exchange = false;
var version_exchanged: []u8 = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const address = try std.net.Address.parseIp4(HOST_ADDR, PORT);
    const conn = try std.net.tcpConnectToAddress(address);
    defer conn.close();
    const recv_buf = try allocator.alloc(u8, BUFFER_SIZE);
    while (true) {
        const command = try std.io.getStdIn().reader().readUntilDelimiterOrEofAlloc(allocator, '\n', BUFFER_SIZE) orelse "";
        defer allocator.free(command);

        if (command.len == 0) {
            continue;
        }
        try conn.writer().writeAll(command);
        while (true) {
            const bytes_read = try conn.reader().read(recv_buf);
            std.debug.print("Server: {d}\n", .{bytes_read});

            const packet = Packet{
                .packet_length=33,
            };

            const bytes = std.mem.asBytes(&packet);

            if (!completed_version_exchange) {
                std.debug.print("Version: {s}\n", .{recv_buf[0..bytes_read]});
                version_exchanged = recv_buf[0..bytes_read]; //TODO should end with CR CF
            }

            if (bytes_read == 0 or bytes_read != BUFFER_SIZE) {
                std.debug.print("Break read loop\n", .{});
                break;
            }
        }
    }

    std.debug.print("EXITED CLIENT\n", .{});
}
