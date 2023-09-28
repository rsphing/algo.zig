const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn TreeNode(comptime T: type) type {
    return struct {
        const Self = @This();

        data: T = undefined,
        height: i32 = 0,
        left: ?*Self = null,
        right: ?*Self = null,
    };
}

pub fn createNode(comptime T: type, gpa: Allocator, val: T) !*TreeNode(T) {
    var node = try gpa.create(TreeNode(T));
    node.* = .{ .data = val };
    return node;
}

pub fn arrToTree(comptime T: type, allocator: Allocator, arr: []T) !?*TreeNode(T) {
    if (arr.len == 0) return null;

    var pending = std.hash_map.AutoHashMap(usize, *TreeNode(T)).init(allocator);
    defer pending.deinit();

    var root: ?*TreeNode(T) = null;
    var size: usize = arr.len;
    while (size > 0) : (size -= 1) {
        var pos = size - 1;

        var node = try createNode(T, allocator, arr[pos]);

        var child_pos = 2 * pos + 1;
        if (pending.fetchRemove(child_pos)) |kv| {
            node.left = kv.value;
            node.height = node.left.?.height + 1;
        }
        child_pos += 1;
        if (pending.fetchRemove(child_pos)) |kv| {
            node.right = kv.value;
            node.height = @max(node.height, node.right.?.height + 1);
        }

        if (pos > 0) {
            try pending.put(pos, node);
        } else {
            root = node;
        }
    }

    return root;
}

pub fn destroyTree(comptime T: type, gpa: Allocator, node: ?*TreeNode(T)) void {
    if (node == null) return;
    destroyTree(T, gpa, node.?.left);
    destroyTree(T, gpa, node.?.right);
    gpa.destroy(node.?);
}
