const std = @import("std");
const hello = @import("hello");

const assert = std.debug.assert;
const mem = std.mem;

pub fn world() []const u8 {
    return "World!";
}

pub fn helloWorld() []const u8 {
    return comptime hello.hello() ++ world();
}

test "unit test world()" {
    comptime {
        assert(mem.eql(u8, world(), "World!"));
    }
}

test "unit test helloWorld()" {
    comptime {
        assert(mem.eql(u8, helloWorld(), "Hello, World!"));
    }
}
