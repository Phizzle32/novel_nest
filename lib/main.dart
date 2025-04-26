import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:novel_nest/firebase_options.dart';
import 'package:novel_nest/screens/login_screen.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ProxyProvider<FirestoreService, AuthService>(
          update: (_, firestoreService, __) => AuthService(firestoreService),
        ),
      ],
      child: NovelNest(),
    ),
  );
}

class NovelNest extends StatelessWidget {
  const NovelNest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novel Nest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F3324),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFE4DA),
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
