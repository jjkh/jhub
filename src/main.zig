const std = @import("std");
const c = @cImport(@cInclude("hidapi.h"));

const HidDevice = c.hid_device_;

pub fn main() !void {
    std.log.info("Opening HID library...", .{});
    try handleResult(c.hid_init(), null);
    defer handleResult(c.hid_exit(), null) catch {};

    std.log.info("Job done!", .{});
}

fn handleResult(rc: c_int, dev: ?*HidDevice) !void {
    if (rc != 0) {
        std.log.warn("{f}", .{fmtApiString(c.hid_error(dev))});
        return error.HidApiFailed;
    }
}

pub fn fmtApiString(api_str: [*:0]const c.wchar_t) std.fmt.Alt([]const c.wchar_t, formatWideString) {
    return .{ .data = std.mem.span(api_str) };
}
fn formatWideString(wide_str: []const c.wchar_t, writer: *std.io.Writer) std.io.Writer.Error!void {
    const unicode = std.unicode;

    const writeCodepoint = struct {
        fn write(codepoint: u21, buffer: []u8, len: *usize, w: *std.io.Writer) !void {
            len.* += unicode.utf8Encode(codepoint, buffer[len.*..]) catch
                unicode.utf8Encode(unicode.replacement_character, buffer[len.*..]) catch unreachable;
            // make sure there's always enough room for another maximum length UTF-8 codepoint
            if (len.* + 4 > buffer.len) {
                try w.writeAll(buffer[0..len.*]);
                len.* = 0;
            }
        }
    }.write;

    var buf: [300]u8 = undefined; // just an arbitrary size
    var u8len: usize = 0;
    if (c.wchar_t == u16) {
        var it = unicode.Utf16LeIterator.init(wide_str);
        while (it.nextCodepoint() catch unicode.replacement_character) |codepoint| {
            try writeCodepoint(codepoint, &buf, &u8len, writer);
        }
    } else {
        for (wide_str) |val| {
            try writeCodepoint(@intCast(val), &buf, &u8len, writer);
        }
    }
    try writer.writeAll(buf[0..u8len]);
}
