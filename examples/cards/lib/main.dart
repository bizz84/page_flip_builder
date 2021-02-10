import 'package:flutter/material.dart';
import 'package:page_flip_builder/page_flip_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final cardFlipKey1 = GlobalKey<PageFlipBuilderState>();
  final cardFlipKey2 = GlobalKey<PageFlipBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: LayoutBuilder(builder: (_, constraints) {
          final cardHeight = constraints.maxWidth / 1.333;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Note: putting a PageFlipBuilder inside a Column would cause an unbounded height.
              // So we use a LayoutBuilder and a SizedBox to "force" a fixed height
              SizedBox(
                height: cardHeight,
                child: PageFlipBuilder(
                  key: cardFlipKey1,
                  frontBuilder: (_) => FlutterCard(
                    backgroundColor: Colors.amber.shade200,
                    onFlip: cardFlipKey1.currentState?.flip,
                  ),
                  backBuilder: (_) => FlutterCard(
                    backgroundColor: Colors.yellow.shade200,
                    onFlip: cardFlipKey1.currentState?.flip,
                  ),
                  flipAxis: Axis.horizontal,
                  maxTilt: 0.003,
                  maxScale: 0.2,
                ),
              ),
              SizedBox(
                height: cardHeight,
                child: PageFlipBuilder(
                  key: cardFlipKey2,
                  frontBuilder: (_) => FlutterCard(
                    backgroundColor: Colors.amber.shade200,
                    onFlip: cardFlipKey2.currentState?.flip,
                  ),
                  backBuilder: (_) => FlutterCard(
                    backgroundColor: Colors.yellow.shade200,
                    onFlip: cardFlipKey2.currentState?.flip,
                  ),
                  flipAxis: Axis.vertical,
                  maxTilt: 0.003,
                  maxScale: 0.2,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class FlutterCard extends StatelessWidget {
  const FlutterCard({Key? key, required this.backgroundColor, this.onFlip})
      : super(key: key);
  final Color backgroundColor;
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFlip,
      child: Card(
          elevation: 5,
          color: backgroundColor,
          child: const Center(
            child: FlutterLogo(size: 128.0),
          )),
    );
  }
}
