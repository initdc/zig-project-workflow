const std = @import("std");
const world = @import("world");
const print = std.debug.print;

const assert = std.debug.assert;
const mem = std.mem;

pub fn main() void {
    print("{s}\n", .{world.helloWorld()});
}

test "test main()" {
    comptime {
        assert(mem.eql(u8, world.helloWorld(), "Hello, World!"));
    }
}
