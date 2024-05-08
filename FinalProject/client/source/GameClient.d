/// Represents the core game mechanics and logic.
module gameclient;

// Import D standard libraries
import std.stdio;
import std.string;
import std.socket;
import std.conv;

import setup_sdl; // verify that sdl has been loaded
import sprite;
import tilemap;
import player;

import music;

// Load the SDL2 library
import bindbc.sdl;

import core.thread;
import core.sync.mutex;

import Packet : Packet;
import chatwindow;

/// Store walking direction for sprites.
enum DIRECTION
{
    LEFT,
    RIGHT,
    UP,
    DOWN
};

/** 
 * This class represents the core game mechanics and logic for a multiplayer 2D game.
 */
class GameClient
{
    string serverIp;
    string username; /// A unique identifier for the player.
    SDL_Window* window; /// Pointer to the SDL_Window for creating a SDL window.
    DrawableTileMap dt, dt2, dt3, dt4, dt5; /// A DrawableTileMap object representing a layer of the tile map.
    DrawableTileMap*[5] dts; /// Array of DrawableTileMap pointers representing different layers of the map.
    Player player; /// Represents a player in the game.
    Socket gameSocket; /// The socket used for communication with the server.
    byte[Packet.sizeof] buffer; /// Buffer to store data received from the server.
    Mutex mutex; /// Mutex for managing thread safety.
    Player[string] otherPlayers; /// Array of other players in the game.
    SDL_Renderer* renderer = null; /// Pointer to the SDL_Renderer for rendering.
    string bmpFile; /// File name of the sprite image.
    Music[4][4] allTracks; /// 2D Array to store music tracks in each room.
    bool[4] turntableCollisionAllRooms; /// Boolean array to store player's turntable collision status in each room
    ChatWindow chatWindow; /// Represents a chat window in the game.
    int[] tracknum = [0, 0, 0, 0]; /// Int array to store current track information in each room
    bool firstContact = false; /// This boolean is to represent first contact of player with the turntable, we only print the playlist for first contact.

    /** 
     * Constructor to initialize the game window, renderer, and loads tile sets for different layers.
     * Params:
     *      username = A unique identifier for player.
     *      chatWindow = A chat window object in the game.
     *      serverIp = Ip address that runs the server.
     */
    this(string username, ChatWindow chatWindow, string serverIp)
    {
        this.username = username;
        this.chatWindow = chatWindow;
        this.serverIp = serverIp;
        // Create an SDL window
        this.window = SDL_CreateWindow("United Music Club",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            32 * 20,
            32 * 15,
            SDL_WINDOW_SHOWN);

        SDL_SetWindowPosition(window, 200, 210);
        // Create a hardware accelerated renderer
        this.renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
        // Load our tiles for base layer
        TileSet ts = TileSet(renderer, "./assets/images/tiles/lpc-floors/floors.bmp", 32, 32, 64);
        dt = DrawableTileMap(ts);

        // Load our tiles for wall layer
        TileSet wall = TileSet(renderer, "./assets/images/tiles/lpc-walls/walls.bmp", 32, 64, 96);
        dt2 = DrawableTileMap(wall);

        // Load our tiles for classic decor layer
        TileSet classic_decor = TileSet(renderer, "./assets/images/tiles/LPC_city_inside/city_inside.bmp", 32, 24, 16);
        dt3 = DrawableTileMap(classic_decor);

        // Load our tiles for modern decor layer
        TileSet modern_decor = TileSet(renderer, "./assets/images/tiles/inside/inside.bmp", 32, 16, 10);
        dt4 = DrawableTileMap(modern_decor);

        // Load our tiles for turntable layer
        TileSet turntable = TileSet(renderer, "./assets/images/tiles/turntables/turntables.bmp", 32, 8, 8);
        dt5 = DrawableTileMap(turntable);

        dts = [&dt, &dt2, &dt3, &dt4, &dt5];

        // Initialise player instance and music tracks
        initPlayerAndSetupMusic();

        // Aligning windows to correct position on the screen
        int sdlWindowX, sdlWindowY, sdlWindowWidth, sdlWindowHeight;
        SDL_GetWindowPosition(window, &sdlWindowX, &sdlWindowY);
        SDL_GetWindowSize(window, &sdlWindowWidth, &sdlWindowHeight);
        chatWindow.move(sdlWindowX + sdlWindowWidth, sdlWindowY);
    }

