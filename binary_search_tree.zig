const std = @import("std");
const Allocator = std.mem.Allocator;
const binary_tree = @import("binary_tree.zig");
const TreeNode = binary_tree.TreeNode;

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        const Self = @This();

        root: ?*TreeNode(T) = null,
        gpa: Allocator = undefined,

        pub fn init(gpa: Allocator, root: ?*TreeNode(T)) Self {
            return .{
                .gpa = gpa,
                .root = root,
            };
        }

        pub fn deinit(self: *Self) void {
            binary_tree.destroyTree(T, self.gpa, self.root);
        }

        pub fn fromSlice(self: *Self, slice: []T) !void {
            const build = (struct {
                fn _build(gpa: Allocator, sl: []T) !?*TreeNode(T) {
                    if (sl.len == 0) return null;

                    var mid = sl.len / 2;
                    var node = try binary_tree.createNode(T, gpa, sl[mid]);

                    if (mid >= 1) node.left = try _build(gpa, sl[0..mid]);
                    node.right = try _build(gpa, sl[mid + 1 ..]);
                    return node;
                }
            })._build;

            std.mem.sort(T, slice, {}, comptime std.sort.asc(T));
            self.root = try build(self.gpa, slice);
        }

        pub fn search(self: *Self, val: T) ?*TreeNode(T) {
            if (self.root == null) return null;

            var cur = self.root;
            while (cur != null) {
                if (cur.?.data > val) {
                    cur = cur.?.left;
                } else if (cur.?.data < val) {
                    cur = cur.?.right;
                } else {
                    break;
                }
            }
            return cur;
        }

        pub fn insert(self: *Self, val: T) !void {
            if (self.root == null) {
                self.root = try binary_tree.createNode(T, self.gpa, val);
                return;
            }

            var cur = self.root;
            var pre: ?*TreeNode(T) = null;
            while (cur != null) {
                if (cur.?.data == val) return;

                pre = cur;

                if (cur.?.data > val) {
                    cur = cur.?.left;
                } else {
                    cur = cur.?.right;
                }
            }

            var tmp = try binary_tree.createNode(T, self.gpa, val);
            if (pre.?.data > val) {
                pre.?.left = tmp;
            } else {
                pre.?.right = tmp;
            }
        }

        pub fn remove(self: *Self, val: T) void {
            self.root = Self.removeImpl(self.gpa, self.root, val);
        }

        fn removeImpl(gpa: Allocator, _root: ?*TreeNode(T), val: T) ?*TreeNode(T) {
            if (_root == null) return null;

            var root = _root;
            var cur = root;
            var pre: ?*TreeNode(T) = null;
            while (cur != null) {
                if (cur.?.data == val) break;

                pre = cur;

                if (cur.?.data > val) {
                    cur = cur.?.left;
                } else {
                    cur = cur.?.right;
                }
            }

            if (cur == null) return root;
            if (cur.?.left == null or cur.?.right == null) {
                var child = if (cur.?.left != null) cur.?.left else cur.?.right;
                if (cur != root) {
                    if (cur == pre.?.left) {
                        pre.?.left = child;
                    } else {
                        pre.?.right = child;
                    }
                } else {
                    root = child;
                }
                gpa.destroy(cur.?);
            } else {
                var tmp = cur.?.right;
                while (tmp.?.left != null) {
                    tmp = tmp.?.left;
                }
                var tmpVal = tmp.?.data;
                _ = removeImpl(gpa, cur, tmp.?.data);
                cur.?.data = tmpVal;
            }
            return root;
        }
    };
}

pub fn main() !void {
    const printTree = @import("print_util.zig").printTree;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var bstree = BinarySearchTree(u32).init(gpa.allocator(), null);
    defer bstree.deinit();

    var nums = [_]u32{ 8, 4, 12, 2, 6, 10, 14, 1, 3, 5, 7, 9, 11, 13, 15 };

    inline for (nums) |num| {
        try bstree.insert(num);
    }
    //try bstree.fromSlice(&nums);
    std.debug.print("初始化的二叉树:\n", .{});
    printTree(u32, bstree.root.?);

    var node = bstree.search(7);
    std.debug.print("查找到节点为对象为: {any}\n", .{node});

    try bstree.insert(16);
    std.debug.print("插入节点 16 后, 二叉树为:\n", .{});
    printTree(u32, bstree.root.?);

    bstree.remove(1);
    std.debug.print("删除节点 1 后, 二叉树为:\n", .{});
    printTree(u32, bstree.root.?);
    bstree.remove(2);
    std.debug.print("删除节点 2 后, 二叉树为:\n", .{});
    printTree(u32, bstree.root.?);
    bstree.remove(4);
    std.debug.print("删除节点 4 后, 二叉树为:\n", .{});
    printTree(u32, bstree.root.?);
}
