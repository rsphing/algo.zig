const std = @import("std");
const Allocator = std.mem.Allocator;
const GraphAdjList = @import("graph_adjacency_list.zig").GraphAdjList;

const GraphU32 = GraphAdjList(u32);
const Vertex = GraphU32.Vertex;

pub fn graph_bfs(graph: *const GraphU32, start_vert: *Vertex, res: []*const Vertex) !usize {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const alloc = Arena.allocator();

    var visited = std.hash_map.AutoHashMap(*Vertex, void).init(alloc);

    const L = std.DoublyLinkedList(*Vertex);
    var que = L{};

    try visited.put(start_vert, {});
    var start_node = L.Node{ .data = start_vert };
    que.append(&start_node);

    var index: usize = 0;
    while (que.len > 0) : (index += 1) {
        if (index >= res.len) break;

        var vert = que.popFirst().?.data;
        res[index] = vert;

        if (graph.adj_list.get(vert)) |list| {
            var it = list.first;
            while (it) |node| : (it = node.next) {
                if (visited.contains(node.data)) {
                    continue;
                }
                var new_node = try alloc.create(L.Node);
                new_node.*.data = node.data;
                que.append(new_node);
                try visited.put(node.data, {});
            }
        }
    }
    return index;
}

pub fn main() void {
    const print = std.debug.print;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var graph = GraphU32.init(allocator);
    defer graph.deinit();

    const vals = [_]u32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var v = allocator.alloc(GraphU32.Vertex, vals.len) catch unreachable;
    defer allocator.free(v);

    for (vals, 0..) |val, i| {
        v[i].val = val;
        graph.add_vertex(&v[i]);
    }

    graph.add_edge(&v[0], &v[1]);
    graph.add_edge(&v[0], &v[3]);
    graph.add_edge(&v[1], &v[2]);
    graph.add_edge(&v[1], &v[4]);
    graph.add_edge(&v[2], &v[5]);
    graph.add_edge(&v[3], &v[4]);
    graph.add_edge(&v[3], &v[6]);
    graph.add_edge(&v[4], &v[5]);
    graph.add_edge(&v[4], &v[7]);
    graph.add_edge(&v[5], &v[8]);
    graph.add_edge(&v[6], &v[7]);
    graph.add_edge(&v[7], &v[8]);

    print("\n初始化后, 图为:\n", .{});
    graph.print();

    var res = allocator.alloc(*Vertex, graph.size()) catch unreachable;
    defer allocator.free(res);

    var size = graph_bfs(&graph, &v[0], res) catch unreachable;
    print("\n广度优先遍历(BFS)顶点序列为:\n[", .{});
    for (res[0..size], 0..) |item, i| {
        print("{any}{s}", .{ item.val, if (i < size - 1) ", " else "" });
    }
    print("]\n", .{});
}
