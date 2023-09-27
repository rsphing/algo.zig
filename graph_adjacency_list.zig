// File: graph_adjacency_list.zig
// Created Time: 2023-09-16
// Author: szeph (szeph@gmail.com)

const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.hash_map.AutoHashMap;
const DoublyLinkedList = std.DoublyLinkedList;

pub fn GraphAdjList(comptime T: type) type {
    return struct {
        const Self = @This();
        const LinkedList = DoublyLinkedList(*Vertex);
        const VertexMap = AutoHashMap(*Vertex, LinkedList);

        pub const Vertex = struct {
            val: T,
        };

        adj_list: VertexMap,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .adj_list = VertexMap.init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            var iter = self.adj_list.iterator();
            while (iter.next()) |entry| {
                while (entry.value_ptr.pop()) |node| {
                    self.allocator.destroy(node);
                }
            }
            self.adj_list.deinit();
        }

        pub fn size(self: *Self) u32 {
            return @intCast(self.adj_list.count());
        }

        pub fn add_vertex(self: *Self, vert: *Vertex) void {
            if (self.adj_list.contains(vert)) {
                return;
            }
            self.adj_list.put(vert, LinkedList{}) catch unreachable;
        }

        pub fn remove_vertex(self: *Self, vert: *Vertex) void {
            if (self.adj_list.fetchRemove(vert)) |kv| {
                var it = kv.value.first;
                while (it) |node| : (it = node.next) {
                    self.remove(
                        self.adj_list.getPtr(node.data).?,
                        vert,
                    );
                }
            }
        }

        pub fn add_edge(self: *Self, vert1: *Vertex, vert2: *Vertex) void {
            if (vert1 == vert2 or !self.adj_list.contains(vert1) or !self.adj_list.contains(vert2)) {
                @panic("不存在顶点或边");
            }
            var node1 = self.allocator.create(LinkedList.Node) catch unreachable;
            node1.* = .{ .data = vert1 };
            var node2 = self.allocator.create(LinkedList.Node) catch unreachable;
            node2.* = .{ .data = vert2 };
            self.adj_list.getPtr(vert1).?.append(node2);
            self.adj_list.getPtr(vert2).?.append(node1);
        }

        pub fn remove_edge(self: *Self, vert1: *Vertex, vert2: *Vertex) void {
            if (vert1 == vert2 or !self.adj_list.contains(vert1) or !self.adj_list.contains(vert2)) {
                @panic("不存在顶点或边");
            }

            self.remove(self.adj_list.getPtr(vert1).?, vert2);
            self.remove(self.adj_list.getPtr(vert2).?, vert1);
        }

        fn remove(self: *Self, list: *LinkedList, vert: *Vertex) void {
            var it = list.first;
            while (it) |node| : (it = node.next) {
                if (node.data == vert) {
                    list.remove(node);
                    self.allocator.destroy(node);
                    break;
                }
            }
        }

        pub fn print(self: *Self) void {
            const out = std.debug.print;
            out("邻接表 =\n", .{});
            var iter = self.adj_list.iterator();
            while (iter.next()) |entry| {
                out("{any}: [", .{entry.key_ptr.*.val});
                var it = entry.value_ptr.*.first;
                while (it) |node| : (it = node.next) {
                    out("{any}{s}", .{ node.data.*.val, if (node.next != null) ", " else "" });
                }
                out("]\n", .{});
            }
        }
    };
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const GraphU32 = GraphAdjList(u32);

    var graph = GraphU32.init(allocator);
    defer graph.deinit();

    const vals = [_]u32{ 1, 3, 2, 5, 4 };
    var verts = allocator.alloc(GraphU32.Vertex, vals.len) catch unreachable;
    defer allocator.free(verts);

    for (vals, 0..) |val, i| {
        verts[i].val = val;
        graph.add_vertex(&verts[i]);
    }

    graph.add_edge(&verts[0], &verts[1]);
    graph.add_edge(&verts[0], &verts[3]);
    graph.add_edge(&verts[1], &verts[2]);
    graph.add_edge(&verts[2], &verts[3]);
    graph.add_edge(&verts[2], &verts[4]);
    graph.add_edge(&verts[3], &verts[4]);

    print("\n初始化后, 图为:\n", .{});
    graph.print();

    graph.add_edge(&verts[0], &verts[2]);
    print("\n添加边 1-2 后图为:\n", .{});
    graph.print();

    graph.remove_edge(&verts[0], &verts[1]);
    print("\n删除边 1-3 后图为:\n", .{});
    graph.print();

    var vert6 = allocator.create(GraphU32.Vertex) catch unreachable;
    vert6.val = 6;
    defer allocator.destroy(vert6);

    graph.add_vertex(vert6);
    print("\n添加顶点 6 后图为:\n", .{});
    graph.print();

    graph.remove_vertex(&verts[1]);
    print("\n删除顶点 3 后图为:\n", .{});
    graph.print();
}
