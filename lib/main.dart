import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Chronos works!', style: TextStyle(fontSize: 24)),
        ),
      ),
    ),
  );
}
