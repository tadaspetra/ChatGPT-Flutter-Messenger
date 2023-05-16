# ChatGPT Messenger

![ChatGPT Messenger](output.gif)

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
3. Run the application: `flutter run`

# How to retrieve `consts.dart` values
1. Create an account on [Agora.io](https://console.agora.io/)
2. Create a project
3. Scroll down to `Chat` and click `Enable/Configure` 
4. Click the toggle button and copy paste the AppKey.
5. On the left side under `Operation Management` select `User` and create 2 users. (Remember the User IDs)
6. Go back to `Application Information` under the `Basic Information` tab and enter the User IDs for each user in the `Chat User Temp Token` field, and click `Generate`. Bring the tokens and User IDs to the `consts.dart` file.

