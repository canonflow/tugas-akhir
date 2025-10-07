import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> imageDownloader(BuildContext context, String url) async {
  try {
    // TODO: 01. Download the image
    final response = await http.get(Uri.parse(url));

    // TODO: 02. Get Temporary Directory
    final dir = await getTemporaryDirectory();

    // TODO: 03. Create an image name
    var extension = url.split(".").last;
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var filename = '${dir.path}/$timestamp.$extension';

    // TODO 04. Save to filesystem
    final file = File(filename);
    await file.writeAsBytes(response.bodyBytes);

    // TODO: 05. Ask the user to save it
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final finalPath = await FlutterFileDialog.saveFile(params: params);

    return finalPath;
  } catch (e) {
    print("Image Downloader Function Error: $e");
    rethrow;
  }
}