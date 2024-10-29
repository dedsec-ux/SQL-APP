import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'database_helper.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Push Notifications',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message received: ${message.notification!.title}');
        db.insertMessage(message.notification!.body!);
        _loadMessages();
      }
    });
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Map<String, dynamic>> msgs = await db.getMessages();
    setState(() {
      messages = msgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(messages[index]['content']));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseMessaging.instance.subscribeToTopic('test');
        },
        child: Icon(Icons.notifications),
      ),
    );
  }
}
