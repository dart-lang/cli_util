// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('sdkPath', () {
    test('sdkPath', () {
      expect(sdkPath, isNotNull);
    });
  });

  final functions = {
    'applicationCacheHome': applicationCacheHome,
    'applicationConfigHome': applicationConfigHome,
    'applicationDataHome': applicationDataHome,
    'applicationRuntimeDir': applicationRuntimeDir,
    'applicationStateHome': applicationStateHome,
  };
  functions.forEach((name, fn) {
    group(name, () {
      test('returns a non-empty string', () {
        expect(fn('dart'), isNotEmpty);
      });

      test('has an ancestor folder that exists', () {
        final path = p.split(fn('dart'));
        // We expect that first two segments of the path exist. This is really
        // just a dummy check that some part of the path exists.
        expect(Directory(p.joinAll(path.take(2))).existsSync(), isTrue);
      });

      test('empty environment throws exception', () async {
        expect(() {
          runZoned(() => fn('dart'), zoneValues: {
            #environmentOverrides: <String, String>{},
          });
        }, throwsA(isA<EnvironmentNotFoundException>()));
      });
    });
  });
}
