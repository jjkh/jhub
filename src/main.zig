const std = @import("std");
const c = @cImport(@cInclude("hidapi.h"));
const args = @import("args");

const options = @import("options");
pub const std_options: std.Options = .{
    .log_level = if (options.log_level) |ll|
        @enumFromInt(ll)
    else
        std.log.default_level,
};

const HidDevice = c.hid_device_;
const HidDeviceInfo = c.hid_device_info;

const HidBusType = enum(c_uint) {
    unknown = c.HID_API_BUS_UNKNOWN,
    usb = c.HID_API_BUS_USB,
    bluetooth = c.HID_API_BUS_BLUETOOTH,
    i2c = c.HID_API_BUS_I2C,
    spi = c.HID_API_BUS_SPI,
    virtual = c.HID_API_BUS_VIRTUAL,
    _,
};

const GPRO_VENDOR_ID = 0x046D;
const GPRO_PRODUCT_ID = 0xC339;

pub fn main() !void {
    defer std.process.cleanExit();

    // get an "auto" allocator
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa, const is_debug = gpa: {
        const builtin = @import("builtin");
        if (builtin.os.tag == .wasi) break :gpa .{ std.heap.wasm_allocator, false };
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
            .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
        };
    };
    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    // parse some args
    const parsed_opts = args.parseForCurrentProcess(struct {
        list: bool = false,
        @"no-open-device": bool = false,
        @"dump-descriptors": bool = false,
        @"log-level": std.log.Level = std.log.default_level,

        pub const shorthands = .{
            .l = "list",
            .n = "no-open-device",
            .d = "dump-descriptors",
        };
    }, gpa, .print) catch return error.InvalidArgs;
    defer parsed_opts.deinit();
    const opts = parsed_opts.options;

    std.log.debug("Opening HID library...", .{});
    try handleResult(c.hid_init(), null);
    defer logResult(c.hid_exit(), null);

    const first_dev_info = blk: {
        if (opts.list) {
            std.log.info("Enumerating ALL HID devices...", .{});
            break :blk c.hid_enumerate(0, 0) orelse return handleResult(-1, null);
        } else {
            std.log.info("Enumerating devices with vid=0x{X:0>4} and pid=0x{X:0>4}...", .{ GPRO_VENDOR_ID, GPRO_PRODUCT_ID });
            break :blk c.hid_enumerate(GPRO_VENDOR_ID, GPRO_PRODUCT_ID) orelse return handleResult(-1, null);
        }
    };
    defer c.hid_free_enumeration(first_dev_info);

    var next_dev_info: ?*HidDeviceInfo = @ptrCast(first_dev_info);
    while (next_dev_info) |dev_info| : (next_dev_info = dev_info.next) {
        logDeviceInfo(dev_info);

        if (opts.@"no-open-device") continue;
        const dev = c.hid_open_path(dev_info.path) orelse {
            logResult(-1, null);
            continue;
        };
        defer c.hid_close(dev);

        if (!opts.@"dump-descriptors") continue;
        try dumpDeviceData(dev);
    }
}

fn logDeviceInfo(dev_info: *const HidDeviceInfo) void {
    std.log.info("VID=0x{X:0>4}&PID=0x{X:0>4} ({s})", .{ dev_info.vendor_id, dev_info.product_id, dev_info.path.? });
    std.log.info("    Serial Number: {f}", .{fmtApiString(dev_info.serial_number)});
    // std.log.info("    Serial Number: {f}", .{fmtApiString(dev_info.serial_number)});
    std.log.info("    Manufacturer String: {f}", .{fmtApiString(dev_info.manufacturer_string)});
    std.log.info("    Product String: {f}", .{fmtApiString(dev_info.product_string)});
    std.log.info("    Usage Page: {d}, Usage: {d}", .{ dev_info.usage_page, dev_info.usage });
    std.log.info("    Bus Type: {}", .{@as(HidBusType, @enumFromInt(dev_info.bus_type))});
    std.log.debug("   Release Number: {d}", .{dev_info.release_number});
    std.log.debug("   Interface Number: {d}", .{dev_info.interface_number});
}

fn dumpDeviceData(dev: *HidDevice) !void {
    {
        var manu_str: [255:0]c.wchar_t = undefined;
        try handleResult(c.hid_get_manufacturer_string(dev, &manu_str, manu_str.len), dev);
        std.log.info("  Manufacturer String: {f}", .{fmtApiString(&manu_str)});
    }
    {
        var prod_str: [255:0]c.wchar_t = undefined;
        try handleResult(c.hid_get_product_string(dev, &prod_str, prod_str.len), dev);
        std.log.info("       Product String: {f}", .{fmtApiString(&prod_str)});
    }
    {
        var prod_str: [255:0]c.wchar_t = undefined;
        try handleResult(c.hid_get_serial_number_string(dev, &prod_str, prod_str.len), dev);
        std.log.info("        Serial Number: {f}", .{fmtApiString(&prod_str)});
    }
    {
        std.log.info("      Indexed Strings:", .{});
        var indexed_str: [255:0]c.wchar_t = undefined;
        for (1..10) |i| {
            if (c.hid_get_indexed_string(dev, @intCast(i), &indexed_str, indexed_str.len) != 0)
                break;
            std.log.info("                  [{d}]: {f}", .{ i, fmtApiString(&indexed_str) });
        }
    }
    {
        std.log.info("    Report Descriptor:", .{});
        var report_desc_buf: [c.HID_API_MAX_REPORT_DESCRIPTOR_SIZE]u8 = undefined;
        const bytes_copied = c.hid_get_report_descriptor(dev, &report_desc_buf, report_desc_buf.len);
        if (bytes_copied < 0)
            return handleResult(-1, dev);

        std.debug.print("  ", .{});
        for (report_desc_buf[0..@intCast(bytes_copied)]) |byte|
            std.debug.print("0x{X:0>2} ", .{byte});
        std.debug.print("\n", .{});
    }
}

fn logResult(rc: c_int, dev: ?*HidDevice) void {
    if (rc != 0)
        std.log.warn("HID API error: {f}", .{fmtApiString(c.hid_error(dev))});
}

fn handleResult(rc: c_int, dev: ?*HidDevice) !void {
    if (rc != 0) {
        logResult(rc, dev);
        return error.HidApiFailed;
    }
}

pub fn fmtApiString(api_str: [*:0]const c.wchar_t) std.fmt.Alt([]const c.wchar_t, formatWideString) {
    return .{ .data = std.mem.span(api_str) };
}
fn formatWideString(wide_str: []const c.wchar_t, writer: *std.io.Writer) std.io.Writer.Error!void {
    const unicode = std.unicode;

    if (wide_str.len == 0) {
        try writer.writeAll("<empty>");
        return;
    }

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
