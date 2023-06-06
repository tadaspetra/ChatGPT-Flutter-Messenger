# ChatGPT Messenger

![ChatGPT Messenger](output.gif)

## How to run this
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

## How to retrieve Agora Chat information
1. Create an account on [Agora.io](https://console.agora.io/)
2. Create a project
3. Scroll down to `Chat` and click `Enable/Configure` 
4. Click the toggle button and copy paste the AppKey.
5. On the left side under `Operation Management` select `User` and create 2 users. (Remember the User IDs)
6. Go back to `Application Information` under the `Basic Information` tab and enter the User IDs for each user in the `Chat User Temp Token` field, and click `Generate`. Bring the tokens and User IDs to the `consts.dart` file.

## How to get an OpenAI token
1. Create an account on [OpenAI](https://platform.openai.com/)
2. Top right corner click on your image and select "View API Keys"
3. Create a new Secret Key and copy paste it into the `consts.dart` file.

## How ChatGPT Flutter Messenger works
The app is a simple demo integrating Agora Chat with ChatGPT. The app has 2 users, and each user can send messages to the other user. 

If the users are feeling a bit lazy they can just have ChatGPT generate the response for them. The response options are either a happy response or an angry response. Once a user clicks on either of those options a request is sent to OpenAI with the following prompt: "Give me an angry response to the message: " + the last message that was sent.

Once OpenAI responds with a message, that message is filled into the `TextField` and the user can choose to regenerate a message in a different tone, or they can send that message.