import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> _loadFileBytes(String url) async {
  Uint8List bytes;
  try {
    bytes = await readBytes(url);
  } catch (exception) {
    print('failed to download audio');
    rethrow;
  }
  return bytes;
}

Future<String> loadFile({String url, String path, renewParentWidget}) async {
  print('audio loading started');
  final bytes = await _loadFileBytes(url);

  final file = File(path);

  await file.writeAsBytes(bytes);
  if (await file.exists()) {
    print(file.path);
    print('audio loading ended');
    return file.path;
  } else {
    print('file not exist');
    throw Exception('file not exist');
  }
}

Future<String> getLocalPath(String url) async {
  final dir = await getApplicationDocumentsDirectory();
  String fileName = url.replaceAll('/', '_').replaceAll(':', '_');
  return '${dir.path}/$fileName';
}
