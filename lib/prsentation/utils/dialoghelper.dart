

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/color.dart';

class DialogHelper {
  /// Common button style for Cancel/Confirm actions
  static ButtonStyle _buttonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  /// Show a confirmation dialog (e.g., for delete actions)
  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: tdPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: tdTextSecondary,
              fontSize: 16,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: _buttonStyle(
                backgroundColor: tdBGColor,
                foregroundColor: tdTextPrimary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              style: _buttonStyle(
                backgroundColor: tdPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  /// Show an input dialog (e.g., for renaming or adding items)
  static Future<void> showInputDialog({
    required BuildContext context,
    required String title,
    required String hintText,
    required String initialValue,
    required ValueChanged<String> onConfirm,
  }) async {
    final TextEditingController _controller =
    TextEditingController(text: initialValue);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: tdPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: hintText,
              labelText: hintText,
              labelStyle: const TextStyle(color: tdSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: tdBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: tdPrimaryColor),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: _buttonStyle(
                backgroundColor: tdBGColor,
                foregroundColor: tdTextPrimary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = _controller.text.trim();
                if (input.isNotEmpty) {
                  onConfirm(input);
                  Navigator.pop(context);
                }
              },
              style: _buttonStyle(
                backgroundColor: tdPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
