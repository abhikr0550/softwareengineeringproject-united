/// Module for manipulating audio tracks
module music;

import std.stdio;
import std.string;
import std.conv;
import bindbc.sdl.mixer;

/** 
    Class representing an audio file that can be played using SDL2_mixer
*/
class Music
{
    Mix_Chunk* m_music; /// bitstream of the music, used to play the audio data
    int channel; /// audio channel that music will play on
    bool playing; /// indicates if Music object is playing or not
    bool muted; /// indicates if Music object is muted (vol 0) or not

    /**
        Loads music file as a Mix_Chunk object so that it can be played in a specified audio channel.
        We play in a channel using SDL_Mixer so we can play multiple tunes and control each one separately.
        Chunks are still able to be looped by setting the loop value to -1.
        Params:
            musicfilepath = filepath of the music file
            channel = audio channel to play the music on
    */
    this(string musicfilepath, int channel)
    {
        if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024) == -1)
        {
            writeln("Audio library not working: ", Mix_GetError());
        }

        // Load our music file
        writeln("opening ", musicfilepath);
        // convert musicFilePath string to char* input to load properly
        auto musicFilePathChars = musicfilepath.toStringz;

        m_music = Mix_LoadWAV(musicFilePathChars);
        // TODO: error handling, if song didn't load properly
        writeln("loaded: ", m_music);

        this.setChannel(channel);
        this.setPlaying(false);
    }

    /** 
        Frees the Music object from memory
    */
    ~this()
    {
        Mix_FreeChunk(m_music);
    }

    /** 
        Setter for audio channel value
        Params:
            channel = new audio channel value
        Returns:
            None
    */
    void setChannel(int channel)
    {
        this.channel = channel;
    }

    /** 
        Setter for playing status value
        Params:
            playing = new playing status of Music object
        Returns:
            None
    */
    void setPlaying(bool playing)
    {
        this.playing = playing;
    }

    /** 
        Getter for playing status value
        Returns: 
            the playing status of the Music object (true if track is playing, false otherwise)
    */
    bool isPlaying()
    {
        return this.playing;
    }

    /** 
        Setter for playing status value
        Params:
            muted = new muted status of Music object
        Returns:
            None
    */
    void setMuted(bool muted)
    {
        this.muted = muted;
    }

    /** 
        Getter for playing status value
        Returns: 
            the playing status of the Music object (true if track is playing, false otherwise)
    */
    bool isMuted()
    {
        return this.muted;
    }

    /** 
        Plays the audio file on the Music object's set audio channel
        Params:
            loops = number of times the music loops. 0 means 0 loops, -1 means plays forever.
        Returns:
            None
    */
    void playMusic(int loops)
    {
        if (m_music != null)
        {
            Mix_PlayChannel(channel, m_music, loops);
            setPlaying(true);
            // mute channel by default
            mute();
        }
    }

    /** 
        Pauses the audio file on the Music object's set audio channel.
        Uses SDL2_mixer Mix_Pause() method. An audio channel paused by Mix_Pause() can be resumed from the paused spot using Mix_Resume().
        Returns:
            None
    */
    void pauseMusic()
    {
        // Mix_PauseMusic();
        Mix_Pause(channel);
        // update status of sample playing
        setPlaying(false);
    }

    /** 
        Resumes playing an audio file on the Music object's set audio channel that was paused by pauseMusic(), from the same spot that the track was paused at.
        Returns:
            None
    */
    void resumeMusic()
    {
        Mix_Resume(channel);
        setPlaying(true);
    }

    // 
    /**
        Sets the volume of the audio channel.
        Params:
            volume = track volume, ranges from 0 (muted) to 128 (full volume)
        Returns:
            None
    */
    void setVolume(int volume)
    {
        Mix_VolumeChunk(this.m_music, volume);
    }

    /**
        Mutes the audio channel. Uses setVolume() under the hood.
        Returns:
            None
    */
    void mute()
    {
        this.setVolume(0);
        setMuted(true);
    }

    /**
        Unmutes the audio channel. Uses setVolume() under the hood.
        Returns:
            None
    */
    void unmute()
    {
        this.setVolume(128);
        setMuted(false);
    }
}

//Test case 1
@("Test music is muted after playing")
unittest {
    Music m = new Music("/assets/music/jazz_2/bill_evans.mp3", 1);
    m.playMusic(-1);

    assert(m.isMuted == true, "Music is not muted as expected");
}

//Test case 2
@("Test music is playing")
unittest {
    Music m = new Music("/assets/music/jazz_2/bill_evans.mp3", 1);
    m.playMusic(-1);
    
    assert(m.isPlaying == true, "Music is not playing as expected");
}

//Test case 3
@("Test music is paused")
unittest {
    Music m = new Music("/assets/music/jazz_2/bill_evans.mp3", 1);
    m.playMusic(-1);
    // pause music
    m.pauseMusic();
    assert(m.isPlaying == false, "Music is not paused as expected");
}