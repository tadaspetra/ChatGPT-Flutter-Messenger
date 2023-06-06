# ChatGPT Flutter Messenger

In this day and age, it's so time consuming keeping up with friends. Before social media and messaging apps came out you actually had to spend time with people in real life. Although it has gotten a bit better now that you can just message them, it is still a pain having to think of what to say and interact with them. 

Now there is a solution! You no longer need to think, you can just have an AI chat with your friends!

Of course this is just a joke, you should definitely still hang out with friends and not outsource your relationships to AI, but this is still a cool use-case, that can be used for replies to bots, or maybe even to help you keep the conversation going when it get's a bit stale. 

In this article we will cover how you can build your own chat application using [Agora Chat](https://docs.agora.io/en/agora-chat/overview/product-overview?platform=flutter) and then making it even fancier by adding ChatGPT.

You can find the [full code here](https://github.com/tadaspetra/ChatGPT-Flutter-Messenger)

## Agora Chat
Agora Chat enables you communicate with your friends via chat. This includes text, images, gifs, emojis and other media. This can be used as a standalone chat application, or it can be integrated into your existing applications that use RTC (Real Time Communication) such as video calling.

## ChatGPT
ChatGPT is OpenAI's AI model that can generate very realistic responses to messages. We will be using their API to send requests to the model and get responses that we will insert into our chat. 

## Setup
To interact with these services, we will need to create accounts on both Agora and OpenAI and retrieve some tokens.

### How to retrieve Agora Chat information
1. Create an account on [Agora.io](https://console.agora.io/)
2. Create a project
3. Scroll down to `Chat` and click `Enable/Configure` 
4. Click the toggle button and copy paste the AppKey.
5. On the left side under `Operation Management` select `User` and create 2 users. (Remember the User IDs)
6. Go back to `Application Information` under the `Basic Information` tab and enter the User IDs for each user in the `Chat User Temp Token` field, and click `Generate`. Bring the tokens and User IDs to a `consts.dart` file.

### How to get an OpenAI token
1. Create an account on [OpenAI](https://platform.openai.com/)
2. Top right corner click on your image and select "View API Keys"
3. Create a new Secret Key and copy paste it into the `consts.dart` file.

## Chat Page
We need to get to the chat page, with the current users ID and token and the user's ID who you want to message. There are multiple ways to do this, but for this example I just created two buttons where you can log in as each individual user. You can see more in the [`main.dart` file](https://github.com/tadaspetra/ChatGPT-Flutter-Messenger/blob/main/lib/main.dart).

As soon as we launch into the chat page there are three things that need to happen in order for our chat to be initialized. Since we haven't done any setup with the Agora Chat SDK, we need to initialize the SDK, then add a listener for messages, and finally log the current user in to have it fully ready to use. These 3 functions will need to be called in the `initState`

```dart
void _initSDK() async {
    ChatOptions options = ChatOptions(
        appKey: widget.chatKey,
        autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
}

void _addChatListener() {
    ChatClient.getInstance.chatManager.addMessageEvent(
        "UNIQUE_HANDLER_ID",
        ChatMessageEvent(
            onSuccess: (msgId, msg) {
            debugPrint(
                "send message succeed: ${(msg.body as ChatTextMessageBody).content}");
            _addMessage(
                DemoMessage(
                    text: (msg.body as ChatTextMessageBody).content,
                    senderId: widget.userId),
            );
            },
            onProgress: (msgId, progress) {
            debugPrint("send message succeed");
            },
            onError: (msgId, msg, error) {
            debugPrint(
                "send message failed, code: ${error.code}, desc: ${error.description}",
            );
            },
        ));

ChatClient.getInstance.chatManager.addEventHandler(
        "UNIQUE_HANDLER_ID",
        ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
}

void _signIn() async {
    try {
        await ChatClient.getInstance.loginWithAgoraToken(
        widget.userId,
        widget.agoraToken,
        );
        debugPrint("login succeed, userId: ${widget.userId}");
    } on ChatError catch (e) {
        debugPrint("login failed, code: ${e.code}, desc: ${e.description}");
    }
}
```

Since we have the sign in method here, let's also create our sign out method. This will be called in the `dispose` method.

```dart
void _signOut() async {
    ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    try {
        await ChatClient.getInstance.logout(true);
        debugPrint("sign out succeed");
    } on ChatError catch (e) {
        debugPrint(
        "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
}
```

You'll notice there are a couple functions called in the Chat Listener that aren't shown.
* `_addMessage` adds the incoming message to list of visible messages.
* `debugPrint` adds the incoming message to the console log.
* `onMessagesReceived` is a function that is called when a message is received. (We will also use `_addMessage` with there to keep a list from both parties)

Below are the definitions for those functions

```dart
void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
        switch (msg.body.type) {
        case MessageType.TXT:
            {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            debugPrint(
                "receive text message: ${body.content}, from: ${msg.from}",
            );
            _addMessage(
                DemoMessage(text: body.content, senderId: msg.from),
            );
            }
            break;
        default:
            break;
        }
    }
}

void _addMessage(DemoMessage message) {
    _messages.add(message);
    setState(() {
        scrollController.jumpTo(scrollController.position.maxScrollExtent + 40);
    });
}
```

## Show the Chat
This will be displayed in a `ListView.builder` that will display all the messages in the `_messages` list. You will also need to add a `TextField` at the bottom of the screen that will allow us to send messages. 

```dart
ListView.builder(
    controller: scrollController,
    itemCount: _messages.length,
    itemBuilder: (_, index) {
    //show first 10 characters
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SizedBox(height: 2),
        if (widget.userId != _messages[index].senderId)
            Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
                _messages[index].text!,
            ),
            )
        else
            Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Flexible(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                    color: Colors.lightGreen[100],
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                    _messages[index].text!,
                    ),
                ),
                ),
            ],
            ),
        ],
    );
},),
```

## Send a Message
To send a message we will need to call the `sendMessage` function from the Agora Chat SDK. This function takes in a `ChatMessage` object.  We will also need to pass in the user ID of the person we want to send the message to. 

```dart
void _sendMessage(String sentTo, String? message) async {
    if (message == null) {
        debugPrint("single chat id or message content is null");
        return;
    }

    var msg = ChatMessage.createTxtSendMessage(
        targetId: sentTo,
        content: message,
    );

    ChatClient.getInstance.chatManager.sendMessage(msg);

    setState(() {
        _messageController.text = "";
    });
}
```

This should be a fully functioning Agora Chat application. The last step is to integrate ChatGPT to allow for AI generated responses.

# ChatGPT
To use ChatGPT we need to connect to the API first. We will also declare a `isWaitingResponse` variable that will be used to disable the send button while we wait for a response from the API. 

Then once it is declared we can set up different functions to send either a happy or an angry response to the other users last message 

```dart
final openAI = OpenAI.instance.build(
    token: openAIToken,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)),
    isLog: true);
var _isWaitingResponse = false;

void _onTapSendHappyMessage() async {
    final List<DemoMessage> otherMessages = _messages
        .where((element) => element.senderId != widget.userId)
        .toList();
    _reset();
    _sendAIMessage(
        "Give me a happy response to the message: ${otherMessages.last.text}",
    ).then((value) {
        setState(() {
        _isWaitingResponse = false;
        _messageController.text = value.trim();
        });
    });
}

void _onTapSendAngryMessage() async {
    final List<DemoMessage> otherMessages = _messages
        .where((element) => element.senderId != widget.userId)
        .toList();
    _reset();
    _sendAIMessage(
        "Give me an angry response to the message: ${otherMessages.last.text}",
    ).then((value) {
        setState(() {
        _isWaitingResponse = false;
        _messageController.text = value.trim();
        });
    });
}

void _reset() {
    setState(() {
        _isWaitingResponse = true;
    });
}

Future<String> _sendAIMessage(String message) async {
    final request = CompleteText(
        prompt: message,
        model: Model.textDavinci3,
        maxTokens: 200,
    );

    final response = await openAI.onCompletion(
        request: request,
    );
    return response!.choices.first.text;
}
```

That's the full functionality of our application. You now can add buttons that generate those responses and put them into the `TextController.value` of the `TextField` to allow the user to send them. 

Thank you for reading, [click here to read and learn more about Agora.](https://docs.agora.io/en/)