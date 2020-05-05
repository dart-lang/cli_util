// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:cli_util/src/utils.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('getSdkDir', () {
    test('arg parsing', () {
      expect(getSdkDir(['--dart-sdk', '/dart/sdk']).path, equals('/dart/sdk'));
      expect(getSdkDir(['--dart-sdk=/dart/sdk']).path, equals('/dart/sdk'));
    });

    test('finds the SDK without cli args', () {
      expect(getSdkDir(), isNotNull);
    });
  });

  group('getSdkPath', () {
    test('sdkPath', () {
      expect(getSdkPath(), isNotNull);
    });
  });

  group('utils', () {
    test('isSdkDir', () {
      expect(isSdkDir(Directory(getSdkPath())), true);
    });
  });
}
