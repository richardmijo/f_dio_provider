// lib/main.dart

import 'package:f_dio_provider/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'services/post_api_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inyectamos el PostProvider en la app
        ChangeNotifierProvider(
          create: (_) => PostProvider(PostApiService())..loadPosts(),
        ),
      ],
      child: MaterialApp(
        title: 'Dio CRUD Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
        ),
        //home: const PostListScreen(),
      ),
    );
  }
}
