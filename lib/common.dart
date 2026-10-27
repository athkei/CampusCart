import 'package:flutter/material.dart';

// ---- CampusCart color scheme ----
const Color blushPink = Color(0xFFFBD9E4);
const Color apricot = Color(0xFFF7B58B);
const Color persimmon = Color(0xFFCC4A27);
const Color skyBlue = Color(0xFFA8D0F7);
const Color oceanBlue = Color(0xFF3E70D8);
const Color warmWhite = Color(0xFFFFF9F5);
const Color textColor = Color(0xFF1F2A4D);

// Aliases used across the screens
const Color blue = oceanBlue; // primary: buttons, links, focus
const Color red = persimmon; // errors / destructive actions
const Color ink = textColor;
const Color grey = Color(0xFF6B7280);
const Color bg = warmWhite;

/// Soft-border field used in Login (label sits above the field)
InputDecoration softField(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9AA3B8)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: skyBlue),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: blue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: red, width: 1.5),
    ),
  );
}

/// Bold dark-outline field used in Register
InputDecoration boldField(String hint, {Widget? suffix}) {
  OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
    suffixIcon: suffix,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: b(ink, 2),
    focusedBorder: b(blue, 2),
    errorBorder: b(red, 2),
    focusedErrorBorder: b(red, 2),
  );
}

class AppButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class AuthBackdrop extends StatelessWidget {
  final Widget child;
  const AuthBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration:
                const BoxDecoration(color: blushPink, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -70,
          child: Container(
            width: 200,
            height: 200,
            decoration:
                const BoxDecoration(color: skyBlue, shape: BoxShape.circle),
          ),
        ),
        child,
      ],
    );
  }
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
