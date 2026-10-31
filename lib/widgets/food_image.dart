import 'package:flutter/material.dart';
import '../common.dart';

/// Shows a food photo from its URL.
/// Falls back to a food icon when the URL is empty, still loading, or broken,
/// so the menu never shows a red error box.
class FoodImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double iconSize;

  const FoodImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.iconSize = 32,
  });

  Widget _placeholder({Widget? child}) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: skyBlue,
      child: child ?? Icon(Icons.fastfood, color: oceanBlue, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final link = url.trim();
    if (link.isEmpty) return _placeholder();

    return Image.network(
      link,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: blue),
          ),
        );
      },
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }
}
