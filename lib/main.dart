import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gymer/app/auth/loginconfirmation.dart';
import 'package:gymer/app/auth/register_page.dart';
import 'package:gymer/app/splash/splash_screen.dart';
import 'package:gymer/app/user/home/userhome_screen.dart';
import 'package:gymer/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gymer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/user': (context) => UserhomeScreen(),
        '/login': (context) => Login(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
