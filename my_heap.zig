const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn MaxHeap(comptime T: type) type {
    return struct {
        const Self = @This();

        list: std.ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            return .{
                .list = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit();
        }

        pub fn size(self: *Self) usize {
            return self.list.items.len;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.list.items.len == 0;
        }

        pub fn peek(self: *Self) ?T {
            if (self.list.items.len == 0) return null;
            return self.list.items[0];
        }

        pub fn push(self: *Self, val: T) !void {
            try self.list.append(val);
            self.shiftUp(self.list.items.len - 1);
        }

        fn shiftUp(self: *Self, _i: usize) void {
            var i = _i;
            while (i > 0) {
                var p = ((i - 1) >> 1);
                if (self.list.items[p] >= self.list.items[i]) break;
                std.mem.swap(T, &self.list.items[p], &self.list.items[i]);
                i = p;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.isEmpty()) return null;

            var val = self.list.swapRemove(0);
            self.shiftDown(0);
            return val;
        }

        fn shiftDown(self: *Self, _i: usize) void {
            var i = _i;
            while (true) {
                var c = (std.math.mul(usize, i, 2) catch break) | 1;
                if (c >= self.size()) break;

                if (c + 1 < self.size() and self.list.items[c] < self.list.items[c + 1]) {
                    c += 1;
                }
                if (self.list.items[i] >= self.list.items[c]) break;
                std.mem.swap(T, &self.list.items[i], &self.list.items[c]);
                i = c;
            }
        }

        pub fn appendSlice(self: *Self, slice: []const T) !void {
            if (slice.len == 0) return;
            try self.list.insertSlice(self.list.items.len, slice);
            var i = ((self.list.items.len - 1) >> 1);
            while (i > 0) : (i -= 1) {
                self.shiftDown(i);
            }
            self.shiftDown(0);
        }
    };
}

fn printHeap(comptime T: type, gpa: Allocator, items: []T) !void {
    const binary_tree = @import("binary_tree.zig");
    const printTree = @import("print_util.zig").printTree;
    var tree = try binary_tree.arrToTree(T, gpa, items);
    printTree(T, tree.?);
    binary_tree.destroyTree(T, gpa, tree);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const arr = [_]u32{ 9, 8, 6, 6, 7, 5, 2, 1, 4, 3, 6, 2 };
    var maxheap = MaxHeap(u32).init(allocator);
    defer maxheap.deinit();

    try maxheap.appendSlice(&arr);
    std.debug.print("after created heap:\n", .{});
    try printHeap(u32, allocator, maxheap.list.items);

    var peek = maxheap.peek();
    std.debug.print("heap head: {any}\n", .{peek});

    try maxheap.push(7);
    std.debug.print("7 in heap:\n", .{});
    try printHeap(u32, allocator, maxheap.list.items);

    var pop = maxheap.pop();
    std.debug.print("out heap: {any}\n", .{pop});
    try printHeap(u32, allocator, maxheap.list.items);

    std.debug.print("heap size: {}\n", .{maxheap.size()});
    std.debug.print("heap empty: {any}\n", .{maxheap.isEmpty()});
}
