
# Page Flip Builder

[![Pub](https://img.shields.io/pub/v/page_flip_builder.svg)](https://pub.dev/packages/page_flip_builder)
[![Language](https://img.shields.io/badge/dart-2.12.0-informational.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](http://mit-license.org)
[![Twitter](https://img.shields.io/badge/twitter-@biz84-blue.svg)](http://twitter.com/biz84)

A custom Flutter widget that enables interactive page-flip transitions in your app.

You can use this to flip images, cards, or widgets of any size.

## Preview

![Page Flip screenshots](https://raw.githubusercontent.com/bizz84/page_flip_builder/main/.github/images/page-flip-transition.png)

![Card Flip screenshots](https://raw.githubusercontent.com/bizz84/page_flip_builder/main/.github/images/cards-flip-transition.png)

Also see the **[Flutter Web Live Preview](https://page-flip-demo.web.app/#/)**.

## Usage

> Note: This package uses **null-safety**.

`PageFlipBuilder` is best used for **full-screen** page-flip transitions, but works with widgets of any size _as long as their width and height is not unbounded_.

`PageFlipBuilder` uses a **drag gesture** to interactively transition between a "front" and a "back" widget. These are specified with the `frontBuilder` and `backBuilder` arguments:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        // add a black background to prevent flickering on Android when the page flips
        color: Colors.black,
        child: PageFlipBuilder(
          frontBuilder: (_) => LightHomePage(),
          backBuilder: (_) => DarkHomePage(),
        ),
      ),
    );
  }
}
```

By defalt the flip happens along the **vertical** axis, but you can change the `flipAxis` to `Axis.horizontal` if you want.

For more control, you can also add a `GlobalKey<PageFlipBuilderState>` and programmatically flip the page with a callback-based API:

```dart
class MyApp extends StatelessWidget {
  // used to flip the page programmatically
  final pageFlipKey = GlobalKey<PageFlipBuilderState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        // add a black background to prevent flickering on Android when the page flips
        color: Colors.black,
        child: PageFlipBuilder(
          key: pageFlipKey,
          frontBuilder: (_) => LightHomePage(
            onFlip: () => pageFlipKey.currentState?.flip(),
          ),
          backBuilder: (_) => DarkHomePage(
            onFlip: () => pageFlipKey.currentState?.flip(),
          ),
          // flip the axis to horizontal
          flipAxis: Axis.horizontal,
          // customize tilt value
          maxTilt: 0.003,
          // customize scale
          maxScale: 0.2,
        ),
      ),
    );
  }
}
```

## Features

- Interactive flip transition using drag gestures (forward and reverse)
- Fling animation to complete the transition on drag release
- Flip page programmatically via callbacks
- Flip around the horizontal or vertical axis
- Flip widgets of any size
- Customizable flip duration, tilt, scale

### [LICENSE: MIT](LICENSE)