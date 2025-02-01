const std = @import("std");

pub const Packet = struct {
    packet_length:u32,
    padding_length:u8,
    payload:[]const u8,
    random_padding:[]const u8,
    mac:[]const u8,

    pub fn print(self: Packet) void {
        std.debug.print(\\Pack len: {d}
                        \\Pad_len: {d} 
                        \\Payload: {s} 
                        \\Rand padd: {s} 
                        \\Mac: {s} 
                        , .{self.packet_length,self.padding_length,self.payload,self.random_padding,self.mac});
    }

    pub fn writePacket(self:Packet,buffer:[]u8) usize {
        var offset: usize = 0;

        //TODO fix this
        const len=self.packet_length;
        buffer[0] = @intCast( len >> 24);
        buffer[1] = @intCast(len >> 16);
        buffer[2] = @intCast(len >> 8);
        buffer[3] = @intCast(len);
        offset+=4;

        buffer[offset] = self.padding_length;
        offset += 1;
        
        @memcpy(buffer[offset .. offset + self.payload.len], self.payload);
        offset += self.payload.len;

        // Write random_padding
        @memcpy(buffer[offset .. offset + self.random_padding.len], self.random_padding);
        offset += self.random_padding.len;

        // Write MAC
        @memcpy(buffer[offset .. offset + self.mac.len], self.mac);
        offset += self.mac.len;

        return offset;
    }
};
pub const MAC_LEN=4;

pub fn readPacket(data:[]u8) Packet {
    const pack_len:u32=std.mem.readInt(u32, data[0..4], .big);
    const padd_len:u32=data[4];

    const packet = Packet{ 
        .packet_length = pack_len, 
        .padding_length = data[4],
        .payload = data[5..5+pack_len+4-padd_len],
        .random_padding = data[5+pack_len+4-padd_len..5+pack_len+4],
        .mac = data[5+pack_len+4..5+pack_len+4+MAC_LEN]
    };
    return packet;
}

