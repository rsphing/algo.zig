const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const TreeNode = @import("binary_tree.zig").TreeNode;

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        const Self = @This();

        root: ?*TreeNode(T) = null,
        arena: ArenaAllocator = undefined,
        gpa: Allocator = undefined,

        pub fn init(gpa: Allocator, root: ?*TreeNode(T)) Self {
            var arena = ArenaAllocator.init(gpa);
            return .{
                .arena = arena,
                .gpa = arena.allocator(),
                .root = root,
            };
        }

        pub fn deinit(self: *Self) void {
            self.arena.deinit();
        }

        pub fn fromSlice(self: *Self, slice: []T) !void {
            const build = (struct {
                fn _build(gpa: Allocator, sl: []T) !?*TreeNode(T) {
                    if (sl.len == 0) return null;

                    var mid = sl.len / 2;
                    var node = try gpa.create(TreeNode(T));
                    node = .{ .data = sl[mid] };

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
                self.root = try self.gpa.create(TreeNode(T));
                self.root = .{ .data = val };
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

            var tmp = try self.gpa.create(TreeNode(T));
            tmp = .{ .data = val };
            if (pre.?.data > val) {
                pre.?.left = tmp;
            } else {
                pre.?.right = tmp;
            }
        }

        pub fn remove(self: *Self, val: T) !void {
            if (self.root == null) return;

            var cur = self.root;
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

            if (cur == null) return;
            if (cur.?.left == null or cur.?.right == null) {
                var node = if (cur.?.left != null) cur.?.left else cur.?.right;
                if (node != null) {}
            }
        }
    };
}
