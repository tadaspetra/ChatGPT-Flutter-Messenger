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
  final List<DemoMessage> _messages = [];

  final openAI = OpenAI.instance.build(token: openAIToken);
  bool _isWaitingResponse = false;

  void _onTapSendHappyMessage() async {
    setState(() {
      _isWaitingResponse = true;
    });

    final List<DemoMessage> otherMessages = _messages
        .where((element) => element.senderId != widget.userId)
        .toList();

    String response = await _sendAIMessage(
      "Give me a happy response to the message: ${otherMessages.last.text}",
    );

    setState(() {
      _isWaitingResponse = false;
      _messageController.text = response.trim();
    });
  }

  void _onTapSendAngryMessage() async {
    setState(() {
      _isWaitingResponse = true;
    });

    final List<DemoMessage> otherMessages = _messages
        .where((element) => element.senderId != widget.userId)
        .toList();

    String response = await _sendAIMessage(
      "Give me an angry response to the message: ${otherMessages.last.text}",
    );
    setState(() {
      _isWaitingResponse = false;
      _messageController.text = response.trim();
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

  void _signOut() async {
    ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    try {
      await ChatClient.getInstance.logout(true);
      debugPrint("sign out succeed");
    } on ChatError catch (e) {
      debugPrint("sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

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

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: widget.chatKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
    _addChatListener();
    _signIn();
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

  @override
  void initState() {
    super.initState();
    _initSDK();
  }

  @override
  void dispose() {
    _signOut();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                },
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
                      foregroundColor: MaterialStateProperty.all(Colors.white),
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
    );
  }
}
