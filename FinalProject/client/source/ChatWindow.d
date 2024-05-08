/// Represents a chat window within the game.
module chatwindow;
import chatclient : ChatClient;
import gtk.Main;
import gtk.MainWindow;
import gtk.Box;
import gtk.Entry;
import gtk.Button;
import gtk.ScrolledWindow;
import gtk.TextBuffer;
import gtk.TextIter;
import gtk.TextView;
import gtk.TextTag;
import gtk.TextTagTable;
import gtk.HeaderBar;
import gtk.Widget;
import gtk.Image;
import core.sync.mutex;
import core.thread;
import std.stdio;
import std.string;

/** 
 * This class represents the group chat window.
 */
class ChatWindow : MainWindow
{

    ChatClient chatClient;  /// Represents the chat client handling communication.
    Box mainBox;    /// Container holding chat elements like the message display and input field.
    ScrolledWindow chatScrollWindow;    /// Provides scrolling functionality for the chat display.
    TextView chatTextView;  /// Widget displaying the chat conversation.
    Entry messageEntry;   /// Input field for typing and sending messages.
    Button sendButton;  /// Button triggering the sending of messages.
    HeaderBar headerBar;    /// Top bar displaying chat window information.
    TextTag myMessageTag;   /// Text tag for messages sent by the player.
    TextTag otherMessageTag;    /// Text tag for messages sent by other users.
    Mutex mutex;    /// Mutex for managing thread safety.
    string username;    /// A unique identifier of the player.

    /** 
     * Constructor to initialize a chat window.
     * Params:
     *      username = A unique identifier of the player.
     *      serverIp = Ip address that runs the server.
     */
    this(string username, string serverIp)
    {
        super("");
        this.username = username;
        setTitle("Chat");
        setDefaultSize(350, 32 * 15);

        // Main vertical box
        mainBox = new Box(Orientation.VERTICAL, 0);
        add(mainBox);

        // Scrolled window for chat text view
        chatScrollWindow = new ScrolledWindow(null, null);
        mainBox.packStart(chatScrollWindow, true, true, 0);

        // Text view for chat messages
        chatTextView = new TextView();
        chatTextView.setEditable(false);
        // chatTextView.setWrapMode(TextWrapMode.WORD_CHAR);
        chatScrollWindow.add(chatTextView);

        // Text tags for different message styles
        TextTagTable tagTable = new TextTagTable();
        myMessageTag = new TextTag("myMessage");
        otherMessageTag = new TextTag("otherMessage");
        tagTable.add(myMessageTag);
        tagTable.add(otherMessageTag);

        TextBuffer buffer = new TextBuffer(tagTable);
        chatTextView.setBuffer(buffer);

        messageEntry = new Entry();
        mainBox.packStart(messageEntry, false, false, 0);

        // Send button with icon
        sendButton = new Button("_Send");
        // sendButton.setImage(new Image("document-send-symbolic"));
        mainBox.packStart(sendButton, false, false, 0);

        // Initialize mutex
        mutex = new Mutex();

        // Initialize chat client
        chatClient = new ChatClient(username, &onMessageReceived, serverIp);
        chatClient.start();

        messageEntry.addOnActivate(delegate void(Entry e) { handleMessage(); });

        sendButton.addOnClicked(delegate void(Button b) { handleMessage(); });

        // Connect the delete event to the main loop quit function
        addOnDestroy(delegate void(Widget w) { quitApp(); });

        showAll();
    }

    /** 
     * Closes the socket connection and the gtk window.
     */
    void quitApp()
    {
        writeln("Terminating chat window");
        chatClient.stop();
        destroy();
        Main.quit();
    }

    /** 
     * Handles the message typed by the user
     */
    void handleMessage()
    {
        string message = messageEntry.getText();
        chatClient.sendMessage(message);
        displayMessage(username ~ ": " ~ message, "left");
        messageEntry.setText("");
    }

    /** 
     * Handles the message received from other players
     * Params:
     *      message = message from other players
     * Returns:
     *      None
     */
    void onMessageReceived(string message)
    {
        mutex.lock();
        if (message.indexOf(":") != -1)
        {
            displayMessage(message, "right");
        }
        else
        {
            displayMessage(message, "center");
        }
        mutex.unlock();
    }

    /** 
     * Displays the message in the chat window
     * Params:
     *      message = message to be displayed
     *      alignment = right if own message, left if other's message
     * Returns:
     *      None
     */
    void displayMessage(string message, string alignment)
    {
        TextBuffer buffer = chatTextView.getBuffer();
        TextIter iter;
        buffer.getEndIter(iter);
        int numSpaces = calculateSpaces(message, alignment);

        // Add spaces for alignment
        if (numSpaces > 0)
        {
            char[] spaces = new char[numSpaces];
            spaces[] = ' ';
            message = spaces.idup ~ message;
        }

        buffer.insert(iter, message ~ "\n");
    }

    /** 
     * Helper to calculate spaces to make alignment work
     * Params:
     *      message = message to be displayed
     *      alignment = right or left
     * Returns: 
     *      num of spaces
     */
    int calculateSpaces(string message, string alignment)
    {
        int totalWidth = 80;
        int messageWidth = cast(int) message.length;
        int numSpaces = totalWidth - messageWidth;

        switch (alignment)
        {
        case "right":
            return 0;
        case "center":
            return numSpaces / 2;
        case "left":
        default:
            return numSpaces;
        }
    }
}
