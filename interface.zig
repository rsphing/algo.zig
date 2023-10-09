const std = @import("std");
const builtin = @import("biiltin");

const Writer = struct {
    ptr: *anyopaque,
    writeAllFn: *const fn (ptr: *anyopaque, data: []const u8) anyerror!void,

    fn init(ptr: anytype) Writer {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);
        if (ptr_info != .Pointer) @compileError("ptr must be a pointer");
        if (ptr_info.Pointer.size != .One) @compileError("ptr must be a single item pointer");

        const gen = struct {
            pub fn writeAll(pointer: *anyopaque, data: []const u8) anyerror!void {
                const self: *File = @ptrCast(@alignCast(pointer));
                try @call(.always_inline, ptr_info.Pointer.child.writeAll, .{ self, data });
            }
        };

        return .{
            .ptr = ptr,
            .writeAllFn = gen.writeAll,
        };
    }

    fn writeAll(self: Writer, data: []const u8) !void {
        return self.writeAllFn(self.ptr, data);
    }
};

const File = struct {
    fd: std.os.fd_t,

    fn writeAll(self: *File, data: []const u8) !void {
        _ = try std.os.write(self.fd, data);
    }

    fn writer(self: *File) Writer {
        return Writer.init(self);
    }
};

pub fn main() !void {
    var file = File{ .fd = std.io.getStdOut().handle };
    const out = file.writer();
    try out.writeAll("hello\n");
}
