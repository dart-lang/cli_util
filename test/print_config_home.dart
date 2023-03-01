// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_util/cli_util.dart';

void main() {
  try {
    print(applicationConfigHome('dart'));
  } on EnvironmentNotFoundException catch (e) {
    print('Caught: $e');
  }
}
