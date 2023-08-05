// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cli_util/cli_logging.dart';

Future<void> main(List<String> args) async {
  var percentage = 0;
  final progress = CustomProgress(
    refreshPer: const Duration(milliseconds: 50),
    // This callback will be called per 'refreshPer'
    message: (elapsed) =>
        'Downloading $percentage% (${elapsed.inMilliseconds / 1000.0}s)',
  );

  while (percentage <= 100) {
    // Do stuffs...
    await Future<void>.delayed(const Duration(milliseconds: 50));
    percentage++;
  }

  progress.finish(message: 'Download: Done!');
}