    /** 
     * Initialize player instance and music tracks
     * Returns:
     *      None
     */
    void initPlayerAndSetupMusic()
    {
        // Send username to server, server will provide the bmp name available
        writeln("Starting client...attempt to create socket");
        gameSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        gameSocket.connect(new InternetAddress(serverIp, 50002));
        writeln("Connected");
        gameSocket.send(username);
        mutex = new Mutex();
        auto received = gameSocket.receive(buffer);
        if (received != Socket.ERROR)
        {
            bmpFile = cast(string) buffer[0 .. received];
            writeln("Received BMP file: ", bmpFile);
        }
        else
        {
            writeln("Error receiving BMP file");
            return;
        }
        write(">");

        // Spawn a thread for receiving messages
        auto receiveThread = new Thread({
            while (true)
            {
                auto got = gameSocket.receive(buffer);
                if (got > 0)
                {
                    mutex.lock();
                    handleIncomingData();
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

        // Create our player
        player = Player(username, renderer, "./assets/images/characters/" ~ bmpFile);

        // load music
        string[4][4] trackLists = [
            [
                "/assets/music/first/424_23 blippy.mp3",
                "/assets/music/first/gonny.mp3",
                "/assets/music/first/Moye Moye.mp3",
                "/assets/music/first/neo.mp3"
            ],
            [
                "/assets/music/classic/mozart.mp3",
                "/assets/music/classic/mendelssohn.mp3",
                "/assets/music/classic/verdi.mp3",
                "/assets/music/classic/schubert.mp3"
            ],
            [
                "/assets/music/jazz_1/unforgettable.mp3",
                "/assets/music/jazz_1/round_midnight.mp3",
                "/assets/music/jazz_1/cantaloupe_island.mp3",
                "/assets/music/jazz_1/l_appuntamento.mp3"
            ],
            [
                "/assets/music/Rap/eminem.mp3",
                "/assets/music/Rap/mockingbird.mp3",
                "/assets/music/Rap/notafraid.mp3",
                "/assets/music/Rap/venom.mp3"
            ]
        ];

        // Create Music objects based on each room's track list and add to nested array allTracks[][]
        for (int index = 0; index < trackLists.length; index++)
        {
            int counter = 0;
            auto trackList = trackLists[index];

            for (int i = 0; i < trackList.length; i++)
            {
                Music val = new Music(trackList[i], index + 1); // Increment index by 1 to match music channel in each room
                allTracks[index][counter] = val;
                counter++;
            }
        }

        // Play the first song in each room's track list
        for (int room = 0; room < allTracks.length; room++)
        {
            allTracks[room][0].playMusic(-1);
        }
    }

    /** 
     * Main Game loop
     * Returns: 
     *      true when game is running
     */
    bool runGameLoop()
    {
        // Infinite loop for our application
        static bool gameIsRunning = true;

        // How 'zoomed' in are we
        int zoomFactor = 1;

        // Main application loop
        if (gameIsRunning)
        {
            SDL_Event event;

            // (1) Handle Input
            // Start our event loop
            while (SDL_PollEvent(&event) != 0)
            {
                // Handle each specific event
                if (event.type == SDL_QUIT)
                {
                    gameIsRunning = false;
                    chatWindow.quitApp();
                    quitSDL();
                }
            }
            // Get Keyboard input
            const ubyte* keyboard = SDL_GetKeyboardState(null);

            int playerX = player.GetX();
            int playerY = player.GetY();

            bool moveLeft = checkNoCollision(playerX, playerY, DIRECTION.LEFT);
            bool moveRight = checkNoCollision(playerX, playerY, DIRECTION.RIGHT);
            bool moveUp = checkNoCollision(playerX, playerY, DIRECTION.UP);
            bool moveDown = checkNoCollision(playerX, playerY, DIRECTION.DOWN);

            auto roomNumber = detectRoom(playerX, playerY);

            bool turntableLeft = checkTurntableCollision(playerX, playerY, DIRECTION.LEFT, roomNumber);
            bool turntableRight = checkTurntableCollision(playerX, playerY, DIRECTION.RIGHT, roomNumber);
            bool turntableUp = checkTurntableCollision(playerX, playerY, DIRECTION.UP, roomNumber);
            bool turntableDown = checkTurntableCollision(playerX, playerY, DIRECTION.DOWN, roomNumber);

            if (roomNumber >= 1 && roomNumber <= 4)
            {
                turntableCollisionAllRooms[roomNumber - 1] = turntableLeft || turntableRight || turntableUp || turntableDown;
            }

            //Toggle firstContact bool
            if (turntableLeft || turntableRight || turntableUp || turntableDown)
            {
                if (!firstContact)
                {
                    firstContact = true;
                    printPlayList(roomNumber);
                }
            }
            else
            {
                // Reset the flag when player is not in contact
                firstContact = false;
            }

            // Check for movement
            handleMovement(keyboard, moveLeft, moveRight, moveUp, moveDown);

            unmuteMusicInRoom(keyboard, roomNumber, allTracks, turntableCollisionAllRooms);

            if (turntableLeft || turntableRight || turntableUp || turntableDown)
            {
                handlePauseResume(keyboard, roomNumber, allTracks);
            }

            // (2) Handle Updates

            // (3) Clear and Draw the Screen
            // Gives us a clear "canvas"
            SDL_SetRenderDrawColor(renderer, 100, 190, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);

            // NOTE: The draw order here is very important
            //       We follow the 'painters algorithm' in 2D
            //       meaning that we draw the background first,
            //  
            // Render out DrawableTileMap for each layer
            for (int i = 0; i < dts.length; i++)
            {
                DrawableTileMap* dt = dts[i];
                dt.Render(renderer, dt.mTiles[i], zoomFactor, player.GetX(), player.GetY());
            }

            // Render other players in the game
            foreach (username, otherPlayer; otherPlayers)
            {
                otherPlayer.RenderOther(renderer, player.GetX(), player.GetY());
            }

            // Draw our sprite
            player.Render(renderer);

            // Little frame capping hack so we don't run too fast
            SDL_Delay(100);

            // Finally show what we've drawn
            // (i.e. anything where we have called SDL_RenderCopy will be in memory and presnted here)
            SDL_RenderPresent(renderer);
        }

        return gameIsRunning;
    }

    /** 
     * Function to terminate the game window.
     * Returns:
     *      None
     */
    void quitSDL()
    {
        writeln("Terminating game window");
        gameSocket.close();
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    /** 
     * Prints the room's playlist for the player
     * Params:
     *      roomNumber = The room number
     * Returns:
     *      None
     */
    void printPlayList(int roomNumber)
    {
        writeln("Please pick a song:");
        if (roomNumber == 1)
        {
            writeln("1. Blippy");
            writeln("2. Gonny");
            writeln("3. Moye Moye");
            writeln("4. Neo");
        }
        else if (roomNumber == 2)
        {
            writeln("1. Mozart");
            writeln("2. Mendelssohn");
            writeln("3. Verdi");
            writeln("4. Schubert");
        }
        else if (roomNumber == 3)
        {
            writeln("1. Unforgettable");
            writeln("2. Round Midnight");
            writeln("3. Cantaloupe Island");
            writeln("4. L'Appuntamento");
        }
        else if (roomNumber == 4)
        {
            writeln("1. Love the way you lie");
            writeln("2. Mockingbird");
            writeln("3. Not Afraid");
            writeln("4. Venom");
        }
    }

    /**
     * Check collision for sprite movement.
     * Params:
     *      playerX = X-coordinate of the player.
     *      playerY = Y-coordinate of the player.
     *      d = Direction in which the collision is being checked.
     * Returns:
     *      True if no collision, false otherwise.
     */
    bool checkNoCollision(int playerX, int playerY, DIRECTION d)
    {
        // checks whether the player makes a valid move or not. returns true if no collision. otherwise returns false
        for (int i = 0; i < dts.length; i++)
        {
            DrawableTileMap* dtCurrent = dts[i];
            int adjTile;

            switch (d)
            {
            case DIRECTION.RIGHT:
                adjTile = dtCurrent.GetTileAt(i, playerX + 1, playerY);
                break;
            case DIRECTION.LEFT:
                adjTile = dtCurrent.GetTileAt(i, playerX - 1, playerY);
                break;
            case DIRECTION.UP:
                adjTile = dtCurrent.GetTileAt(i, playerX, playerY - 1);
                break;
            case DIRECTION.DOWN:
                adjTile = dtCurrent.GetTileAt(i, playerX, playerY + 1);
                break;
            default:
                adjTile = 0;
                break;
            }

            bool collisionCase = (i == 0 && (adjTile != 1654 && adjTile != 1794 && adjTile != 1796 && adjTile != 1798 && adjTile != 1801))
                || (i == 1 && adjTile != -2049) || (i == 2 && adjTile != -8193) || (i == 3 && adjTile != -8577) || (
                    i == 4 && adjTile != -8737);

            if (collisionCase)
            {
                return false;
            }
        }
        return true;
    }

    /**
     * Detect the current room that the player is in.
     * Params:
     *      playerX = X-coordinate of the player.
     *      playerY = Y-coordinate of the player.
     * Returns:
     *      The current room number based on player's position.
     */
    auto detectRoom(int playerX, int playerY)
    {

        DrawableTileMap* floorLayer = dts[0]; // Retrieve floor layer 
        int currentTile = floorLayer.GetTileAt(0, playerX, playerY);

        switch (currentTile)
        {
        case 1796:
            // writeln("In room 1 (top room)");
            return 1;
        case 1794:
            // writeln("In room 2 (bottom room)");
            return 2;
        case 1801:
            // writeln("In room 3 (left room)");
            return 3;
        case 1798:
            // writeln("In room 4 (right room)");
            return 4;
        case 1654:
            // writeln("Not in any room");
            return 0;
        default:
            return -1;
        }
    }

    /**
     * Check if the player collides with a turntable in a room.
     * Params:
     *      playerX = X-coordinate of the player.
     *      playerY = Y-coordinate of the player.
     *      d = Direction in which the collision is being checked.
     *      roomNumber = The number of the current room that the player is in.
     * Returns:
     *      True if colliding with a turntable, false otherwise.
     */
    bool checkTurntableCollision(int playerX, int playerY, DIRECTION d, int roomNumber)
    {
        const int turntableLayerNum = 4;

        DrawableTileMap* turntableLayer = dts[turntableLayerNum]; // Retrieve turntable layer
        int adjTile;

        switch (d)
        {
        case DIRECTION.RIGHT:
            adjTile = turntableLayer.GetTileAt(turntableLayerNum, playerX + 1, playerY);
            break;
        case DIRECTION.LEFT:
            adjTile = turntableLayer.GetTileAt(turntableLayerNum, playerX - 1, playerY);
            break;
        case DIRECTION.UP:
            adjTile = turntableLayer.GetTileAt(turntableLayerNum, playerX, playerY - 1);
            break;
        case DIRECTION.DOWN:
            adjTile = turntableLayer.GetTileAt(turntableLayerNum, playerX, playerY + 1);
            break;
        default:
            adjTile = 0;
            break;
        }

        bool adjTurntable = (adjTile + turntableLayer.GetTurntableLayerFirstGid() == 8769) ||
            (adjTile + turntableLayer.GetTurntableLayerFirstGid() == 8770) ||
            (adjTile + turntableLayer.GetTurntableLayerFirstGid() == 8777) ||
            (adjTile + turntableLayer.GetTurntableLayerFirstGid() == 8778);

        if (adjTurntable)
        {
            // writefln("collide with turntable in room %d", roomNumber);
            return true;
        }
        else
        {
            return false;
        }
    }

    /**
     * Handle player movement from keyboard events.
     * Params:
     *      keyboard = Array representing the state of the keyboard keys.
     *      moveLeft = Boolean indicating movement to the left.
     *      moveRight = Boolean indicating movement to the right.
     *      moveUp = Boolean indicating upwards movement.
     *      moveDown = Boolean indicating downwards movement.
     * Returns:
     *      None
     */
    void handleMovement(const(ubyte)* keyboard, bool moveLeft, bool moveRight, bool moveUp, bool moveDown)
    {

        // writefln("movement booleans: [%o, %o, %o, %o]", moveLeft, moveRight, moveUp, moveDown);

        if (keyboard[SDL_SCANCODE_LEFT] && moveLeft)
        {
            player.MoveLeft();
            sendToServer("MoveLeft");
        }
        else if (keyboard[SDL_SCANCODE_LEFT] && !moveLeft)
        {
            player.TurnLeft();
            sendToServer("TurnLeft");
        }
        if (keyboard[SDL_SCANCODE_RIGHT] && moveRight)
        {
            player.MoveRight();
            sendToServer("MoveRight");
        }
        else if (keyboard[SDL_SCANCODE_RIGHT] && !moveRight)
        {
            player.TurnRight();
            sendToServer("TurnRight");
        }
        if (keyboard[SDL_SCANCODE_UP] && moveUp)
        {
            player.MoveUp();
            sendToServer("MoveUp");
        }
        else if (keyboard[SDL_SCANCODE_UP] && !moveUp)
        {
            player.TurnUp();
            sendToServer("TurnUp");
        }
        if (keyboard[SDL_SCANCODE_DOWN] && moveDown)
        {
            player.MoveDown();
            sendToServer("MoveDown");
        }
        else if (keyboard[SDL_SCANCODE_DOWN] && !moveDown)
        {
            player.TurnDown();
            sendToServer("TurnDown");
        }
        if (keyboard[SDL_SCANCODE_D])
        {
            player.MoveDance();
            sendToServer("MoveDance");
        }
    }

    /**
     * Unmute music based on the player's current room and their music selection.
     * Params:
     *      keyboard = keyboard input from the player.
     *      roomNumber = The number of the current room.
     *      allTracks = Nested array of Music objects representing different music tracks in different rooms.
     *      turntableCollision = An array of boolean to detect if the player collides with the turntable in a room.
     * Returns:
     *      None
     */
    void unmuteMusicInRoom(const(ubyte)* keyboard, int roomNumber, Music[4][4] allTracks, bool[4] turntableCollision)
    {
        if (roomNumber > 0 && roomNumber <= allTracks.length)
        {
            int currentTrack = tracknum[roomNumber - 1];

            if (turntableCollision[roomNumber - 1])
            {
                for (int i = 0; i < allTracks[roomNumber - 1].length; i++)
                {
                    if (keyboard[SDL_SCANCODE_1 + i])
                    {
                        if (!allTracks[roomNumber - 1][currentTrack].isMuted())
                        {
                            allTracks[roomNumber - 1][currentTrack].mute();
                        }

                        currentTrack = i;
                        allTracks[roomNumber - 1][currentTrack].playMusic(-1);
                        sendMusicChangeToServer(roomNumber, currentTrack, 2);
                        if (allTracks[roomNumber - 1][currentTrack].isMuted())
                        {
                            writeln("Now playing track ", i + 1);
                            allTracks[roomNumber - 1][currentTrack].unmute();
                        }
                    }
                }

                tracknum[roomNumber - 1] = currentTrack;
            }
            else
            {
                // The current song playing when the character enters a room
                if (allTracks[roomNumber - 1][currentTrack].isMuted())
                {
                    allTracks[roomNumber - 1][currentTrack].unmute();
                    // writeln("unmuting ", roomNumber);
                }
            }
        }
        else
        {
            // if the character is NOT in any room, mute all music
            foreach (tracks; allTracks)
            {
                foreach (track; tracks)
                {
                    track.mute();
                }
            }
        }
    }

    /**
     * Pause music based on the player's current room.
     * Params:
     *      keyboard = keyboard input from the player.
     *      roomNumber = The number of the current room.
     *      allTracks = Nested array of Music objects representing different music tracks in different rooms.
     * Returns:
     *      None
     */
    void handlePauseResume(const(ubyte)* keyboard, int roomNumber, Music[4][4] allTracks)
    {

        if (keyboard[SDL_SCANCODE_P])
        {

            // The current song playing when the character enters a room

            writeln("Inside Room number : ", roomNumber - 1);

            if (allTracks[roomNumber - 1][tracknum[roomNumber - 1]].isPlaying())
            {
                // Adding 1 for printing the song on the playlist as it's 0 indexed in app but user sees 1 indexed.
                writeln("Track number  : ", (tracknum[roomNumber - 1] + 1), " was Playing. Pausing it");
                // pause the channel
                allTracks[roomNumber - 1][tracknum[roomNumber - 1]].setPlaying(false);
                allTracks[roomNumber - 1][tracknum[roomNumber - 1]].pauseMusic();
                sendMusicChangeToServer(roomNumber, tracknum[roomNumber - 1], 1);
            }
            else
            {
                writeln("Track number  : ", (tracknum[roomNumber - 1] + 1), " was Paused. Playing it");
                allTracks[roomNumber - 1][tracknum[roomNumber - 1]].setPlaying(true);
                allTracks[roomNumber - 1][tracknum[roomNumber - 1]].resumeMusic();
                sendMusicChangeToServer(roomNumber, tracknum[roomNumber - 1], 3);
            }
        }
    }

    /** 
     * Send the player data to the server based on any action.
     * Params:
     *      action = Action made by the player
     * Returns:
     *      None
     */
    void sendToServer(string action)
    {
        Packet data;
        data.username = getCharArrFromString(player.username);
        data.x = player.GetX();
        data.y = player.GetY();
        data.bmp = getCharArrFromString(bmpFile);
        data.status = getCharArrFromString("online");
        data.action = getCharArrFromString(action);
        data.isMusicChange = false;
        data.roomNumber = 0;
        data.trackNum = 0;
        data.pauseOrPlayOrResume = 0;
        gameSocket.send(data.GetPacketAsBytes());
    }

    /** 
     * Send the music data to the server based on any music change.
     * Params:
     *      roomNumber = Room number where music changed
     *      trackNum = Track number that changed
     *      pauseOrPlayOrResume = 1 for pausing, 2 for switching the music, 3 for resuming
     * Returns:
     *      None
     */
    void sendMusicChangeToServer(int roomNumber, int trackNum, int pauseOrPlayOrResume)
    {
        Packet data;

        // Not relevant, but using same packet, so have to send the complete data
        data.username = getCharArrFromString(player.username);
        data.x = player.GetX();
        data.y = player.GetY();
        data.bmp = getCharArrFromString(bmpFile);
        data.status = getCharArrFromString("online");
        data.action = getCharArrFromString("MoveDown");

        //Real data
        data.isMusicChange = true;
        data.roomNumber = roomNumber;
        data.trackNum = trackNum;
        data.pauseOrPlayOrResume = pauseOrPlayOrResume;
        gameSocket.send(data.GetPacketAsBytes());
    }

    /** 
     * Handle incoming data of other players.
     * Returns:
     *      None
     */
    void handleIncomingData()
    {
        writeln("Incoming");
        Packet formattedPacket;
        formattedPacket.FromBytes(buffer);
        string playerUsername = (cast(string) formattedPacket.username).stripRight("\0");
        string status = (cast(string) formattedPacket.status).stripRight("\0");
        string otherBmpFile = (cast(string) formattedPacket.bmp).stripRight("\0");
        string action = (cast(string) formattedPacket.action).stripRight("\0");
        int x = formattedPacket.x;
        int y = formattedPacket.y;
        bool isMusicChange = formattedPacket.isMusicChange;
        if (isMusicChange)
        {
            writeln("Incoming in music now");
            handleMusicChangeFromOthers(formattedPacket.roomNumber, formattedPacket.trackNum, formattedPacket
                    .pauseOrPlayOrResume);
            return;
        }
        if (status == "offline")
        {
            otherPlayers.remove(playerUsername);
            return;
        }
        if (!(playerUsername in otherPlayers))
        {
            Player newPlayer = Player(playerUsername, renderer, "./assets/images/characters/" ~ otherBmpFile);
            newPlayer.mMapXPos = x;
            newPlayer.mMapYPos = y;
            otherPlayers[playerUsername] = newPlayer;
        }
        else
        {
            Player otherPlayer = otherPlayers[playerUsername];
            handleOtherPlayerMovement(otherPlayer, action);
        }
    }

    /** 
     * Handle music change from another player (player 1). 
     * Player 2 should listen to the same music as player 1, after player 1 changes the music.
     * Params:
     *      roomNumber = Room number where music changed
     *      trackNumReceived = Track num of the new music
     *      pauseOrPlayOrResume = 1 for pausing, 2 for switching the music, 3 for resuming
     * Returns: 
     *      None
     */
    void handleMusicChangeFromOthers(int roomNumber, int trackNumReceived, int pauseOrPlayOrResume)
    {
        if (pauseOrPlayOrResume == 1) // Pause
        {
            // Adding 1 for printing the song on the playlist as it's 0 indexed in app but user sees 1 indexed.
            writeln("Track number : ", (tracknum[roomNumber - 1] + 1), " was Playing. Pausing it");
            // pause the channel
            allTracks[roomNumber - 1][tracknum[roomNumber - 1]].setPlaying(false);
            allTracks[roomNumber - 1][tracknum[roomNumber - 1]].pauseMusic();
        }
        else if (pauseOrPlayOrResume == 2) // Change song
        {
            tracknum[roomNumber - 1] = trackNumReceived;
            //Mute anything that's running right now
            for (int i = 0; i < allTracks[roomNumber - 1].length; i++)
            {
                if (!allTracks[roomNumber - 1][i].isMuted())
                {
                    allTracks[roomNumber - 1][i].mute();
                }
            }
            //Play the new song
            allTracks[roomNumber - 1][trackNumReceived].playMusic(-1);
        }
        else if (pauseOrPlayOrResume == 3) // Resume
        {
            writeln("Track number : ", (tracknum[roomNumber - 1] + 1), " was Paused. Playing it");
            allTracks[roomNumber - 1][tracknum[roomNumber - 1]].setPlaying(true);
            allTracks[roomNumber - 1][tracknum[roomNumber - 1]].resumeMusic();
        }
    }

    /** 
	 * Utility to convert string to char[16] to be used in packet
	 * Params:
	 *      str = String to be converted
	 * Returns: 
     *      char[16] arr
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

    /** 
     * Handles the movement of other players in the game.
     * Using this instead of only passing coords of other players because we want to show the 
     * animation of other players as well.
     * Params:
     *      otherPlayer = Instance of other player
     *      action = Action of other player
     * Returns:
     *      None
     */
    void handleOtherPlayerMovement(Player otherPlayer, string action)
    {
        switch (action)
        {
        case "MoveLeft":
            otherPlayer.MoveLeft();
            break;
        case "TurnLeft":
            otherPlayer.TurnLeft();
            break;
        case "MoveRight":
            otherPlayer.MoveRight();
            break;
        case "TurnRight":
            otherPlayer.TurnRight();
            break;
        case "MoveUp":
            otherPlayer.MoveUp();
            break;
        case "TurnUp":
            otherPlayer.TurnUp();
            break;
        case "MoveDown":
            otherPlayer.MoveDown();
            break;
        case "TurnDown":
            otherPlayer.TurnDown();
            break;
        case "MoveDance":
            otherPlayer.MoveDance();
            break;
        default:
            break;
        }
        otherPlayers[otherPlayer.username] = otherPlayer;
    }
}

// UNIT TESTS
//Test case 1
@("Testing Player First Location")
unittest
{
    SDL_Window* window = SDL_CreateWindow("United Music Club",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        32 * 20,
        32 * 15,
        SDL_WINDOW_SHOWN);
    SDL_Renderer * renderer = SDL_CreateRenderer(window,  - 1, SDL_RENDERER_ACCELERATED);
    Player p = Player("aoh", renderer, "../assets/images/characters/Arc-Pur.bmp");

    assert(p.GetX() == 14, "NOT IN CORRECT X COORDINATE");
    assert(p.GetY() == 14, "NOT IN CORRECT Y COORDINATE");
}
