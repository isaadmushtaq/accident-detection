import 'package:accident_detection/screens/home_screen.dart';
import 'package:accident_detection/screens/login_screen.dart';
import 'package:accident_detection/screens/registration_screen.dart';
import 'package:accident_detection/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:accident_detection/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main () async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FlashChat());
}

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        RegistrationScreen.id : (context) => RegistrationScreen(),
        HomeScreen.id : (context) => HomeScreen(),
      },
    );
  }
}
