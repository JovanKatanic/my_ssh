const Packet = struct {
    packet_length:u32,
    padding_length:u8,
    payload:[]u8,
    random_padding:[]u8,
    mac:[]u8,
};
const MAC_LEN=4;

pub fn readPacket(data:[]u8) Packet {
    const pack_len:u32=data[0..4];
    const padd_len:u32=data[5];
    const packet = Packet{ 
        .packet_length = pack_len, 
        .padding_length = data[4],
        .payload = data[5..pack_len+4],
        .random_padding = data[pack_len+4+1..pack_len+4+1+padd_len],
        .mac = data[pack_len+4+1+padd_len+1..]
    };
    return packet;
}