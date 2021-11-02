import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Helpers {
  Widget titleText() {
    return Text(
      "Universal Payment".toUpperCase(),
      style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 2.5,
          decorationStyle: TextDecorationStyle.dashed),
    );
  }

  Widget sizedBox(double height, double width) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  snackBar(GlobalKey<ScaffoldState> key, bool isSuccess, String content) {
    key.currentState!.showSnackBar(
      SnackBar(
        content: Text(content),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}
