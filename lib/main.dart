import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BGTrackApp());
}

class BGTrackApp extends StatelessWidget {
  const BGTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: const HomePage(),
    );
  }
}