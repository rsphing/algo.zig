const std = @import("std");

fn greaterThan(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b).invert();
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

    var max_heap = std.PriorityQueue(u32, void, greaterThan).init(allocator, {});
    defer max_heap.deinit();

    try max_heap.add(1);
    try max_heap.add(3);
    try max_heap.add(6);
    try max_heap.add(4);
    try max_heap.add(5);
    try max_heap.add(7);
    try printHeap(u32, allocator, max_heap.items[0..max_heap.count()]);
}
