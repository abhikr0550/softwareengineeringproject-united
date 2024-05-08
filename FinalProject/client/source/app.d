/// Run with: 'dub'
import std.stdio;
import std.string;
import std.conv;

import std.concurrency : spawn;

import gtk.MainWindow;
import gtk.Main;
import gtk.Widget;
import gtk.Button;
import gdk.Event;
import core.thread;

// Load the SDL2 library
import bindbc.sdl;

import glib.Idle;
import gameclient : GameClient;
import chatwindow : ChatWindow;

/// Entry point to program
void main(string[] args)
{
    // Initialize GTK
    Main.init(args);
    write("Enter your username: ");
    string username = readln.strip;
    write("Enter server ip: ");
    string serverIp = readln.strip.chomp;
    ChatWindow chatWindow = new ChatWindow(username, serverIp);
    GameClient gameClient = new GameClient(username, chatWindow, serverIp);

    chatWindow.addOnDestroy(delegate void(Widget w) { gameClient.quitSDL(); });

    // Render the game sdl window.
    auto idle = new Idle(delegate bool() { return gameClient.runGameLoop(); });

    Main.run();
}
