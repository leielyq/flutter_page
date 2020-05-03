import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FluttieAnimationRootWidget extends StatefulWidget {
  final String path;
  FluttieAnimationRootWidgetState fluttieAnimationRootWidgetState;
  final bool autoPlay;

  FluttieAnimationRootWidget({Key key, this.path, this.autoPlay = false})
      : super(key: key);

  get getState {
    return fluttieAnimationRootWidgetState;
  }

  @override
  FluttieAnimationRootWidgetState createState() {
    fluttieAnimationRootWidgetState = FluttieAnimationRootWidgetState();
    return fluttieAnimationRootWidgetState;
  }
}

class FluttieAnimationRootWidgetState extends State<FluttieAnimationRootWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    prepareLottie();
  }

  AnimationController _controller;

  void prepareLottie() async {
    _controller = AnimationController(vsync: this);
  }

  start({bool isRepeat = true}) {
    setState(() {
      isRepeat ? _controller.repeat() : _controller.forward();
    });
  }

  stop() {
    setState(() {
      _controller.stop();
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.path,
      controller: _controller,
      onLoaded: (composition) {
        _controller..duration = composition.duration;
        if (widget.autoPlay) _controller.repeat();
      },
    );
  }
}
