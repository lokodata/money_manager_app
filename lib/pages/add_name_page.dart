import 'package:flutter/material.dart';
import 'package:money_manager_app/controllers/db_helper.dart/db_helper.dart';
import 'package:money_manager_app/main.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({super.key});

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  //
  DbHelper dbHelper = DbHelper();
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/images/logo_v1.png'),
                height: 100,
              ),
            ),

            //
            const SizedBox(
              height: 100,
            ),

            //
            Text(
              'What should we address you?',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: globalColor.onSecondaryContainer,
              ),
            ),

            //
            TextField(
              onChanged: (value) => name = value,
              style: TextStyle(
                fontSize: 25,
                color: globalColor.onSecondaryContainer,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Enter your name',
                labelStyle: TextStyle(
                  color: globalColor.primary,
                ),
                focusColor: globalColor.primary,
              ),
            ),

            //
            const SizedBox(
              height: 50,
            ),

            //
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                    side: MaterialStateProperty.all(
                        BorderSide(color: globalColor.primary))),
                onPressed: () async {
                  // check if name is empty or not if empty show error
                  if (name.isNotEmpty && mounted) {
                    // add name to shared preferences
                    await dbHelper.addName(name);

                    // navigate to home page
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    // show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: globalColor.error,
                        content: const Text('Name cannot be empty'),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: globalColor.primary,
                          fontFamily: 'Georgia'),
                    ),

                    //
                    const SizedBox(
                      width: 12,
                    ),

                    //
                    Icon(
                      Icons.arrow_forward,
                      color: globalColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
