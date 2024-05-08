module test;

import std.stdio;
import std.string;
import std.conv;

import std.concurrency : spawn;

import core.thread;

// Load the SDL2 library
import bindbc.sdl;

import glib.Idle;
import gameclient;
import chatwindow : ChatWindow;
import chatclient;

// Test case 1
@("Test client networking")
unittest {
    import std.socket;
    import std.stdio;
    import std.conv;
    import core.thread;

    // Mock a server
    auto serverSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
    serverSocket.bind(new InternetAddress("localhost", 50001));
    serverSocket.listen(1);

    // Start the client and connect to the mock server
    auto client = new ChatClient("MockUser", (string message) { writeln(message); }, "localhost");
    client.start();

    // Accept the client connection in the mock server
    auto clientSocket = serverSocket.accept();

    // Wait for the client to send the username
    char[1024] buffer;
    auto receivedUsername = clientSocket.receive(buffer);
    auto username = buffer[0 .. receivedUsername].idup;

    // Check if the client has sent the correct username
    assert(username == "MockUser", "Client did not send the correct username");

    // Close the connections
    clientSocket.close();
    serverSocket.close();
    client.stop();
}