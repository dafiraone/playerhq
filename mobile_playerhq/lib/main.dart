import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_playerhq/firebase_api.dart';
import 'package:mobile_playerhq/models/post.dart';
import 'package:mobile_playerhq/pages/login_page.dart';
import 'package:mobile_playerhq/pages/post/post_detail.dart';
import 'package:mobile_playerhq/pages/register_page.dart';
import 'package:mobile_playerhq/provider/post.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:mobile_playerhq/pages/home_page.dart';
import 'package:mobile_playerhq/pages/user/user_profile.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => const UserProfile(),
        '/postDetail': (context) => PostDetailPage(
            post: ModalRoute.of(context)!.settings.arguments as Post),
      },
      home: LoginPage(),
    );
  }
}
