/// Represents a sprite entity within the game world.
module sprite;

// Load the SDL2 library
import bindbc.sdl;
import std.stdio;

/// Store state for sprites.
enum STATE
{
    IDLE,
    WALK,
    LEFT_WALK,
    RIGHT_WALK,
    UP_WALK,
    DOWN_WALK,
    DANCE
};

const SPRITE_SIZE = 32; // size of a sprite animation cel in pixels
const SPRITE_SCALE = 2; // scale of sprite on screen

/*******
 * This struct defines a sprite that holds a texture and position in the game.
 * It encapsulates a sprite's properties, including its screen coordinates, texture, 
 * animation frames, and states.
 */
struct Sprite
{
    /// Sprite's screen coordinates. Center x: 17 tiles in from the left.
    int mScreenXPos = 32 / 2 * 17;

    /// Sprite's screen coordinates. Center y: 13 tiles down from the top.
    int mScreenYPos = 32 / 2 * 13;

    /// Destination rectangle that the texture will fill. This controls the size of the sprite on the screen.
    SDL_Rect mRectangle; 

    /// SDL_Texture pointer holding the sprite's graphical representation.
    SDL_Texture* mTexture;

    /// Represents the current frame of the sprite's animation sequence.
    int mFrame;

    /// Represents the vertical position (y-coordinate) of the current frame.
    int y_mFrame;

    /// Current state of the sprite, indicating its movement or action.
    STATE mState;

    /**
     * Constructor to initialize a Sprite object.
     * Params:
     *      renderer = SDL_Renderer pointer for rendering.
     *      filepath = Filepath to the sprite bitmap.
     */
    this(SDL_Renderer* renderer, string filepath)
    {
        // Load the bitmap surface
        SDL_Surface* myTestImage = SDL_LoadBMP(filepath.ptr);
        // Create a texture from the surface
        mTexture = SDL_CreateTextureFromSurface(renderer, myTestImage);
        // Done with the bitmap surface pixels after we create the texture, we have
        // effectively updated memory to GPU texture.
        SDL_FreeSurface(myTestImage);

        // Rectangle is where we will represent the shape
        mRectangle.x = mScreenXPos;
        mRectangle.y = mScreenYPos;
        mRectangle.w = SPRITE_SIZE * SPRITE_SCALE;
        mRectangle.h = SPRITE_SIZE * SPRITE_SCALE;
    }

    /** 
     * Renders other players in the game relative to the main player
     * Params:
     *      renderer = SDL renderer
     *      mainPlayerX = Global x coord of the main player
     *      mainPlayerY = Global y coord of the main player
     *      thisPlayerX = Global x coord of the other player to be rendered
     *      thisPlayerY = Global y coord of the other player to be rendered
     * Returns:
     *      None
     */
    void RenderOther(SDL_Renderer* renderer, int mainPlayerX, int mainPlayerY, int thisPlayerX, int thisPlayerY)
    {
        handlePlayerAnimation();

        SDL_Rect selection; // this is the selection window on the bitmap texture. picks which animation frame to view
        selection.x = SPRITE_SIZE * mFrame + SPRITE_SIZE;
        selection.y = SPRITE_SIZE * y_mFrame;
        selection.w = SPRITE_SIZE;
        selection.h = SPRITE_SIZE;

        int xOffset = 9 - mainPlayerX;
        int yOffset = 7 - mainPlayerY;
        mRectangle.x = (thisPlayerX + xOffset) * SPRITE_SIZE; // pixel position
        mRectangle.y = (thisPlayerY + yOffset) * SPRITE_SIZE;

        // Render the bitmap selection in the renderer
        SDL_RenderCopy(renderer, mTexture, &selection, &mRectangle);
    }

    /**
     * Renders the sprite on the screen. This controls the walking animation.
     * Params:
     *      renderer = SDL_Renderer pointer for rendering.
     * Returns:
     *      None
     */
    void Render(SDL_Renderer* renderer)
    {
        SDL_Rect selection; // This is the selection window on the bitmap texture. Picks which animation frame to view.
        selection.x = SPRITE_SIZE * mFrame + SPRITE_SIZE;
        selection.y = SPRITE_SIZE * y_mFrame;
        selection.w = SPRITE_SIZE;
        selection.h = SPRITE_SIZE;

        mRectangle.x = mScreenXPos;
        mRectangle.y = mScreenYPos;

        // Render the bitmap selection in the renderer
        SDL_RenderCopy(renderer, mTexture, &selection, &mRectangle);

        // show the SDL rectangle the sprite is in
        // SDL_RenderDrawRect(renderer, &mRectangle);

        handlePlayerAnimation();
    }

    /** 
     * Helper function to handle player animation.
     * Returns:
     *      None
     */
    void handlePlayerAnimation()
    {
        if (mState == STATE.DOWN_WALK)
        {
            y_mFrame = 0;
            mFrame++;
            if (mFrame > 2) // 2 is the number of walk frames
            {
                mFrame = 0;
            }
        }
        else if (mState == STATE.UP_WALK)
        {
            y_mFrame = 4;
            mFrame++;
            if (mFrame > 2) // 2 is the number of walk frames
            {
                mFrame = 0;
            }
        }
        else if (mState == STATE.LEFT_WALK)
        {
            y_mFrame = 6;
            mFrame++;
            if (mFrame > 2) // 2 is the number of walk frames
            {
                mFrame = 0;
            }
        }
        else if (mState == STATE.RIGHT_WALK)
        {
            y_mFrame = 2;
            mFrame++;
            if (mFrame > 2) // 2 is the number of walk frames
            {
                mFrame = 0;
            }
        }
        else if (mState == STATE.DANCE)
        {
            if (mFrame < 4)
                mFrame = 18;
            y_mFrame = 1;
            mFrame++;
            if (mFrame > 21) // 2 is the number of walk frames
            {
                mFrame = 19;
            }
        }
    }
}
