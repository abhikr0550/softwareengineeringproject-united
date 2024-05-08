/// This module orchestrates multiplayer interactions, managing client connections 
/// and data transmission for synchronized gameplay among multiple players.
module gameserver;

import std.socket;
import std.stdio;
import std.conv;
import std.exception;
import core.thread;
import core.sync.mutex;

import packet : Packet;

/** 
 * The client info object holds all the player info required to facilitate networking.
 */
struct ClientInfo
{
	Socket socket;	/// Socket associated with the client.
	string username;	/// Username of the client.
	string bmpFile;	/// File name of the client's sprite image.
	int x;	/// X-coordinate of the player.
	int y;	/// Y-coordinate of the player.
}

/** 
 * Game server handles all the new clients in the game and enables data transfer to facilitate the gameplay of multiple players together.
 */
class GameServer
{
	Socket listener;	/// Socket listening for new connections.
	SocketSet readSet;	/// Set of sockets for reading incoming data.
	ClientInfo[string] connectedClientsList;	/// List of connected clients with associated information.
	string[] bmpFiles = [
		"Arc-Gre.bmp",
		"Arc-Pur.bmp",
		"Mag-Cya.bmp",
		"Mag-Red.bmp",
		"Sol-Blu.bmp",
		"Sol-Red.bmp",
		"Sol-Yel.bmp",
		"War-Blu.bmp",
		"War-Red.bmp"
	]; /// Array of sprite image filenames.

	/** 
	 * Constructor to initialize the game server.
	 */
	this()
	{
		writeln("Starting server...");
		writeln("Server must be started before clients may join");
		listener = new Socket(AddressFamily.INET, SocketType.STREAM);
		listener.bind(new InternetAddress(getIP(), 50002));
		listener.listen(4);
		readSet = new SocketSet();
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
		write("All clients must use this IP to connect to the server: ");
		writeln(ip);
		return ip;
	}
	/** 
	 * This function boots up the game server.
	 * Returns:
	 * 		None
	 */
	void start()
	{
		bool serverIsRunning = true;
		writeln("Awaiting client connections");
		auto receiveThread = new Thread({
			while (serverIsRunning)
			{
				readSet.reset();
				readSet.add(listener);
				foreach (client; connectedClientsList.values)
				{
					readSet.add(client.socket);
				}
				if (Socket.select(readSet, null, null))
				{
					foreach (username, client; connectedClientsList)
					{
						if (readSet.isSet(client.socket))
						{
							handleIncomingDataFromClient(username);
						}
					}
					if (readSet.isSet(listener))
					{
						handleNewClient();
					}
				}
			}
		});
		receiveThread.start();
	}

	/** 
	 * Handles new clients joining the game, it also broadcasts existing players info to new player and vice-versa.
	 * Returns:
	 * 		None
	 */
	void handleNewClient()
	{
		char[1024] usernameBuffer;
		usernameBuffer[] = 0;
		auto newSocket = listener.accept();
		auto received = newSocket.receive(usernameBuffer);
		string username = usernameBuffer[0 .. received].idup;
		connectedClientsList[username] = ClientInfo(newSocket, username, bmpFiles[$ - connectedClientsList.length - 1], 14, 14);
		writeln("> client ", username, " added to connectedClientsList");
		newSocket.send(connectedClientsList[username].bmpFile);

		broadcastExistingPlayersDetails(username);

		Packet p;
		char[16] usernameBytes = getCharArrFromString(username);
		p.username = usernameBytes;
		p.status = "online\0";
		p.bmp = getCharArrFromString(connectedClientsList[username].bmpFile);
		p.action = "TurnDown\0";
		p.x = 14;
		p.y = 14;
		broadcastData(p.GetPacketAsBytes(), username);
	}

	/** 
	 * Helper to broadcast all players info to new player at once.
	 * Params:
	 *   	username = The new player's username to whom all players info will be broadcasted
	 * Returns:
	 * 		None
	 */
	void broadcastExistingPlayersDetails(string username)
	{
		auto clientInfo = connectedClientsList[username];
		foreach (otherUserName, otherUser; connectedClientsList)
		{
			if (otherUserName != username)
			{
				Packet p;
				p.username = getCharArrFromString(otherUser.username);
				p.x = otherUser.x;
				p.y = otherUser.y;
				p.status = "online\0";
				p.bmp = getCharArrFromString(otherUser.bmpFile);
				p.action = "\0";
				writeln("sending details of " ~ otherUserName);
				clientInfo.socket.send(p.GetPacketAsBytes());
			}
		}
	}

	/** 
	 * Handles incoming data from a player and broadcasts the state changes to all the players.
	 * Params:
	 *   	username = The username of the player sending the data.
	 * Returns:
	 * 		None
	 */
	void handleIncomingDataFromClient(string username)
	{
		byte[Packet.sizeof] buffer;
		auto got = connectedClientsList[username].socket.receive(buffer);
		if (got > 0)
		{
			Packet p;
			p.FromBytes(buffer);
			connectedClientsList[username].x = p.x;
			connectedClientsList[username].y = p.y;
			broadcastData(p.GetPacketAsBytes(), username);
		}
		else
		{
			handleDisconnection(username);
		}
	}

	/** 
	 * Handles disconnection.
	 * Params:
	 *   	username = The username of player disconnected.
	 * Returns:
	 * 		None
	 */
	void handleDisconnection(string username)
	{
		auto clientInfo = connectedClientsList[username];
		clientInfo.socket.close();
		connectedClientsList.remove(username);
		writeln(username ~ " disconnected.");
		Packet p;
		char[16] usernameBytes = getCharArrFromString(username);
		p.username = usernameBytes;
		p.status = "offline\0";
		p.bmp = "\0";
		p.action = "\0";
		broadcastData(p.GetPacketAsBytes(), username);
	}

	/** 
	 * Helper to broadcast the data to all players except themselves.
	 * Params:
	 *   	data = The data to be broadcasted
	 *   	senderUsername = The sender username
	 * Returns:
	 * 		None
	 */
	void broadcastData(char[Packet.sizeof] data, string senderUsername)
	{
		foreach (username, client; connectedClientsList)
		{
			if (username != senderUsername)
			{
				client.socket.send(data);
			}
		}
	}

	/** 
	 * Utility to convert string to char[16] to be used in packet
	 * Params:
	 *   	str = String to be converted
	 * Returns: 
	 * 		char[16] arr
	 */
	char[16] getCharArrFromString(string str)
	{
		char[16] strBytes;
		strBytes[] = '\0';
		foreach (i, c; str)
		{
			strBytes[i] = c;
		}
		return strBytes;
	}
}
