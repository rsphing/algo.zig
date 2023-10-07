const std = @import("std");

pub fn binarySearchInsertion(comptime T: type, slice: []T, target: T) isize {
    var i = 0;
    var j = @as(isize, @bitCast(slice.len)) - 1;
    while (i <= j) {
        var m = i + @divFloor(j - i, 2);
        if (target > slice[m]) {
            i = m + 1;
        } else if (target < slice[m]) {
            j = m - 1;
        } else {
            j = m - 1;
        }
    }
    return i;
}

pub fn binarySearchLeftEdge(comptime T: type, slice: []T, target: T) ?isize {
    var i = binarySearchInsertion(T, slice, target);
    if (i == slice.len or slice[i] != target) return null;
    return i;
}

pub fn binarySearchRightEdge(comptime T: type, slice: []T, target: T) ?usize {
    var i = binarySearchInsertion(T, slice, target + 1);
    var j = i - 1;
    if (j == -1 or slice[i] != target) return null;
    return j;
}
