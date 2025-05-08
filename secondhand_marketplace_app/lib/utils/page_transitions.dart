import 'package:flutter/material.dart';
import '../constants.dart';

/// Custom page route that maintains the dark background during transitions
class DarkPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  DarkPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          // Set the background color to match your app's dark theme
          opaque: true,
          barrierColor: AppColors.charcoalBlack,
          barrierDismissible: false,
          maintainState: true,
        );
}

/// Custom page route for replacing the current page
class DarkPageReplaceRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  DarkPageReplaceRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          // Set the background color to match your app's dark theme
          opaque: true,
          barrierColor: AppColors.charcoalBlack,
          barrierDismissible: false,
          maintainState: true,
        );
}
