const std = @import("std");
pub fn main() !void {
    var cmd = std.process.Child.init(&[_][]const u8{ "sudo", "ls" }, std.heap.page_allocator);
    cmd.stdout_behavior = .Inherit;
    cmd.stdin_behavior = .Inherit;

    try cmd.spawn();
    _ = try cmd.wait();
}
