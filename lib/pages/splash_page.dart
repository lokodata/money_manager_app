import 'package:flutter/material.dart';
import 'package:money_manager_app/controllers/db_helper.dart/db_helper.dart';
import 'package:money_manager_app/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  //
  DbHelper dbHelper = DbHelper();

  Future getSettings() async {
    String? name = await dbHelper.getName();

    if (mounted) {
      if (name != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/add_name');
      }
    }
  }

  // override initState
  @override
  void initState() {
    super.initState();

    // wait for 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      getSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo_v2.png'),
              height: 300,
            ),

            //
            Text(
              'Pera Natin',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: globalColor.primary,
                  fontFamily: 'Georgia'),
            ),

            //
            const SizedBox(
              height: 50,
            ),

            //
            Text(
              'Welcome to your money manager.\nWhere nothing is personal. Your money is our money.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: globalColor.onSecondaryContainer,
              ),
            ),

            //
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
