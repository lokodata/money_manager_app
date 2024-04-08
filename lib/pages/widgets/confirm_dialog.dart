import 'package:flutter/material.dart';
import 'package:money_manager_app/main.dart';

showConfirmDialog(BuildContext context, String title, String content) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: globalColor.error),
      ),
      content: Text(
        content,
        style: const TextStyle(fontFamily: "Georgia", fontSize: 15),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => globalColor.error,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text(
            "YES",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text(
            "No",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
