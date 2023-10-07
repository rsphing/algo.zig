const std = @import("std");
const Allocator = std.mem.Allocator;
const binary_tree = @import("binary_tree.zig");
const TreeNode = binary_tree.TreeNode;

pub fn AVLTree(comptime T: type) type {
    return struct {
        const Self = @This();

        root: ?*TreeNode(T) = null,
        gpa: Allocator = undefined,

        pub fn init(gpa: Allocator) Self {
            return .{
                .gpa = gpa,
            };
        }

        pub fn deinit(self: *Self) void {
            binary_tree.destroyTree(T, self.gpa, self.root);
        }

        pub fn height(node: ?*TreeNode(T)) i32 {
            return if (node == null) -1 else node.?.height;
        }

        pub fn balanceFactor(node: ?*TreeNode(T)) i32 {
            if (node == null) return 0;
            return height(node.?.left) - height(node.?.right);
        }

        fn updateHeight(node: *TreeNode(T)) void {
            node.height = @max(height(node.left), height(node.right)) + 1;
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

        fn rightRotate(node: *TreeNode(T)) *TreeNode(T) {
            var child = node.left.?;
            var grand_child = node.right;
            child.right = node;
            node.left = grand_child;

            updateHeight(node);
            updateHeight(child);

            return child;
        }

        fn leftRotate(node: *TreeNode(T)) *TreeNode(T) {
            var child = node.right.?;
            var grand_child = node.left;
            child.left = node;
            node.right = grand_child;

            updateHeight(node);
            updateHeight(child);

            return child;
        }

        fn rotate(node: *TreeNode(T)) *TreeNode(T) {
            var balance_factor = balanceFactor(node);
            if (balance_factor > 1) {
                if (balanceFactor(node.left) >= 0) {
                    return rightRotate(node);
                } else {
                    node.left = leftRotate(node.left.?);
                    return rightRotate(node);
                }
            }
            if (balance_factor < -1) {
                if (balanceFactor(node.right) <= 0) {
                    return leftRotate(node);
                } else {
                    node.right = rightRotate(node.right.?);
                    return leftRotate(node);
                }
            }

            return node;
        }

        pub fn insert(self: *Self, val: T) !void {
            self.root = try insertImpl(self.gpa, self.root, val);
        }

        fn insertImpl(gpa: Allocator, node: ?*TreeNode(T), val: T) !*TreeNode(T) {
            if (node == null) return binary_tree.createNode(T, gpa, val);

            if (node.?.data > val) {
                node.?.left = try insertImpl(gpa, node.?.left, val);
            } else if (node.?.data < val) {
                node.?.right = try insertImpl(gpa, node.?.right, val);
            } else {
                return node.?;
            }

            updateHeight(node.?);
            return rotate(node.?);
        }

        pub fn remove(self: *Self, val: T) void {
            self.root = removeImpl(self.gpa, self.root, val);
        }

        fn removeImpl(gpa: Allocator, node: ?*TreeNode(T), val: T) ?*TreeNode(T) {
            if (node == null) return null;

            if (node.?.data > val) {
                node.?.left = removeImpl(gpa, node.?.left, val);
            } else if (node.?.data < val) {
                node.?.right = removeImpl(gpa, node.?.right, val);
            } else {
                if (node.?.left == null or node.?.right == null) {
                    var tmp = node.?.left orelse node.?.right;
                    gpa.destroy(node.?);
                    return tmp;
                } else {
                    var cur = node.?.right;
                    while (cur.?.left != null) {
                        cur = cur.?.left;
                    }

                    var tmp_val = cur.?.data;
                    node.?.right = removeImpl(gpa, node.?.right, tmp_val);
                    node.?.data = tmp_val;
                }
            }
            updateHeight(node.?);
            return rotate(node.?);
        }
    };
}

pub fn main() !void {
    const printTree = @import("print_util.zig").printTree;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var avltree = AVLTree(u32).init(gpa.allocator());
    defer avltree.deinit();

    var nums = [_]u32{ 8, 4, 12, 2, 6, 10, 14, 1, 3, 5, 7, 9, 11, 13, 15 };

    inline for (nums) |num| {
        try avltree.insert(num);
    }
    std.debug.print("初始化的AVL树:\n", .{});
    printTree(u32, avltree.root.?);

    try avltree.insert(7);
    std.debug.print("插入重复节点 7 后:\n", .{});
    printTree(u32, avltree.root.?);

    avltree.remove(8);
    avltree.remove(5);
    avltree.remove(4);
    std.debug.print("删除节点 8,5,4 后, AVL树为:\n", .{});
    printTree(u32, avltree.root.?);

    var node = avltree.search(7);
    std.debug.print("查找到节点为 7 对象为: {any}\n", .{node});
}
