/// Represents a player within the game world.
module player;

// Load the SDL2 library
import bindbc.sdl;
import sprite;

/*******
  * This struct defines a player in the game. 
  * It encapsulates the player's sprite, global coordinates on the map, 
  * and functions to control the player's movements and dance/idle states.
  */
struct Player
{

    /// User name of the client
    string username;

    /// Sprite object to load a sprite
    Sprite mSprite;

    /// Player's global coordinates, +x is to the right: ->
    int mMapXPos;

    /// Player's global coordinates, +y is down: vv
    int mMapYPos;

    /** 
     * Constructor to initialize Player object.
     * Params:
     *      username = User name of the client.
     *      renderer = SDL_Renderer pointer for rendering.
     *      filepath = Filepath to the sprite.
     */
    this(string username, SDL_Renderer* renderer, string filepath)
    {
        this.username = username;
        mSprite = Sprite(renderer, filepath);

        // Changing initial mMap positions changes what is considered (0, 0).
        // Modifying this and offsetX/offsetY (changes where it looks like 
        // the player is located)in game.d are related
        mMapXPos = 14;
        mMapYPos = 14;
    }

    /** 
     * Get the player's current x-coordinate.
     * Params:
     *      None
     * Returns: 
     *      The player's x global coordinate.
     */
    int GetX()
    {
        return this.mMapXPos;
    }

    /** 
     * Get the player's current y-coordinate.
     * Params:
     *      None
     * Returns: 
     *      The player's y global coordinate.
     */
    int GetY()
    {
        return this.mMapYPos;
    }

    /**
     * Move the player upwards.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void MoveUp()
    {
        // mSprite.mScreenYPos -=16;
        this.mMapYPos--;
        mSprite.mState = STATE.UP_WALK;
    }

    /**
     * Set the player to face upwards.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void TurnUp()
    {
        mSprite.mState = STATE.UP_WALK;
    }

    /**
     * Move the player downwards.
    * Params:
     *      None
     * Returns: 
     *      None
     */
    void MoveDown()
    {
        // mSprite.mScreenYPos +=16;
        this.mMapYPos++;
        mSprite.mState = STATE.DOWN_WALK;
    }

    /**
     * Set the player to face downwards.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void TurnDown()
    {
        mSprite.mState = STATE.DOWN_WALK;
    }

    /**
     * Move the player to the left.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void MoveLeft()
    {
        // mSprite.mScreenXPos -=16;
        this.mMapXPos--;
        mSprite.mState = STATE.LEFT_WALK;
    }

    /**
     * Set the player to face left.
     */
    void TurnLeft()
    {
        mSprite.mState = STATE.LEFT_WALK;
    }

    /**
     * Move the player to the right.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void MoveRight()
    {
        // mSprite.mScreenXPos +=16;
        this.mMapXPos++;
        mSprite.mState = STATE.RIGHT_WALK;
    }

    /**
     * Set the player to face right.
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void TurnRight()
    {
        mSprite.mState = STATE.RIGHT_WALK;
    }

    /**
     * Set the player to dancing or idle state. 
     * Params:
     *      None
     * Returns: 
     *      None
     */
    void MoveDance()
    {
        if (mSprite.mState == STATE.DANCE)
        {
            mSprite.mState = STATE.IDLE;
        }
        else
        {
            mSprite.mState = STATE.DANCE;
        }
    }

    /** 
     * Render the player on the screen.
     * Params:
     *      renderer = SDL_Renderer pointer for rendering.
     * Returns:
     *      None
     */
    void Render(SDL_Renderer* renderer)
    {
        mSprite.Render(renderer);
        if (mSprite.mState != STATE.DANCE)
        {
            mSprite.mState = STATE.IDLE;
        }
    }

    /** 
     * Renders other players in the game relative to the main player
     * Params:
     *      renderer = SDL renderer
     *      mainPlayerX = Global x coord of the main player
     *      mainPlayerY = Global y coord of the main player
     * Returns:
     *      None
     */
    void RenderOther(SDL_Renderer* renderer, int mainPlayerX, int mainPlayerY)
    {
        mSprite.RenderOther(renderer, mainPlayerX, mainPlayerY, mMapXPos, mMapYPos);
        if (mSprite.mState != STATE.DANCE)
        {
            mSprite.mState = STATE.IDLE;
        }
    }
}

// Test case 1
@("Verify move down")
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
    
    assert(p.GetX == 14);
    assert(p.GetY == 14);

    p.MoveDown();
    assert(p.GetX == 14);
    assert(p.GetY == 15);
}

// Test case 2
@("Verify move up")
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

    assert(p.GetX == 14);
    assert(p.GetY == 14);

    p.MoveUp();
    assert(p.GetX == 14);
    assert(p.GetY == 13);
}

// Test case 3
@("Verify move left")
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

    assert(p.GetX == 14);
    assert(p.GetY == 14);

    p.MoveLeft();
    assert(p.GetX == 13);
    assert(p.GetY == 14);
}

// Test case 4
@("Verify move right")
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

    assert(p.GetX == 14);
    assert(p.GetY == 14);

    p.MoveRight();
    assert(p.GetX == 15);
    assert(p.GetY == 14);
}


