/// Defines a packet structure used in client-server communication.
module packet;

import core.stdc.string;

/** 
 * This struct represents the packet that is used to communicate between client and server, to facilitate multiple player movement and interactions.
 */
struct Packet
{
    char[16] username; /// A unique identifier for the user associated with the packet.
    int x; /// X-coordinate for player position.
    int y; /// Y-coordinate for player position.
    char[16] action; /// Action associated with the packet, such as movement type or interaction.
    char[16] bmp; /// Bitmap data associated with the packet.
    char[16] status; /// Status information related to the packet.
    bool isMusicChange; /// Helps player know if there is a music related change.
    int roomNumber; /// the roomNumber where the music changed.
    int trackNum; /// the trackNum that changed.
    int pauseOrPlayOrResume; /// The change, whether it's play or plause or Resume, values 1,2,3.
    
    /** 
     * This function returns the Packet as bytes.
     * Returns: 
     *      Packet as Bytes
     */
    char[Packet.sizeof] GetPacketAsBytes()
    {
        char[Packet.sizeof] payload;
        memmove(&payload, &username, username.sizeof);
        memmove(&payload[16], &x, x.sizeof);
        memmove(&payload[20], &y, y.sizeof);
        memmove(&payload[24], &action, action.sizeof);
        memmove(&payload[40], &bmp, bmp.sizeof);
        memmove(&payload[56], &status, status.sizeof);
        memmove(&payload[72], &isMusicChange, isMusicChange.sizeof);
        memmove(&payload[73], &roomNumber, roomNumber.sizeof);
        memmove(&payload[77], &trackNum, trackNum.sizeof);
        memmove(&payload[81], &pauseOrPlayOrResume, pauseOrPlayOrResume.sizeof);
        return payload;
    }

    /** 
    * This function converts the byte arr consisiting of packet data and assigns to the packet fields.
    * Params: 
    *      bytes = Bytes containing packet information.
    * Returns:
    *      None
    */
    void FromBytes(byte[Packet.sizeof] bytes)
    {
        byte[16] field0 = bytes[0 .. 16].dup;
        username = cast(char[])(field0);
        byte[4] field1 = bytes[16 .. 20].dup;
        byte[4] field2 = bytes[20 .. 24].dup;
        x = *cast(int*)&field1;
        y = *cast(int*)&field2;
        byte[16] field3 = bytes[24 .. 40].dup;
        action = cast(char[])(field3);
        byte[16] field4 = bytes[40 .. 56].dup;
        bmp = cast(char[])(field4);
        byte[16] field5 = bytes[56 .. 72].dup;
        status = cast(char[])(field5);
        byte[1] field6 = bytes[72 .. 73].dup;
        isMusicChange = *cast(bool*)&field6;
        byte[4] field7 = bytes[73 .. 77].dup;
        roomNumber = *cast(int*)&field7;
        byte[4] field8 = bytes[77 .. 81].dup;
        trackNum = *cast(int*)&field8;
        byte[4] field9 = bytes[81 .. 85].dup;
        pauseOrPlayOrResume = *cast(int*)&field9;
    }
}
