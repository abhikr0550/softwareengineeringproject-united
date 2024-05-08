/// This module manages a chat client that handles message communication from a server.
/// It interacts with the server through sockets, sending and receiving messages, and enables users to join chat sessions.
module chatclient;

import std.socket;
import std.stdio;
import std.array;
import std.algorithm;
import std.conv;
import core.thread;
import core.sync.mutex;

/** 
 * Chat client that handles message communication from server.
 */
class ChatClient
{
    Socket socket; /// The socket used for communication with the server.
    string username; /// The username associated with the chat client.
    void delegate(string) onMessageReceived; /// Delegate function to handle received messages.
    Mutex mutex; /// Mutex for managing thread safety.

    /** 
     * Constructor to initialize the chat client with the provided username and message handling delegate.
     * Params:
     *      username = The username for the chat client.
     *      onMessageReceived = Delegate function to process received messages.
     *      serverIp = Ip address that runs the server.
     */
    this(string username, void delegate(string) onMessageReceived, string serverIp)
    {
        this.username = username;
        this.onMessageReceived = onMessageReceived;
        socket = new Socket(AddressFamily.INET, SocketType.STREAM);
        socket.connect(new InternetAddress(serverIp, 50001));
        socket.send(username);
        mutex = new Mutex();
    }

    /** 
     * Function to boot up the client.
     * Returns:
     *      None
     */
    void start()
    {
        char[1024] buffer;

        // Spawn a thread for receiving messages
        auto receiveThread = new Thread({
            while (true)
            {
                auto got = socket.receive(buffer);
                if (got > 0)
                {
                    mutex.lock();
                    onMessageReceived(buffer[0 .. got].idup);
                    mutex.unlock();
                }
                else
                {
                    writeln("Disconnected from server.");
                    break;
                }
            }
        });
        receiveThread.start();
    }

    /** 
     * Helper to send message to the server.
     * Params:
     *      message = message to be sent
     * Returns:
     *      None
     */
    void sendMessage(string message)
    {
        socket.send(message);
    }

    /** 
     * Helper to close the socket connection.
     * Returns:
     *      None
     */
    void stop()
    {
        socket.close();
    }
}
