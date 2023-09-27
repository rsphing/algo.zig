const std = @import("std");
const Allocator = std.mem.Allocator;
const GraphAdjList = @import("graph_adjacency_list.zig").GraphAdjList;

const GraphU32 = GraphAdjList(u32);
const Vertex = GraphU32.Vertex;
const VertexMap = std.hash_map.AutoHashMap(*Vertex, void);

pub fn graph_dfs(graph: *const GraphU32, start_vert: *Vertex, res: []*Vertex) !usize {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const alloc = Arena.allocator();

    var visited = VertexMap.init(alloc);

    var index: usize = 0;
    try dfs(graph, &visited, start_vert, res, &index);
    return index;
}

fn dfs(graph: *const GraphU32, visited: *VertexMap, vert: *Vertex, res: []*Vertex, index: *usize) !void {
    res[index.*] = vert;
    try visited.put(vert, {});

    if (graph.adj_list.get(vert)) |list| {
        var it = list.first;
        while (it) |node| : (it = node.next) {
            if (visited.contains(node.data)) {
                continue;
            }
            index.* += 1;
            try dfs(graph, visited, node.data, res, index);
        }
    }
}

pub fn main() void {
    const print = std.debug.print;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var graph = GraphU32.init(allocator);
    defer graph.deinit();

    const vals = [_]u32{ 0, 1, 2, 3, 4, 5, 6 };
    var v = allocator.alloc(GraphU32.Vertex, vals.len) catch unreachable;
    defer allocator.free(v);

    for (vals, 0..) |val, i| {
        v[i].val = val;
        graph.add_vertex(&v[i]);
    }

    graph.add_edge(&v[0], &v[1]);
    graph.add_edge(&v[0], &v[3]);
    graph.add_edge(&v[1], &v[2]);
    graph.add_edge(&v[2], &v[5]);
    graph.add_edge(&v[4], &v[5]);
    graph.add_edge(&v[5], &v[6]);

    print("\n初始化后, 图为:\n", .{});
    graph.print();

    var res = allocator.alloc(*Vertex, graph.size()) catch unreachable;
    defer allocator.free(res);

    var size = graph_dfs(&graph, &v[0], res) catch unreachable;
    print("\n深度优先遍历(DFS)顶点序列为:\n[", .{});
    for (res[0..size], 0..) |item, i| {
        print("{any}{s}", .{ item.val, if (i < size - 1) ", " else "" });
    }
    print("]\n", .{});
}
