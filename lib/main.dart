import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_shopping_list_app/providers/shopping_list_provider.dart';
import 'package:simple_shopping_list_app/screens/shopping_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShoppingListProvider(),
      child: MaterialApp(
        title: 'Shopping List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ShoppingListScreen(),
      ),
    );
  }
}