/// Represents a tile map responsible for rendering tiles within the game world.
module tilemap;

// Load the SDL2 library
import bindbc.sdl;
import std.stdio;

/********
 * This struct defines a drawable tile map in the game. 
 * It is responsible for drawing the actual tiles for the tilemap data structure.
 */
struct DrawableTileMap
{

    /// Map width
    const int mMapXSize = 30;

    /// Map height
    const int mMapYSize = 30;

    /// The GID that maps to the first tile in floor data set
    int floor_first_gid = 1;

    /// Floor layer data for tile map
    int[] floorLayerData = [
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1797,
        1797, 1797, 1797, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1797, 1797, 1797, 1797, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1802, 1802, 1802, 1802, 1802, 1802, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1799,
        1799, 1799, 1799, 1799, 1799, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1795,
        1795, 1795, 1795, 1795, 1795, 1795, 1795, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655,
        1655, 1655, 1655, 1655, 1655, 1655
    ];

    // The GID that maps to the first tile in wall data set
    int wall_first_gid = 2049;

    /// Wall layer data for tile map
    int[] wallLayerData = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3149, 3150, 3150, 3150, 3150, 3150, 3150,
        3150, 3150, 3151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3213, 0, 0, 0, 0, 0, 0, 0, 0, 3215, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3277, 3278, 3278, 0, 0, 0, 0, 3278, 3278,
        3279, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        2521, 2522, 2522, 2522, 2522, 2522, 2522, 2523, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3189, 3190, 3190, 3190, 3190, 3190, 3190, 3191,
        2585, 0, 0, 0, 0, 0, 0, 2587, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        3253, 0, 0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 2587, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        3253, 0, 0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 2587, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        3253, 0, 0, 0, 0, 0, 0, 3255,
        2585, 0, 0, 0, 0, 0, 0, 2587, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        3253, 0, 0, 0, 0, 0, 0, 3255,
        2649, 2650, 2650, 2650, 2650, 2650, 2650, 2651, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 3317, 3318, 3318, 3318, 3318, 3318, 3318, 3319,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3161, 3162, 3162, 0, 0, 0, 0, 3162, 3162,
        3163, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3225, 0, 0, 0, 0, 0, 0, 0, 0, 3227, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3289, 3290, 3290, 3290, 3290, 3290, 3290,
        3290, 3290, 3291, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];

    /// The GID that maps to the first tile in classic decor data set
    int classic_decor_first_gid = 8193;

    /// Classic decor layer data for tile map
    int[] classicDecorLayerData = [
        0, 0, 8325, 8326, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 8349, 8350, 0, 0, 8275, 8275, 8275, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8276, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8325, 8326, 0, 0, 8299, 8299, 8299, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8300, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8349, 8350, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8327, 8328, 8329, 0, 0, 0, 0,
        0, 0, 8373, 8374, 0, 0, 0, 0, 0, 0, 0, 8224, 0, 0, 0, 0, 0, 0, 8224, 0, 0,
        0, 0, 8351, 8352, 8353, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 8291, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8375, 8376, 8377, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 8291, 8292, 8291, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 8271, 8271, 8271, 0,
        0, 0, 0, 0, 0, 0, 8291, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8295, 8295, 8295, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 8291, 8224, 8291, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8291, 8224, 8291, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 8291, 8224, 8291, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8291, 8224, 8291, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 8276, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8201,
        8202, 8203, 0, 0, 8300, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8225,
        8226, 8227, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8224, 0, 0, 0, 0, 0, 0, 8224, 0, 0, 0,
        8249, 8250, 8251, 0, 0, 0, 0, 0,
        0, 8276, 8276, 0, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 8300, 8300, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8275, 0, 0, 8211, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8299, 0, 0, 8231, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0
    ];

    /// The GID that maps to the first tile in modern decor data set
    int modern_decor_first_gid = 8577;

    /// Modern decor layer data for tile map
    int[] modernDecorLayerData = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 8674, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 8690, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8646, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8646, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8674, 0,
        0, 0, 0, 0, 0, 0,
        0, 8674, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8690,
        0, 0, 0, 0, 0, 0, 0,
        0, 8690, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8674, 0, 0, 0, 0, 8674, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8690, 0, 0, 0, 0, 8690, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8674, 0, 0, 0, 0, 8674, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8690, 0, 0, 0, 0, 8690, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 8580, 8581, 8580, 8581, 8580, 8581, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8596, 8597, 8596, 8597, 8596, 8597, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8612, 8613, 8612, 8613, 8612, 8613, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8646, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 8626, 8627, 8628, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8646, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 8626, 8627, 8628, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0
    ];

    /// The GID that maps to the first tile in turntable data set
    int turntable_first_gid = 8737;

    /// Turntable layer data for tile map
    int[] turntableLayerData = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8769, 8770, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8777, 8778, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 8769, 8770, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8769, 8770, 0,
        0, 8777, 8778, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8777, 8778, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8769, 8770, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8777, 8778, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];

    /// The tile set used for rendering tiles
    TileSet mTileSet;

    /// Static array to store tile values
    int[mMapXSize][mMapYSize][5] mTiles;

    /**
     * Constructor to initialize a drawable tile map object.
     * Params:
     *      t = The tile set used for rendering the map.
     */
    this(TileSet t)
    {
        // Set our tilemap
        mTileSet = t;

        int index = 0;

        for (int y = 0; y < mMapYSize; y++)
        {
            for (int x = 0; x < mMapXSize; x++)
            {

                // Base Layer: Floor
                // Tile Asset Source: floors
                // Set all tiles to a default tile
                mTiles[0][x][y] = floorLayerData[index] - floor_first_gid;

                // Second Layer: Wall
                // Tile Asset Source: walls
                // Set each tile based on the local tile id in data set and the first gid of the data set.
                // Note that a local tile id of 0 is used to indicate the abscence of a tile.
                mTiles[1][x][y] = wallLayerData[index] - wall_first_gid;

                // Third Layer: Classic Decor
                // Tile Asset Source: city_inside
                mTiles[2][x][y] = classicDecorLayerData[index] - classic_decor_first_gid;

                // Fourth Layer: Modern Decor
                // Tile Asset Source: inside
                mTiles[3][x][y] = modernDecorLayerData[index] - modern_decor_first_gid;

                // Fifth Layer: Turntable
                // Tile Asset Source: turntables
                mTiles[4][x][y] = turntableLayerData[index] - turntable_first_gid;

                index++;

            }
        }
    }

    /** 
     * Renders each layer of the tile map using the renderer.
     * Params:
     *      renderer = The SDL renderer used for rendering.
     *      layer = A layer of the tile map.
     *      zoomFactor = The zoom factor for rendering (default = 1).
     *      playerX = X-coordinate of the player's position.
     *      playerY = Y-coordinate of the player's position.
     * Returns:
     *      None  
     */
    void Render(SDL_Renderer* renderer, int[mMapXSize][mMapYSize] layer, int zoomFactor = 1, int playerX, int playerY)
    {
        int xOffset = 9 - playerX;
        int yOffset = 7 - playerY;
        for (int y = 0; y < mMapYSize; y++)
        {
            for (int x = 0; x < mMapXSize; x++)
            {
                // Scrolling: render the tile found at global position x, y in the layer TO the screen at location x + offsetX
                mTileSet.RenderTile(renderer, layer[x][y], x + xOffset, y + yOffset, zoomFactor);
            }
        }
    }

    /**
     * Helper function to print 2D array for a layer. Change the input to print 2D array for different layers.
     * $(LIST
     *      * -2049 indicates the absence of a tile in wall layer
     *      * -8193 indicates the absence of a tile in classic decor layer
     *      * -8577 indicates the absence of a tile in modern decor layer
     *      * -8737 indicates the absence of a tile in turntable layer
     * )
     * Params:
     *      layer = The layer to print.
     * Returns:
     *      None
     */
    void PrintLayer(int[mMapXSize][mMapYSize] layer)
    {
        writeln();
        writeln("Print selected layer: ");
        writeln();
        writeln(layer);
    }

    /**
     * Retrieves the tile value at a specified position in a given layer.
     * Params:
     *      layer = The layer to retrieve the tile from.
     *      xTile = The X global coordinate of the tile.
     *      yTile = The Y global coordinate of the tile.
     * Returns:
     *      The tile value at the specified position.
     */
    int GetTileAt(int layer, int xTile, int yTile)
    {
        // int x = localX / (mTileSet.mTileSize * zoomFactor);
        // int y = localY / (mTileSet.mTileSize * zoomFactor);
        int x = xTile;
        int y = yTile;

        if (x < 0 || y < 0 || x > mMapXSize - 1 || y > mMapYSize - 1)
        {
            // TODO: Perhaps log error?
            // Maybe throw an exception -- think if this is possible!
            // You decide the proper mechanism!
            return -1;
        }

        return mTiles[layer][x][y];
    }

    /** 
     * Getter for getting the first GID of the floor layer.
     * Returns:
     *      The first GID of the floor layer.
     */
    int GetFloorLayerFirstGid() {
        return this.floor_first_gid;
    }

    /** 
     * Getter for getting the first GID of the wall layer.
     * Returns:
     *      The first GID of the wall layer.
     */
    int GetWallLayerFirstGid() {
        return this.wall_first_gid;
    }

    /** 
     * Getter for getting the first GID of the classic decor layer.
     * Returns:
     *      The first GID of the classic decor layer.
     */
    int GetClassicLayerFirstGid() {
        return this.classic_decor_first_gid;
    }

    /** 
     * Getter for getting the first GID of the modern decor layer.
     * Returns:
     *      The first GID of the modern decor layer.
     */
    int GetModernLayerFirstGid() {
        return this.modern_decor_first_gid;
    }

    /** 
     * Getter for getting the first GID of the turntable layer.
     * Returns:
     *      The first GID of the turntable layer.
     */
    int GetTurntableLayerFirstGid() {
        return this.turntable_first_gid;
    }
}


