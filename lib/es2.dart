import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';


class ElectribeSampler2 {
  ElectribeSampler2();

  late final File allFile;
  late final Uint8List bytes;
  Logger logger = Logger('electribe-sampler2');
  List<ElectribeSample> samples = [];

  void loadAllFile(String path) {
    Logger.root.level = Platform.environment['debug'] == '1' ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });

    allFile = File(path);
    bytes = allFile.readAsBytesSync();

    logger.finest('length: ${bytes.length}');

    _readAllFile();
  }

  void _readAllFile() {
    // it should have at the first 14 bytes
    // the string "e2s all file"
    String readString = '';
    for (var i = 0; i < 14; i++) {
      readString += String.fromCharCode(bytes[i]);
    }

    assert(readString == 'e2s sample all', 'Expected "e2s sample all" but got "$readString"');

    logger.finest('readString: $readString');

    for (var i = 0; i < 1020*4; i+=4) {
      final offset = ByteData.view(bytes.sublist(i, i+4).buffer).getInt32(0, Endian.little);
      if (offset == 0) {
        continue;
      }
      final sampleBytes = bytes.sublist((offset * 1024).toInt(), (offset * 1024).toInt() + 1024);
      samples.add(ElectribeSample(
        allFile: allFile,
        offset: offset,
        bytes: sampleBytes,
      ));
    }

  }
}

class ElectribeSample {
  ElectribeSample({
    required this.allFile,
    required this.offset,
    required this.bytes,
  }) {
    _init();
  }

  final Uint8List bytes;
  final int offset;
  final File allFile;
  
  void _init() {
    final res = ByteData.view(bytes.sublist(88, 88+4).buffer).getInt32(0, Endian.little);
    String id = '';
    for (var i = res; i < res + 4; i++) {
      id += String.fromCharCode(bytes[i]);
    }
    final size = ByteData.view(bytes.sublist(res + 4, res + 4 + 4).buffer).getUint32(0, Endian.little);
    print('size: $size');
    print('res: $res id: $id');
  }
}
