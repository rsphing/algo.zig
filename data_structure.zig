const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();
        const L = std.DoublyLinkedList(T);

        linked: L = undefined,
        gpa: Allocator = undefined,

        pub fn init(gpa: Allocator) Self {
            return .{
                .linked = L{},
                .gpa = gpa,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.linked.popFirst()) |node| {
                self.gpa.destroy(node);
            }
            self.* = undefined;
        }

        pub fn push(self: *Self, data: T) !void {
            var tmp = try self.gpa.create(L.Node);
            tmp.* = .{ .data = data };
            self.linked.append(tmp);
        }

        pub fn pop(self: *Self) ?T {
            if (self.linked.popFirst()) |node| {
                var data = node.data;
                self.gpa.destroy(node);
                return data;
            }
            return null;
        }

        pub fn peak(self: *Self) ?*T {
            if (self.linked.first) |node| {
                return &node.data;
            }
            return null;
        }

        pub fn len(self: *Self) usize {
            return self.linked.len();
        }
    };
}

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        const L = std.SinglyLinkedList(T);

        linked: L = undefined,
        gpa: Allocator = undefined,

        pub fn init(gpa: Allocator) Self {
            return .{
                .linked = L{},
                .gpa = gpa,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.linked.popFirst()) |node| {
                self.gpa.destroy(node);
            }
            self.* = undefined;
        }

        pub fn push(self: *Self, data: T) !void {
            var tmp = try self.gpa.create(L.Node);
            tmp.* = .{ .data = data };
            self.linked.prepend(tmp);
        }

        pub fn pop(self: *Self) ?T {
            if (self.linked.popFirst()) |node| {
                var data = node.data;
                self.gpa.destroy(node);
                return data;
            }
            return null;
        }

        pub fn peak(self: *Self) ?*T {
            if (self.linked.first) |node| {
                return &node.data;
            }
            return null;
        }

        pub fn len(self: *Self) usize {
            return self.linked.len();
        }
    };
}
