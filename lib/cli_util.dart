// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utilities for CLI programs written in dart.
///
/// This library contains information for returning the location of the dart
/// SDK, and other directories that command-line applications may need to
/// access. This library aims follows best practices for each platform, honoring
/// the [XDG Base Directory Specification][1] on Linux and
/// [File System Basics][2] on Mac OS.
///
/// Many functions require a `productName`, as data should be stored in a
/// directory unique to your application, as to not avoid clashes with other
/// programs on the same machine. For example, if you are writing a command-line
/// application named 'zinger' then `productName` on Linux could be `zinger`. On
/// MacOS, this should be your bundle identifier (for example,
/// `com.example.Zinger`).
///
/// [1]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
/// [2]: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1

library cli_util;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

/// The path to the current Dart SDK.
String get sdkPath => path.dirname(path.dirname(Platform.resolvedExecutable));

/// Returns the path to the current Dart SDK.
@Deprecated("Use 'sdkPath' instead")
String getSdkPath() => sdkPath;

// Executables are also mentioned in the XDG spec, but these do not have as well
// defined of locations on Windows and MacOS.
enum _BaseDirectory { cache, config, data, runtime, state }

/// Get the user-specific application cache folder for the current platform.
///
/// This is a location appropriate for storing non-essential files that may be
/// removed at any point. This method won't create the directory; It will merely
/// return the recommended location.
///
/// The folder location depends on the platform:
///  * `%LOCALAPPDATA%\<productName>` on **Windows**,
///  * `$HOME/Library/Caches/<productName>` on **Mac OS**,
///  * `$XDG_CACHE_HOME/<productName>` on **Linux**
///     (if `$XDG_CACHE_HOME` is defined), and,
///  * `$HOME/.cache/` otherwise.
///
/// Throws an [EnvironmentNotFoundException] if necessary environment variables
/// are undefined.
String applicationCacheHome(String productName) =>
    path.join(_baseDirectory(_BaseDirectory.cache), productName);

/// Get the user-specific application configuration folder for the current
/// platform.
///
/// This is a location appropriate for storing application specific
/// configuration for the current user. This method won't create the directory;
/// It will merely return the recommended location.
///
/// The folder location depends on the platform:
///  * `%APPDATA%\<productName>` on **Windows**,
///  * `$HOME/Library/Application Support/<productName>` on **Mac OS**,
///  * `$XDG_CONFIG_HOME/<productName>` on **Linux**
///     (if `$XDG_CONFIG_HOME` is defined), and,
///  * `$HOME/.config/<productName>` otherwise.
///
/// Throws an [EnvironmentNotFoundException] if necessary environment variables
/// are undefined.
String applicationConfigHome(String productName) =>
    path.join(_baseDirectory(_BaseDirectory.config), productName);

/// Get the user-specific application data folder for the current platform.
///
/// This is a location appropriate for storing application specific
/// semi-permanent data for the current user. This method won't create the
/// directory; It will merely return the recommended location.
///
/// The folder location depends on the platform:
///  * `%APPDATA%\<productName>` on **Windows**,
///  * `$HOME/Library/Application Support/<productName>` on **Mac OS**,
///  * `$XDG_DATA_HOME/<productName>` on **Linux**
///     (if `$XDG_DATA_HOME` is defined), and,
///  * `$HOME/.local/share/<productName>` otherwise.
///
/// Throws an [EnvironmentNotFoundException] if necessary environment variables
/// are undefined.
String applicationDataHome(String productName) =>
    path.join(_baseDirectory(_BaseDirectory.data), productName);

/// Get the runtime data folder for the current platform.
///
/// This is a location appropriate for storing runtime data for the current
/// session. This method won't create the directory; It will merely return the
/// recommended location.
///
/// The folder location depends on the platform:
///  * `%LOCALAPPDATA%\<productName>` on **Windows**,
///  * `$HOME/Library/Application Support/<productName>` on **Mac OS**,
///  * `$XDG_DATA_HOME/<productName>` on **Linux**
///     (if `$XDG_DATA_HOME` is defined), and,
///  * `$HOME/.local/share/<productName>` otherwise.
///
/// Throws an [EnvironmentNotFoundException] if necessary environment variables
/// are undefined.
String applicationRuntimeDir(String productName) =>
    path.join(_baseDirectory(_BaseDirectory.runtime), productName);

