// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('getSdkPath', () {
    test('sdkPath', () {
      expect(getSdkPath(), isNotNull);
    });
  });

  group('applicationConfigHome', () {
    test('returns a non-empty string', () {
      expect(applicationConfigHome('dart'), isNotEmpty);
    });

    test('has an ancestor folder that exists', () {
      final path = p.split(applicationConfigHome('dart'));
      // We expect that first two segments of the path exists.. This is really
      // just a dummy check that some part of the path exists.
      expect(Directory(p.joinAll(path.take(2))).existsSync(), isTrue);
    });

    test('Throws IOException when run with empty environment', () {
      final scriptPath = p.join('test', 'print_config_home.dart');
      final result = Process.runSync(
        Platform.resolvedExecutable,
        [scriptPath],
        environment: {},
        includeParentEnvironment: false,
      );
      final varName = Platform.isWindows ? '%APPDATA%' : r'$HOME';
      expect(
        (result.stdout as String).trim(),
        'Caught: Environment variable $varName is not defined!',
      );
      expect(result.exitCode, 0);
    });
  });
}
