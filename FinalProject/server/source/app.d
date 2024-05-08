import chatserver : ChatServer;
import gameserver : GameServer;

/** 
 * Main server function which boots up chat and game server.
 */
void main()
{
    ChatServer chatServer = new ChatServer;
    chatServer.start();
    GameServer gameServer = new GameServer;
    gameServer.start();
}