/********
 * This struct defines a tile set in the game. 
 * It is responsible for loading and rendering tiles.
 */
struct TileSet
{

    /// Rectangle storing a specific tile at an index
    SDL_Rect[] mRectTiles;
    /// The full texture loaded onto the GPU of the entire tile map.
    SDL_Texture* mTexture;
    /// Tile dimensions (assumed to be square)
    int mTileSize;
    /// Number of tiles in the tilemap in the x-dimension
    int mXTiles;
    /// Number of tiles in the tilemap in the y-dimension
    int mYTiles;

    /**
     * Constructor for initializing the tile set.
     * Params:
     *      renderer = The renderer used for rendering.
     *      filepath = The file path of the tile set.
     *      tileSize = The size of each tile.
     *      xTiles = The number of tiles in the X-dimension.
     *      yTiles = The number of tiles in the Y-dimension.
     */
    this(SDL_Renderer* renderer, string filepath, int tileSize, int xTiles, int yTiles)
    {
        mTileSize = tileSize;
        mXTiles = xTiles;
        mYTiles = yTiles;

        // Load the bitmap surface
        SDL_Surface* surface = SDL_LoadBMP(filepath.ptr);
        // Create a texture from the surface
        mTexture = SDL_CreateTextureFromSurface(renderer, surface);
        // Done with the bitmap surface pixels after we create the texture, we have
        // effectively updated memory to GPU texture.
        SDL_FreeSurface(surface);

        // Populate a series of rectangles with individual tiles
        for (int y = 0; y < yTiles; y++)
        {
            for (int x = 0; x < xTiles; x++)
            {
                SDL_Rect rect;
                rect.x = x * tileSize;
                rect.y = y * tileSize;
                rect.w = tileSize;
                rect.h = tileSize;

                mRectTiles ~= rect;
            }
        }
    }

