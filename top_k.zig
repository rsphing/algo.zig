const std = @import("std");

fn lessThan(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

pub fn topKHeap(comptime T: type, heap: *std.PriorityQueue(T, void, lessThan), slice: []T, k: u32) !*std.PriorityQueue(T, void, lessThan) {
    if (slice.len < k) return (error{SliceNotEnoughLen}).SliceNotEnoughLen;
    for (0..k) |i| {
        try heap.add(slice[i]);
    }

    for (k..slice.len) |i| {
        if (slice[i] > heap.peek().?) {
            _ = heap.remove();
            try heap.add(slice[i]);
        }
    }
    return heap;
}

fn printHeap(comptime T: type, gpa: std.mem.Allocator, items: []T) !void {
    const binary_tree = @import("binary_tree.zig");
    const printTree = @import("print_util.zig").printTree;
    var tree = try binary_tree.arrToTree(T, gpa, items);
    printTree(T, tree.?);
    binary_tree.destroyTree(T, gpa, tree);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var max_heap = std.PriorityQueue(u32, void, lessThan).init(allocator, {});
    defer max_heap.deinit();

    var arr = [_]u32{ 1, 3, 4, 6, 5, 7, 9, 8, 2, 11, 13, 15, 20 };
    _ = try topKHeap(u32, &max_heap, &arr, 7);
    try printHeap(u32, allocator, max_heap.items[0..max_heap.count()]);
}
