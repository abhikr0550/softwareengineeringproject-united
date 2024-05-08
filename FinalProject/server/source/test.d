module test;

@("Test server basic networking")
unittest {
    import std.socket;
    import std.stdio;
    import std.conv;
    import core.thread;
    import chatserver;
    ChatServer server = new ChatServer();
    server.start();

    // Mock a client connection
    auto clientSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
    clientSocket.connect(new InternetAddress(server.getIP(), 50001));
    clientSocket.send("MockClient");

    // Wait for the server to accept the connection
    Thread.sleep(1.seconds);

    // Check if the server has added the client
    assert(server.ClientMap.length == 1, "Server did not add the client");
    
    // Check if the server has assigned the correct username to the client
    assert(server.ClientMap[1].username == "MockClient", "Server did not assign the correct username to the client");
    
    // Close the connection
    clientSocket.close();
    server.listener.close();
}