import 'dart:io';

import 'package:cli_util/cli_util.dart';

void main() {
  try {
    print(applicationConfigHome('dart'));
  } on IOException catch (e) {
    print('Caught: $e');
  }
}
