import 'package:page_transition/page_transition.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PageMove {
  static void PushNamed(
      BuildContext context,
      String routeName,
      PageTransitionType type,
      Duration duration,
      {
        bool pop = false,
        Map<String, dynamic>? arguments
      }
  ) {
    final Map<String, dynamic> args = {};

    if (arguments != null) args.addAll(arguments);

    if (pop) Navigator.pop(context);
    context.pushNamedTransition(
        routeName: routeName,
        type: type,
        duration: duration,
        arguments: args
    );
  }
}