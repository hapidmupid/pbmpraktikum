import 'dart:async';
import 'package:flutter/material.dart';

/// Menampilkan SnackBar dengan animasi progress bar yang mengecil selama durasi tertentu
Future<void> showProgressSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onDismissed,
}) async {
  final completer = Completer<void>();
  
  late final Timer timer;
  
  final snackBar = SnackBar(
    content: _ProgressSnackBarContent(
      message: message,
      duration: duration,
      onComplete: () {
        completer.complete();
        onDismissed?.call();
      },
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: duration,
    padding: EdgeInsets.zero,
  );
  
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  
  return completer.future;
}

class _ProgressSnackBarContent extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onComplete;

  const _ProgressSnackBarContent({
    required this.message,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_ProgressSnackBarContent> createState() => _ProgressSnackBarContentState();
}

class _ProgressSnackBarContentState extends State<_ProgressSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    // Animasi lebar dari 1.0 ke 0.0 (makin mengecil)
    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _controller.forward();
    
    // Timer untuk menutup snackbar
    _timer = Timer(widget.duration, () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Progress bar yang mengecil
          AnimatedBuilder(
            animation: _widthAnimation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 3,
                    width: constraints.maxWidth * _widthAnimation.value,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}