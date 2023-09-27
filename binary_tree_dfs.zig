const std = @import("std");
const Allocator = std.mem.Allocator;
const binary_tree = @import("binary_tree.zig");
const TreeNode = binary_tree.TreeNode;
const Stack = @import("data_structure.zig").Stack;

pub fn preOrder(comptime T: type, gpa: Allocator, root: *TreeNode(T)) !std.ArrayList(T) {
    var stack = Stack(*TreeNode(T)).init(gpa);
    defer stack.deinit();

    try stack.push(root);

    var list = std.ArrayList(T).init(gpa);
    errdefer list.deinit();

    while (stack.pop()) |node| {
        try list.append(node.data);

        if (node.right != null) {
            try stack.push(node.right.?);
        }
        if (node.left != null) {
            try stack.push(node.left.?);
        }
    }
    return list;
}

pub fn inOrder(comptime T: type, gpa: Allocator, root: *TreeNode(T)) !std.ArrayList(T) {
    var stack = Stack(*TreeNode(T)).init(gpa);
    defer stack.deinit();

    var left_ptr = root.left;
    try stack.push(root);

    var list = std.ArrayList(T).init(gpa);
    errdefer list.deinit();

    while (stack.len() > 0) {
        if (left_ptr != null) {
            try stack.push(left_ptr.?);
            left_ptr = left_ptr.?.left;
            continue;
        }

        var node = stack.pop().?;
        try list.append(node.data);

        if (node.right) |right| {
            try stack.push(right);
            left_ptr = right.left;
        }
    }
    return list;
}

pub fn postOrder(comptime T: type, gpa: Allocator, root: *TreeNode(T)) !std.ArrayList(T) {
    var stack = Stack(*TreeNode(T)).init(gpa);
    defer stack.deinit();
    var right_ptr = Stack(?*TreeNode(T)).init(gpa);
    defer right_ptr.deinit();

    var left_ptr = root.left;
    try right_ptr.push(root.right);
    try stack.push(root);

    var list = std.ArrayList(T).init(gpa);
    errdefer list.deinit();

    while (stack.len() > 0) {
        if (left_ptr != null) {
            try stack.push(left_ptr.?);
            try right_ptr.push(left_ptr.?.right);
            left_ptr = left_ptr.?.left;
            continue;
        }

        if (right_ptr.peak()) |data_ptr| {
            if (data_ptr.*) |node| {
                try right_ptr.push(node.right);
                try stack.push(node);
                left_ptr = node.left;
                data_ptr.* = null;
                continue;
            }
            _ = right_ptr.pop();
        }

        var node = stack.pop().?;
        try list.append(node.data);
    }
    return list;
}

pub fn main() !void {
    const print_util = @import("print_util.zig");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arr = [_]u32{ 3, 5, 1, 6, 2, 4, 7, 8, 10, 9 };
    const tree = try binary_tree.arrToTree(u32, allocator, &arr);

    print_util.printTree(u32, tree.?);

    var list = try preOrder(u32, allocator, tree.?);
    print_util.printSlice(u32, list.items);
    list.deinit();

    list = try inOrder(u32, allocator, tree.?);
    print_util.printSlice(u32, list.items);
    list.deinit();

    list = try postOrder(u32, allocator, tree.?);
    print_util.printSlice(u32, list.items);
    list.deinit();
}