/// Get the user-specific application state folder for the current platform.
///
/// This is a location appropriate for storing application specific state
/// for the current user. This differs from [applicationDataHome] insomuch as it
/// should contain data which should persist restarts, but is not important
/// enough to be backed up. This method won't create the directory;
// It will merely return the recommended location.
///
/// The folder location depends on the platform:
///  * `%APPDATA%\<productName>` on **Windows**,
///  * `$HOME/Library/Application Support/<productName>` on **Mac OS**,
///  * `$XDG_DATA_HOME/<productName>` on **Linux**
///     (if `$XDG_DATA_HOME` is defined), and,
///  * `$HOME/.local/share/<productName>` otherwise.
///
/// Throws an [EnvironmentNotFoundException] if necessary environment variables
/// are undefined.
String applicationStateHome(String productName) =>
    path.join(_baseDirectory(_BaseDirectory.state), productName);

String _baseDirectory(_BaseDirectory dir) {
  if (Platform.isWindows) {
    switch (dir) {
      case _BaseDirectory.config:
      case _BaseDirectory.data:
        return _requireEnv('APPDATA');
      case _BaseDirectory.cache:
      case _BaseDirectory.runtime:
      case _BaseDirectory.state:
        return _requireEnv('LOCALAPPDATA');
    }
  }

  if (Platform.isMacOS) {
    switch (dir) {
      case _BaseDirectory.config:
      case _BaseDirectory.data:
      case _BaseDirectory.state:
        return path.join(_home, 'Library', 'Application Support');
      case _BaseDirectory.cache:
        return path.join(_home, 'Library', 'Caches');
      case _BaseDirectory.runtime:
        // https://stackoverflow.com/a/76799489
        return path.join(_home, 'Library', 'Caches', 'TemporaryItems');
    }
  }

  if (Platform.isLinux) {
    String xdgEnv;
    switch (dir) {
      case _BaseDirectory.config:
        xdgEnv = 'XDG_CONFIG_HOME';
        break;
      case _BaseDirectory.data:
        xdgEnv = 'XDG_DATA_HOME';
        break;
      case _BaseDirectory.state:
        xdgEnv = 'XDG_STATE_HOME';
        break;
      case _BaseDirectory.cache:
        xdgEnv = 'XDG_CACHE_HOME';
        break;
      case _BaseDirectory.runtime:
        xdgEnv = 'XDG_RUNTIME_HOME';
        break;
    }
    final val = _env[xdgEnv];
    if (val != null) {
      return val;
    }
  }

  switch (dir) {
    case _BaseDirectory.runtime:
      // not a great fallback
    case _BaseDirectory.cache:
      return path.join(_home, '.cache');
    case _BaseDirectory.config:
      return path.join(_home, '.config');
    case _BaseDirectory.data:
      return path.join(_home, '.local', 'share');
    case _BaseDirectory.state:
      return path.join(_home, '.local', 'state');
  }
}

String get _home => _requireEnv('HOME');

String _requireEnv(String name) =>
    _env[name] ?? (throw EnvironmentNotFoundException(name));

/// Exception thrown if a required environment entry does not exist.
///
/// Thrown by [applicationConfigHome] if an expected and required
/// platform specific environment entry is not available.
class EnvironmentNotFoundException implements Exception {
  /// Name of environment entry which was needed, but not found.
  final String entryName;
  String get message => 'Environment variable \'$entryName\' is not defined!';
  EnvironmentNotFoundException(this.entryName);
  @override
  String toString() => message;
}

// This zone override exists solely for testing (see lib/cli_util_test.dart).
Map<String, String> get _env =>
    (Zone.current[#environmentOverrides] as Map<String, String>?) ??
    Platform.environment;
