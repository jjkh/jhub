# JHUB

WIP program to control the lights on the "Logitech PRO X Gaming Keyboard" without using the Logitech GHUB software.

## Current output

```text
debug: Opening HID library...
debug: Enumerating devices with vid=0x046D and pid=0xC339...
debug: .{ .path = u8@198f1cf66f0, .vendor_id = 1133, .product_id = 49977, .serial_number = c_ushort@198f1cf3fd0, .release_number = 4868, .manufacturer_string = c_ushort@198f1cf0090, .product_string 
= c_ushort@198f1cf3570, .usage_page = 12, .usage = 1, .interface_number = 1, .next = cimport.struct_hid_device_info@198f1cf2b50, .bus_type = 1 }
info:   Manufacturer String: Logitech
info:        Product String: PRO X Gaming Keyboard
info:         Serial Number: 147C30473232
info:       Indexed Strings:
info:                   [1]: Logitech
info:                   [2]: PRO X Gaming Keyboard
info:                   [3]: 147C30473232
info:                   [4]: U113.04_B0019
info:     Report Descriptor:
  0x05 0x0C 0x09 0x01 0xA1 0x01 0x85 0x02 0x09 0xB5 0x09 0xB6 0x09 0xB7 0x09 0xCD 0x09 0xE9 0x09 0xEA 0x09 0xE2 0x15 0x00 0x25 0x01 0x75 0x01 0x95 0x07 0x81 0x02 0x75 0x01 0x95 0x01 0x81 0x03 0xC0  
debug: .{ .path = u8@198f1cf6760, .vendor_id = 1133, .product_id = 49977, .serial_number = c_ushort@198f1cf3e20, .release_number = 4868, .manufacturer_string = c_ushort@198f1cefe50, .product_string 
= c_ushort@198f1cf3870, .usage_page = 65347, .usage = 1538, .interface_number = 1, .next = cimport.struct_hid_device_info@198f1cf27e0, .bus_type = 1 }
info:   Manufacturer String: Logitech
info:        Product String: PRO X Gaming Keyboard
info:         Serial Number: 147C30473232
info:       Indexed Strings:
info:                   [1]: Logitech
info:                   [2]: PRO X Gaming Keyboard
info:                   [3]: 147C30473232
info:                   [4]: U113.04_B0019
info:     Report Descriptor:
  0x06 0x43 0xFF 0x0A 0x02 0x06 0xA1 0x01 0x85 0x11 0x09 0x02 0x15 0x00 0x26 0xFF 0x00 0x75 0x08 0x95 0x13 0x81 0x00 0x09 0x02 0x15 0x00 0x26 0xFF 0x00 0x75 0x08 0x95 0x13 0x91 0x00 0xC0
debug: .{ .path = u8@198f1cf5530, .vendor_id = 1133, .product_id = 49977, .serial_number = c_ushort@198f1cf4390, .release_number = 4868, .manufacturer_string = c_ushort@198f1cefe90, .product_string 
= c_ushort@198f1cf38b0, .usage_page = 65347, .usage = 1540, .interface_number = 1, .next = cimport.struct_hid_device_info@198f1cf29c0, .bus_type = 1 }
info:   Manufacturer String: Logitech
info:        Product String: PRO X Gaming Keyboard
info:         Serial Number: 147C30473232
info:       Indexed Strings:
info:                   [1]: Logitech
info:                   [2]: PRO X Gaming Keyboard
info:                   [3]: 147C30473232
info:                   [4]: U113.04_B0019
info:     Report Descriptor:
  0x06 0x43 0xFF 0x0A 0x04 0x06 0xA1 0x01 0x85 0x12 0x09 0x04 0x15 0x00 0x26 0xFF 0x00 0x75 0x08 0x95 0x3F 0x81 0x00 0x09 0x04 0x15 0x00 0x26 0xFF 0x00 0x75 0x08 0x95 0x3F 0x91 0x00 0xC0
debug: .{ .path = u8@198f1cf5610, .vendor_id = 1133, .product_id = 49977, .serial_number = c_ushort@198f1cf3d00, .release_number = 4868, .manufacturer_string = c_ushort@198f1cefeb0, .product_string 
= c_ushort@198f1cf3a30, .usage_page = 1, .usage = 6, .interface_number = 1, .next = cimport.struct_hid_device_info@198f1cf2b00, .bus_type = 1 }
info:   Manufacturer String: Logitech
info:        Product String: PRO X Gaming Keyboard
info:         Serial Number: 147C30473232
info:       Indexed Strings:
info:                   [1]: Logitech
info:                   [2]: PRO X Gaming Keyboard
info:                   [3]: 147C30473232
info:                   [4]: U113.04_B0019
info:                   [4]: U113.04_B0019
info:     Report Descriptor:
  0x05 0x01 0x09 0x06 0xA1 0x01 0x85 0x01 0x05 0x07 0x19 0x00 0x29 0xE7 0x15 0x00 0x26 0xE7 0x00 0x75 0x08 0x95 0x14 0x81 0x00 0xC0
debug: .{ .path = u8@198f1cf7ca0, .vendor_id = 1133, .product_id = 49977, .serial_number = c_ushort@198f1cf3e80, .release_number = 4868, .manufacturer_string = c_ushort@198f1cefed0, .product_string 
= c_ushort@198f1cf3830, .usage_page = 1, .usage = 6, .interface_number = 0, .next = cimport.struct_hid_device_info@0, .bus_type = 1 }
info:   Manufacturer String: Logitech
info:        Product String: PRO X Gaming Keyboard
info:         Serial Number: 147C30473232
info:       Indexed Strings:
info:                   [1]: Logitech
info:                   [2]: PRO X Gaming Keyboard
info:                   [3]: 147C30473232
info:                   [4]: U113.04_B0019
info:     Report Descriptor:
  0x05 0x01 0x09 0x06 0xA1 0x01 0x05 0x07 0x19 0xE0 0x29 0xE7 0x15 0x00 0x25 0x01 0x75 0x01 0x95 0x08 0x81 0x02 0x75 0x08 0x95 0x01 0x81 0x03 0x19 0x00 0x29 0xFF 0x15 0x00 0x26 0xFF 0x00 0x75 0x08 0x95 0x06 0x81 0x00 0x05 0x08 0x19 0x01 0x29 0x03 0x15 0x00 0x25 0x01 0x75 0x01 0x95 0x03 0x91 0x02 
0x75 0x05 0x95 0x01 0x91 0x03 0xC0
```