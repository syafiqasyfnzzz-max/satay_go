
import 'package:flutter/material.dart';
import 'package:satay_master_pro/screens/auth/login_screen.dart';

void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Login Required"),
        content: const Text(
          "Please login or sign up first to place your satay order 🍢",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Login / Sign Up"),
          ),
        ],
      );
    },
  );
}
