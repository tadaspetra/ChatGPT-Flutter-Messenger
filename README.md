# ChatGPT Messenger

# How to run this
1. In project directory run `flutter create .` to create the platform folders and other necessary files.
2. Create a `consts.dart` file with the following contents:
```dart
class AgoraChatConfig {
  static const String appKey = "Chat App Key";
  static const String userId = "Main User ID";
  static const String agoraToken = "Main User Token";
  static const String userId2 = "Second User ID";
  static const String agoraToken2 = "Second User Token";
}

String openAIToken = "Your Token";

```
3. `flutter run`
