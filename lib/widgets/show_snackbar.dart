import 'package:flutter/material.dart';
import 'package:onex/global/theme_color.dart';

showSnackbar(BuildContext context, String contentText) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      backgroundColor: ThemeColor.primary,
      content: Text(
        contentText,
        style: TextStyle(color: ThemeColor.white),
      ),
    ),
  );
}
