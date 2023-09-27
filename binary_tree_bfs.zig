const std = @import("std");
const Allocator = std.mem.Allocator;
const binary_tree = @import("binary_tree.zig");
const TreeNode = binary_tree.TreeNode;

pub fn levelOrder(comptime T: type, gpa: Allocator, root: *TreeNode(T)) !std.ArrayList(T) {
    const L = std.DoublyLinkedList(*TreeNode(T));
    var que = L{};
    defer (struct {
        fn free(l: *L, alloc: Allocator) void {
            while (l.popFirst()) |node| {
                alloc.destroy(node);
            }
        }
    }).free(&que, gpa);

    var list = std.ArrayList(T).init(gpa);
    errdefer list.deinit();

    {
        var tmp = try gpa.create(L.Node);
        tmp.* = .{ .data = root };
        que.append(tmp);
    }

    while (que.popFirst()) |item| {
        const node = item.data;
        gpa.destroy(item);

        try list.append(node.data);

        if (node.left) |left| {
            var tmp = try gpa.create(L.Node);
            tmp.* = .{ .data = left };
            que.append(tmp);
        }
        if (node.right) |right| {
            var tmp = try gpa.create(L.Node);
            tmp.* = .{ .data = right };
            que.append(tmp);
        }
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

    var list = try levelOrder(u32, allocator, tree.?);
    defer list.deinit();

    print_util.printSlice(u32, list.items);
}
