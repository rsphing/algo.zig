const std = @import("std");
const TreeNode = @import("binary_tree.zig").TreeNode;

pub fn printTree(comptime T: type, root: *TreeNode(T)) void {
    const _print_tree = (struct {
        const Trunk = struct {
            prev: ?*Trunk = null,
            str: []const u8 = undefined,
        };
        fn showTrunks(trunk: ?*Trunk) void {
            if (trunk) |t| {
                showTrunks(t.prev);
                std.debug.print("{s}", .{t.str});
            }
        }
        fn print(node: ?*TreeNode(T), prev: ?*Trunk, isLeft: bool) void {
            if (node == null) return;
            var prev_str: []const u8 = "    ";
            var trunk = Trunk{
                .prev = prev,
                .str = prev_str,
            };
            print(node.?.right, &trunk, true);

            if (prev == null) {
                trunk.str = "---";
            } else if (isLeft) {
                trunk.str = "/---";
                prev_str = "   |";
            } else {
                trunk.str = "\\---";
                prev.?.str = prev_str;
            }

            showTrunks(&trunk);
            std.debug.print(" {}\n", .{node.?.data});
            if (prev != null) {
                prev.?.str = prev_str;
            }
            trunk.str = "   |";

            print(node.?.left, &trunk, false);
        }
    }).print;

    _print_tree(root, null, false);
}

pub fn printSlice(comptime T: type, slice: []T) void {
    std.debug.print("[", .{});
    for (slice, 1..) |val, i| {
        std.debug.print("{}{s}", .{ val, if (i < slice.len) ", " else "" });
    }
    std.debug.print("]\n", .{});
}
