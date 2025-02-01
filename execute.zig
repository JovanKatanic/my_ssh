const std = @import("std");
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var command_output: [1024]u8 = undefined;

    var cmd = std.process.Child.init(&[_][]const u8{ "sudo", "ls" }, allocator);
    cmd.stdout_behavior = .Pipe;

    try cmd.spawn(); //TODO fix "[sudo] password for jovankatanic:"

    _ = try cmd.stdout.?.reader().read(&command_output);

    std.debug.print("out: {s}", .{command_output[0..]});
    _ = try cmd.wait();
}
