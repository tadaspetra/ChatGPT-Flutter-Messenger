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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          centerTitle: true,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

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
            TextButton(
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
            const SizedBox(height: 20),
            TextButton(
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
