import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget buildToastSuccess(BuildContext context, ToastOverlay overlay) {
  return SurfaceCard(
      child: Basic(
        title: Text("Success"),
        subtitle: Text("Image downloaded successfully"),
        trailing: PrimaryButton(
            size: ButtonSize.small,
            onPressed: () {
              overlay.close();
            },
            child: Text("Close")
        ),
        trailingAlignment: Alignment.center,
      )
  );
}

Widget buildToastError(BuildContext context, ToastOverlay overlay) {
  return SurfaceCard(
      child: Basic(
        title: Text("Error"),
        subtitle: Text("An error occurred while downloading the image!"),
        trailing: PrimaryButton(
            size: ButtonSize.small,
            onPressed: () {
              overlay.close();
            },
            child: Text("Close")
        ),
        trailingAlignment: Alignment.center,
      )
  );
}