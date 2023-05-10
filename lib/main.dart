import 'package:flutter/material.dart';

import 'chatpage.dart';
import 'consts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AgoraChatPage(
                  userId: AgoraChatConfig.userId,
                  agoraToken: AgoraChatConfig.agoraToken,
                  chatKey: AgoraChatConfig.appKey,
                  receiverId: AgoraChatConfig.userId2,
                ),
              )),
              child: const Text("Login as ${AgoraChatConfig.userId}"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AgoraChatPage(
                  userId: AgoraChatConfig.userId2,
                  agoraToken: AgoraChatConfig.agoraToken2,
                  chatKey: AgoraChatConfig.appKey,
                  receiverId: AgoraChatConfig.userId,
                ),
              )),
              child: const Text("Login as ${AgoraChatConfig.userId2}"),
            ),
          ],
        ),
      ),
    );
  }
}
