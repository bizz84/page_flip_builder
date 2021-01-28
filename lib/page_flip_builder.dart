import 'dart:math';

import 'package:flutter/material.dart';

class PageFlipBuilder extends StatefulWidget {
  const PageFlipBuilder({
    Key? key,
    required this.frontBuilder,
    required this.backBuilder,
    this.nonInteractiveAnimationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);
  final WidgetBuilder frontBuilder;
  final WidgetBuilder backBuilder;
  final Duration nonInteractiveAnimationDuration;

  @override
  _PageFlipBuilderState createState() => _PageFlipBuilderState();
}

abstract class PageFlipCommandState extends State<PageFlipBuilder> {
  void flip();
}

class _PageFlipBuilderState extends PageFlipCommandState
    with SingleTickerProviderStateMixin {
  bool _showFrontSide = true;
  late final AnimationController _controller;

  double get _screenWidth => MediaQuery.of(context).size.width;

  /// Starts a page flip.
  ///
  /// Example:
  /// ```dart
  /// PageFlipBuilder(
  ///   key: pageFlipKey,
  ///   frontBuilder: (_) => Screen1(
  ///     onFlip: () => pageFlipKey.currentState?.flip(),
  ///   ),
  ///   backBuilder: (_) => Screen2(
  ///     onFlip: () => pageFlipKey.currentState?.flip(),
  ///   ),
  /// );
  /// ```
  @override
  void flip() {
    if (_showFrontSide) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value += details.primaryDelta! / _screenWidth;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.dismissed) return;

    const velocityThreshold = 1.0;
    final flingVelocity = details.velocity.pixelsPerSecond.dx / _screenWidth;

    // if value and velocity are 0, the gesture was a tap so we return early
    if (_controller.value == 0.0 && flingVelocity == 0.0) {
      return;
    }

    if (_controller.value > 0.5 ||
        _controller.value > 0.0 && flingVelocity > velocityThreshold) {
      _controller.fling(velocity: 1.0);
    } else if (_controller.value < -0.5 ||
        _controller.value < 0.0 && flingVelocity < -velocityThreshold) {
      _controller.fling(velocity: -1.0);
    } else if (_controller.value > 0.0 ||
        _controller.value > 0.5 && flingVelocity < -velocityThreshold) {
      // controller can't fling to 0.0 because the lowerBound is -1.0
      // so we decrement the value by 1.0 and toggle the state to get the same effect
      _controller.value -= 1.0;
      setState(() => _showFrontSide = !_showFrontSide);
      _controller.fling(velocity: -1.0);
    } else if (_controller.value > -0.5 ||
        _controller.value < -0.5 && flingVelocity > velocityThreshold) {
      // controller can't fling to 0.0 because the upperBound is 1.0
      // so we increment the value by 1.0 and toggle the state to get the same effect
      _controller.value += 1.0;
      setState(() => _showFrontSide = !_showFrontSide);
      _controller.fling(velocity: 1.0);
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.nonInteractiveAnimationDuration,
      // lowerBound of -1.0 is needed for the back flip
      lowerBound: -1.0,
      // upperBound of 1.0 is needed for the front flip
      upperBound: 1.0,
    );
    _controller.value = 0.0;
    _controller.addStatusListener(_updateStatus);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_updateStatus);
    _controller.dispose();
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      // The controller always completes a forward animation with value 1.0
      // and a reverse animation with a value of -1.0.
      // By resetting the value to 0.0 and toggling the state
      // we are preparing the controller for the next animation
      // while preserving the widget appearance on screen.
      _controller.value = 0.0;
      setState(() => _showFrontSide = !_showFrontSide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedPageFlipBuilder(
        animation: _controller,
        frontBuilder: widget.frontBuilder,
        backBuilder: widget.backBuilder,
        showFrontSide: _showFrontSide,
      ),
    );
  }
}

class AnimatedPageFlipBuilder extends StatelessWidget {
  const AnimatedPageFlipBuilder({
    Key? key,
    required this.animation,
    required this.showFrontSide,
    required this.frontBuilder,
    required this.backBuilder,
  }) : super(key: key);
  final Animation<double> animation;
  final bool showFrontSide;
  final WidgetBuilder frontBuilder;
  final WidgetBuilder backBuilder;

  bool get isRotationFirstHalf => animation.value.abs() < 0.5;

  double getTilt() {
    var tilt = (animation.value - 0.5).abs() - 0.5;
    if (animation.value < -0.5) {
      tilt = 1.0 + animation.value;
    }
    return tilt * (isRotationFirstHalf ? -0.003 : 0.003);
  }

  double rotationYAngle() {
    final rotationValue = animation.value * pi;
    if (animation.value > 0.5) {
      return pi - rotationValue; // input from 0.5 to 1.0
    } else if (animation.value > -0.5) {
      return rotationValue; // input from -0.5 to 0.5
    } else {
      return -pi - rotationValue; // input from -1.0 to -0.5
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final child = isRotationFirstHalf ^ showFrontSide
            ? backBuilder(context)
            : frontBuilder(context);
        return Transform(
          transform: Matrix4.rotationY(rotationYAngle())
            ..setEntry(3, 0, getTilt()),
          child: child,
          alignment: Alignment.center,
        );
      },
    );
  }
}
