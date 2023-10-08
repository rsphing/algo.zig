const std = @import("std");

pub fn insertionSort(comptime T: type, slice: []T) void {
    for (1..slice.len) |i| {
        var base = slice[i];
        var j = i;
        while (j >= 1 and slice[j - 1] > base) : (j -= 1) {
            slice[j] = slice[j - 1];
        }
        slice[j] = base;
    }
}

fn partition(comptime T: type, slice: []T, left: usize, right: usize) usize {
    var med = blk: {
        var mid = @divFloor(left + right, 2);
        if ((slice[left] < slice[mid]) != (slice[left] < slice[right])) {
            break :blk left;
        } else if ((slice[mid] < slice[left]) != (slice[mid] < slice[right])) {
            break :blk mid;
        }
        break :blk right;
    };
    std.mem.swap(T, &slice[left], &slice[med]);

    var i = left;
    var j = right;

    while (i < j) {
        while (i < j and slice[j] >= slice[left]) j -= 1;
        while (i < j and slice[i] <= slice[left]) i += 1;
        std.mem.swap(T, &slice[i], &slice[j]);
    }
    std.mem.swap(T, &slice[i], &slice[left]);
    return i;
}

pub fn quickSort(comptime T: type, slice: []T) void {
    if (slice.len == 0) return;

    var left: usize = 0;
    var right = slice.len - 1;

    while (left < right) {
        var pivot = partition(T, slice, left, right);
        if (pivot - left < right - pivot) {
            quickSort(T, slice[left..pivot]);
            left = pivot + 1;
        } else {
            quickSort(T, slice[pivot + 1 .. right + 1]);
            right = pivot - 1;
        }
    }
}

pub fn mergeSort(comptime T: type, slice: []T) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try mergePart(T, allocator, slice);
}

fn mergePart(comptime T: type, gpa: std.mem.Allocator, slice: []T) !void {
    if (slice.len <= 1) return;

    var mid = @divFloor(slice.len, 2);
    try mergePart(T, gpa, slice[0..mid]);
    try mergePart(T, gpa, slice[mid..]);

    try merge(T, gpa, slice, mid);
}

fn merge(comptime T: type, gpa: std.mem.Allocator, slice: []T, mid: usize) !void {
    var tmp = try gpa.alloc(T, slice.len);
    defer gpa.free(tmp);

    @memcpy(tmp, slice);

    var i: usize = 0;
    var j = mid;
    var k: usize = 0;
    while (k < slice.len) : (k += 1) {
        if (i > mid - 1) {
            slice[k] = tmp[j];
            j += 1;
        } else if (j >= slice.len or tmp[i] <= tmp[j]) {
            slice[k] = tmp[i];
            i += 1;
        } else {
            slice[k] = tmp[j];
            j += 1;
        }
    }
}

pub fn ListMergeSort(comptime T: type) type {
    return struct {
        const L = std.SinglyLinkedList(T);

        fn innerMerge(_a: ?*L.Node, _b: ?*L.Node) ?*L.Node {
            var head = L.Node{ .data = 0 };
            var c: ?*L.Node = &head;
            var a = _a;
            var b = _b;
            while (a != null and b != null) {
                if (a.?.data < b.?.data) {
                    c.?.next = a;
                    c = a;
                    a = a.?.next;
                } else {
                    c.?.next = b;
                    c = b;
                    b = b.?.next;
                }
            }
            c.?.next = if (a == null) b else a;
            return head.next;
        }

        pub fn sort(list: *std.SinglyLinkedList(T)) void {
            list.first = innerSort(list.first);
        }

        fn innerSort(first: ?*L.Node) ?*L.Node {
            if (first == null or first.?.next == null) return first;

            var c = first;
            var a = c;
            var b = c.?.next;
            while (b != null and b.?.next != null) {
                c = c.?.next;
                b = b.?.next.?.next;
            }
            b = c.?.next;
            c.?.next = null;

            return innerMerge(innerSort(a), innerSort(b));
        }
    };
}

pub fn countingSort(slice: []u32) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var max: usize = 0;
    for (slice) |el| {
        if (el > max) max = @intCast(el);
    }

    var counter = try allocator.alloc(usize, max + 1);
    defer allocator.free(counter);
    @memset(counter, 0);

    for (slice) |el| {
        counter[@intCast(el)] += 1;
    }

    for (0..max) |i| {
        counter[i + 1] += counter[i];
    }

    var tmp = try allocator.dupe(u32, slice);
    defer allocator.free(tmp);

    var pos = tmp.len;
    while (pos > 0) : (pos -= 1) {
        var num = tmp[pos - 1];
        counter[num] -= 1;
        slice[counter[num]] = num;
    }
}

inline fn digit(el: u32, exp: u32) usize {
    return @intCast(@rem(@divFloor(el, exp), 10));
}

fn countingSortDigit(gpa: std.mem.Allocator, slice: []u32, exp: u32) !void {
    var counter = [_]u32{0} ** 10;
    for (slice) |el| {
        counter[digit(el, exp)] += 1;
    }

    for (1..10) |i| {
        counter[i] += counter[i - 1];
    }

    var tmp = try gpa.dupe(u32, slice);
    defer gpa.free(tmp);

    var pos = tmp.len;
    while (pos > 0) : (pos -= 1) {
        var num = tmp[pos - 1];
        var d = digit(num, exp);
        counter[d] -= 1;
        slice[counter[d]] = num;
    }
}

pub fn radixSort(slice: []u32) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var max: usize = 0;
    for (slice) |el| {
        if (el > max) max = @intCast(el);
    }

    var exp: u32 = 1;
    while (exp <= max) : (exp *= 10) {
        try countingSortDigit(allocator, slice, exp);
    }
}

pub fn main() !void {
    const printSlice = @import("print_util.zig").printSlice;

    var arr = [_]u32{ 9, 2, 4, 1, 12, 0, 3, 14, 5, 8, 6, 7, 10, 15, 13, 11 };
    quickSort(u32, &arr);
    printSlice(u32, &arr);

    var arr2 = [_]u32{ 9, 2, 4, 1, 12, 0, 3, 14, 5, 8, 6, 7, 10, 15, 13, 11 };
    insertionSort(u32, &arr2);
    printSlice(u32, &arr2);

    var arr3 = [_]u32{ 9, 2, 4, 1, 12, 0, 3, 14, 5, 8, 6, 7, 10, 15, 13, 11 };
    mergeSort(u32, &arr3) catch unreachable;
    printSlice(u32, &arr3);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const Link = std.SinglyLinkedList(u32);
    var link = Link{};

    var arr4 = [_]u32{ 9, 2, 4, 1, 12, 0, 3, 14, 5, 8, 6, 7, 10, 15, 13, 11 };
    for (arr4) |val| {
        var node = try allocator.create(Link.Node);
        node.* = .{ .data = val };
        link.prepend(node);
    }

    ListMergeSort(u32).sort(&link);

    var it = link.first;
    while (it) |ptr| : (it = it.?.next) {
        std.debug.print("{d}{s}", .{ ptr.data, if (ptr.next != null) ", " else "\n" });
    }

    var arr5 = [_]u32{ 1, 0, 1, 2, 0, 4, 0, 2, 2, 4 };
    try countingSort(&arr5);
    printSlice(u32, &arr5);

    var arr6 = [_]u32{ 10546151, 35663510, 42865989, 34862445, 81883077, 88906420, 72429244, 30524779, 82060337, 63832996 };
    try radixSort(&arr6);
    printSlice(u32, &arr6);
}
