const std = @import("std");
const hello = @import("hello");
const world = @import("world");
const assert = std.debug.assert;
const mem = std.mem;

test "integ test hello world" {
    comptime {
        assert(mem.eql(u8, hello.hello() ++ world.world(), "Hello, World!"));
    }
}
