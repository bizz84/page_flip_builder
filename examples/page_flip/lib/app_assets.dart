import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  static const profileIcon = 'assets/man.svg';
  static const forestDay = 'assets/forest-day.svg';
  static const forestNight = 'assets/forest-night.svg';

  static Future<void> precacheAll() async {
    final assets = [profileIcon, forestDay, forestNight];
    for (final asset in assets) {
      await precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoder, asset),
        null,
      );
    }
  }
}
