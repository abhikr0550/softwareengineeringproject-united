/// This module manages a chat server that facilitates communication among multiple clients.
/// It utilizes sockets to establish connections, receive and transmit messages between clients, and manage client interactions within the chat environment.
module chatserver;

import std.socket;
import std.stdio;
import std.array;
import std.algorithm;
import std.conv;
import core.thread;
import core.sync.mutex;

/** 
 * The client info object holds all the user info required to facilitate chat
 */
struct ClientInfo
{
	Socket socket;	/// The socket used for communication with the client.
	int id;	 /// The unique ID for the client.
	string username;   /// The username of the client.
}

/** 
 * Chat server handles all the new clients in the chat and provides the functionality of group chat in all rooms
 */
class ChatServer
{
	Socket listener;	/// The server socket that listens for incoming connections.
	SocketSet readSet;	/// Set of sockets for reading data.
	ClientInfo[int] ClientMap; /// Associative array to store clients with their IDs
	int nextClientId; /// Next available client ID

	/** 
	 * Constructor to initialize the chat server, binds to the specified address and port, 
	 * and prepares for client connections.
	 */
	this()
	{
		writeln("Starting server...");

		listener = new Socket(AddressFamily.INET, SocketType.STREAM);
		listener.bind(new InternetAddress(getIP(), 50001));
		listener.listen(4);

		readSet = new SocketSet();
		nextClientId = 1;
	}

	/** 
	 * Get the IP address that the server is running on.
	 * Returns:
	 * 		The IP address.
	 */
	string getIP()
	{
		string ip = "";

		// A bit of a hack, but we'll create a connection from google to
		// our current ip.
		// Use a well known port (i.e. google) to do this
		auto r = getAddress("8.8.8.8", 53); // NOTE: This is effetively getAddressInfo

		// Create a socket
		auto sockfd = new Socket(AddressFamily.INET, SocketType.STREAM);
		// Connect to the google server
		import std.conv;

		const char[] address = r[0].toAddrString().dup;
		ushort port = to!ushort(r[0].toPortString());
		sockfd.connect(new InternetAddress(address, port));
		// Obtain local sockets name and address
		ip = sockfd.localAddress.toAddrString();

		// Close our socket
		sockfd.close();
		writeln(ip);
		return ip;
	}

	/** 
	 * Initiates the chat server, awaiting client connections and message handling in separate threads.
	 * Returns:
	 * 		None
	 */
	void start()
	{
		char[1024] buffer;

		writeln("Awaiting client connections");
		bool serverIsRunning = true;

		auto receiveThread = new Thread({
			while (serverIsRunning)
			{
				readSet.reset();
				readSet.add(listener);

				foreach (clientId; ClientMap.keys)
				{
					readSet.add(ClientMap[clientId].socket);
				}

				if (Socket.select(readSet, null, null))
				{
					foreach (clientId; ClientMap.keys)
					{
						if (readSet.isSet(ClientMap[clientId].socket))
						{
							handleIncomingMessage(clientId, buffer);
						}
					}

					if (readSet.isSet(listener))
					{
						try
						{
							auto newSocket = listener.accept();
							handleNewClient(newSocket);
						}
						catch (SocketAcceptException e)
						{
							writeln("Error accepting new connection: ", e.msg);
						}
					}
				}
			}
		});
		receiveThread.start();
	}

	/** 
	 * Handles new clients joining the chat.
	 * Params:
	 *		newSocket = The new socket that creates the new client.
	 * Returns:
	 * 		None
	 */
	void handleNewClient(Socket newSocket)
	{
		char[1024] usernameBuffer;

		auto receivedUsername = newSocket.receive(usernameBuffer);
		auto username = usernameBuffer[0 .. receivedUsername].idup;

		newSocket.send("Welcome, " ~ username ~ "! You are now in the GC");

		int clientId = nextClientId++;
		ClientMap[clientId] = ClientInfo(newSocket, clientId, username);

		writeln("> client", clientId, " added to connectedClientsList with username '", username, "'");
		broadcastMessage(username ~ " joined the chat.", clientId, false);
	}

	/** 
	 * Helper to broadcast the message to all players except themselves.
	 * Params:
	 *   	message = Message sent
	 *   	senderId = Sender id
	 *   	userMessage = true if user generated, false if server info message
	 * Returns:
	 * 		None
	 */
	void broadcastMessage(string message, int senderId, bool userMessage)
	{
		// Add the sender's name when sending a message if it's not a server notification
		if (userMessage)
		{
			string senderUsername = ClientMap[senderId].username;
			message = senderUsername ~ ": " ~ message;
		}
		foreach (clientId, clientInfo; ClientMap)
		{
			if (clientId != senderId)
			{
				clientInfo.socket.send(message);
			}
		}
	}

	/** 
	 * Handles disconnection.
	 * Params:
	 *   	clientId = The clientId of the player disconnected.
	 * Returns:
	 * 		None
	 */
	void handleDisconnection(int clientId)
	{
		auto clientInfo = ClientMap[clientId];
		string username = clientInfo.username;
		clientInfo.socket.close();
		ClientMap.remove(clientId);
		writeln(username ~ " disconnected.");
		broadcastMessage(username ~ " disconnected.", clientId, false);
	}

	/** 
	 * Handles incoming message from a player and broadcasts to all the players.
	 * Params:
	 *   	clientId = Sender of the message
	 *   	buffer = buffer where the message is stored.
	 * Returns:
	 * 		None
	 */
	void handleIncomingMessage(int clientId, char[1024] buffer)
	{
		auto clientInfo = ClientMap[clientId];
		string username = clientInfo.username;
		auto got = clientInfo.socket.receive(buffer);

		if (got > 0)
		{
			writeln(username, ": ", buffer[0 .. got]);
			broadcastMessage(buffer[0 .. got].to!string, clientId, true);
		}
		else
		{
			handleDisconnection(clientId);
		}
	}
}
