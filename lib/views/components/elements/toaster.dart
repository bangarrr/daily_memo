import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Toaster {
  static void show(
      {required BuildContext context, required String message, Duration duration = const Duration(seconds: 3)}) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _OverlayWidget(overlayEntry: overlayEntry, message: message, duration: duration),
    );

    overlay.insert(overlayEntry);
  }
}

class _OverlayWidget extends StatefulWidget {
  OverlayEntry? overlayEntry;
  final String message;
  final Duration duration;

  _OverlayWidget({Key? key, this.overlayEntry, required this.message, required this.duration}) : super(key: key);

  @override
  State<_OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<_OverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    Future.delayed(widget.duration).then((_) {
      _animationController.reverse().then((_) {
        widget.overlayEntry?.remove();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 5),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
