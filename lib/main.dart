import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_manager_app/pages/add_name_page.dart';
import 'package:money_manager_app/pages/add_transaction_page.dart';
import 'package:money_manager_app/pages/home_page.dart';
import 'package:money_manager_app/pages/splash_page.dart';
import 'package:money_manager_app/theme/color_schemes.dart';

// define global color scheme
late ColorScheme globalColor;
void main() async {
  globalColor = lightColorScheme;

  WidgetsFlutterBinding.ensureInitialized();

  // this is for transaction
  await Hive.initFlutter();
  await Hive.openBox('money');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData.from(colorScheme: lightColorScheme),
      routes: {
        '/add_transaction': (context) => const AddTransaction(),
        '/add_name': (context) => const AddNamePage(),
        '/home': (context) => const HomePage(),
      },
      home: const SplashPage(),
    );
  }
}