    /**
     * Helper function to display all tiles in an animation sequence for previewing.
     * Params:
     *      renderer = The renderer used for rendering.
     *      x = The X-coordinate of the tile.
     *      y = The Y-coordinate of the tile.
     *      zoomFactor = The zoom factor for rendering (default = 1).
     * Returns:
     *      None
     */
    void ViewTiles(SDL_Renderer* renderer, int x, int y, int zoomFactor = 1)
    {
        import std.stdio;

        static int tilenum = 0;

        if (tilenum > mRectTiles.length - 1)
        {
            tilenum = 0;
        }

        // Just a little helper for you to debug
        // You can omit this as necessary
        writeln("Showing tile number: ", tilenum);

        // Select a specific tile from our
        // tiemap texture, by offsetting correcting
        // into the tilemap
        SDL_Rect selection;
        selection = mRectTiles[tilenum];

        // Draw a preview of the actual tile
        SDL_Rect rect;
        rect.x = x;
        rect.y = y;
        rect.w = mTileSize * zoomFactor;
        rect.h = mTileSize * zoomFactor;

        SDL_RenderCopy(renderer, mTexture, &selection, &rect);
        tilenum++;
    }

    /**
     * Helper function to determine the tile that the mouse cursor is over.
     * Params:
     *      renderer = The renderer used for rendering.
     *      tile = The tile to render.
     *      x = The X-coordinate for rendering.
     *      y = The Y-coordinate for rendering.
     * Returns:
     *      None
     */
    void TileSetSelector(SDL_Renderer* renderer)
    {
        import std.stdio;

        int mouseX, mouseY;
        int mask = SDL_GetMouseState(&mouseX, &mouseY);

        int xTileSelected = mouseX / mTileSize;
        int yTileSelected = mouseY / mTileSize;
        int tilenum = yTileSelected * mXTiles + xTileSelected;
        if (tilenum > mRectTiles.length - 1)
        {
            return;
        }

        writeln("mouse  : ", mouseX, ",", mouseY);
        writeln("tile   : ", xTileSelected, ",", yTileSelected);
        writeln("tilenum: ", tilenum);

        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        // Tile to draw out on
        SDL_Rect rect = mRectTiles[tilenum];

        // Copy tile to our renderer
        // Note: We need a rectangle that's the exact dimensions of the
        //       image in order for it to render appropriately.
        SDL_Rect tilemap;
        tilemap.x = 0;
        tilemap.y = 0;
        tilemap.w = mXTiles * mTileSize;
        tilemap.h = mYTiles * mTileSize;
        SDL_RenderCopy(renderer, mTexture, null, &tilemap);
        // Draw a rectangle
        SDL_RenderDrawRect(renderer, &rect);

    }

    /**
     * Draw a specific tile for the tile map.
     * Params:
     *      renderer = the linked SDL renderer that displays the tile on the screen
     *      tile = Tile type to render, based on value of the tile
     *      x = x coord on the screen (renderer) to render the tile
     *      y = y coord on the screen (renderer) to render the tile
     *      zoomFactor = the zoom factor of the tile (default = 1)
     * Returns:
     *      None
     */
    void RenderTile(SDL_Renderer* renderer, int tile, int x, int y, int zoomFactor = 1)
    {
        if (tile > mRectTiles.length - 1)
        {
            // NOTE: Could use 'logger' here to log an error
            return;
        }

        // Select a specific tile from our
        // tiemap texture, by offsetting correcting
        // into the tilemap
        SDL_Rect selection = mRectTiles[tile];

        // Tile to draw out on
        SDL_Rect rect;
        rect.x = mTileSize * x * zoomFactor;
        rect.y = mTileSize * y * zoomFactor;
        rect.w = mTileSize * zoomFactor;
        rect.h = mTileSize * zoomFactor;

        // Copy tile to our renderer
        SDL_RenderCopy(renderer, mTexture, &selection, &rect);
    }
}
