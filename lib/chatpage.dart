import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/consts.dart';
import 'package:flutter/material.dart';

class AgoraChatPage extends StatefulWidget {
  const AgoraChatPage({
    super.key,
    required this.chatKey,
    required this.userId,
    required this.agoraToken,
    required this.receiverId,
  });
  final String chatKey;
  final String userId;
  final String agoraToken;
  final String receiverId;

  @override
  State<AgoraChatPage> createState() => _AgoraChatPageState();
}

class DemoMessage {
  final String? text;
  final String? senderId;

  DemoMessage({required this.text, required this.senderId});
}

class _AgoraChatPageState extends State<AgoraChatPage> {
  ScrollController scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _logText = [];
  final List<DemoMessage> _messages = [];

  final openAI = OpenAI.instance.build(
      token: openAIToken,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)),
      isLog: true);
  var _isWaitingResponse = false;

  void _onTapSendHappyMessage() async {
    _reset();
    _sendAIMessage(
      "Give me a happy response to the message: ${_messages.last.text}",
    ).then((value) {
      setState(() {
        _isWaitingResponse = false;
        _messageController.text = value.trim();
      });
    });
  }

  void _onTapSendAngryMessage() async {
    _reset();
    _sendAIMessage(
      "Give me an angry response to the message: ${_messages.last.text}",
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
      model: Model.kTextDavinci3,
      maxTokens: 200,
    );

    final response = await openAI.onCompletion(
      request: request,
    );
    return response!.choices.first.text;
  }

  void _signIn() async {
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        widget.userId,
        widget.agoraToken,
      );
      _addLogToConsole("login succeed, userId: ${widget.userId}");
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _sendMessage(String sentTo, String? message) async {
    if (message == null) {
      _addLogToConsole("single chat id or message content is null");
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
            _addLogToConsole(
                "send message succeed: ${(msg.body as ChatTextMessageBody).content}");
            _addMessage(
              DemoMessage(
                  text: (msg.body as ChatTextMessageBody).content,
                  senderId: widget.userId),
            );
          },
          onProgress: (msgId, progress) {
            _addLogToConsole("send message succeed");
          },
          onError: (msgId, msg, error) {
            _addLogToConsole(
              "send message failed, code: ${error.code}, desc: ${error.description}",
            );
          },
        ));

    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
            _addMessage(
              DemoMessage(text: body.content, senderId: msg.from),
            );
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole(
              "receive video message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole(
              "receive location message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole(
              "receive voice message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole(
              "receive custom message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CMD:
          {}
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

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
    _signIn();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ChatClient.getInstance.chatManager
            .removeMessageEvent("UNIQUE_HANDLER_ID");
        ChatClient.getInstance.chatManager
            .removeEventHandler("UNIQUE_HANDLER_ID");
        _signOut();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverId),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: ListView.builder(
                  controller: scrollController,
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
                  },
                  itemCount: _messages.length,
                ),
              ),
              if (_isWaitingResponse)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _onTapSendHappyMessage(),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue[300]),
                        ),
                        child: const Text("   HAPPY AI   "),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _onTapSendAngryMessage(),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red[300]),
                        ),
                        child: const Text("   ANGRY AI   "),
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Enter message",
                        border: InputBorder.none,
                      ),
                      maxLines: 2,
                      controller: _messageController,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => _sendMessage(
                          widget.receiverId, _messageController.text),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.lightBlue),
                      ),
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
