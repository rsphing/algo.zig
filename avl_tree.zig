const std = @import("std");
const Allocator = std.mem.Allocator;
const TreeNode = @import("binary_tree.zig").TreeNode;

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
            _ = self;
        }

        pub fn height(node: ?*TreeNode(T)) i32 {
            return if (node == null) -1 else @as(i32, node.?.height);
        }

        pub fn balanceFactor(node: ?*TreeNode(T)) i32 {
            if (node == null) return 0;
            return height(node.?.left) - height(node.?.right);
        }

        fn updateHeight(node: *TreeNode(T)) void {
            node.height = @as(@TypeOf(node.height), @max(height(node.left), height(node.right)) + 1);
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
                    node.left = leftRotate(node.left);
                    return rightRotate(node);
                }
            }
            if (balance_factor < -1) {
                if (balanceFactor(node.right) <= 0) {
                    return leftRotate(node);
                } else {
                    node.right = rightRotate(node.right);
                    return leftRotate(node);
                }
            }

            return node;
        }

        pub fn insert(self: *Self, val: T) !void {
            self.root = try insertImpl(self.gpa, self.root, val);
        }

        fn insertImpl(gpa: Allocator, node: ?*TreeNode(T), val: T) !*TreeNode(T) {
            if (node == null) {
                var tmp = gpa.create(TreeNode(T));
                tmp.* = .{ .data = val };
                return tmp;
            }
        }
    };
}
