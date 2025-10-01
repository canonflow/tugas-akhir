import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget CustomAppBar(BuildContext context, String title, bool hasPrevious) {
  final authService = getIt<AuthService>();

  return AppBar(
    title: Text(
      title,
      style: TextStyle(
          color: Colors.gray[600]
      ),
    ).h4,
    leading: [
      if (hasPrevious) OutlineButton(
          size: ButtonSize.small,
          density: ButtonDensity.icon,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
      )
    ],
    trailing: [
      OutlineButton(
        size: ButtonSize.small,
        density: ButtonDensity.icon,
        onPressed: () async {
          try {
            await authService.signOut();
          } catch (e) {
            CustomSimpleDialog(context, "Error", e.toString());
          }
        },
        child: const Icon(Icons.logout_rounded),
      ),
    ],
  );
}