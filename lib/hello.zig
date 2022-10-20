const std = @import("std");

const assert = std.debug.assert;
const mem = std.mem;

pub fn hello() []const u8 {
    return "Hello, ";
}

test "unit test hello()" {
    // https://ziglang.org/documentation/master/#Arrays
    comptime {
        assert(mem.eql(u8, hello(), "Hello, "));
    }
}
