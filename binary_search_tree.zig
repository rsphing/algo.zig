const std = @import("std");
const Allocator = std.mem.Allocator;
const TreeNode = @import("binary_tree.zig").TreeNode;

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
            _ = self;
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
                self.root = try self.gpa.create(TreeNode(T));
                self.root = .{ .data = val };
                return;
            }

            var cur = self.root;
            var pre: *TreeNode(T) = undefined;
            while (cur != null) {
                if (cur.?.data == val) return;

                pre = cur.?;

                if (cur.?.data > val) {
                    cur = cur.?.left;
                } else {
                    cur = cur.?.right;
                }
            }

            var tmp = try self.gpa.create(TreeNode(T));
            tmp = .{ .data = val };
            if (pre.data > val) {
                pre.left = tmp;
            } else {
                pre.right = tmp;
            }
        }

        pub fn remove(self: *Self, val: T) !void {
            if (self.root == null) return;
            _ = val;
        }
    };
}
