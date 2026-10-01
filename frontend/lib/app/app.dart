import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../screens/login/login_screen.dart';

class DispatchIQApp extends StatelessWidget {
  const DispatchIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DispatchIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
