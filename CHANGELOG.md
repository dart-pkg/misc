# CHANGELOG.md

## 2025.422.1753

- Initial release

## 2025.423.1904

- Modified makeCommandLine()

## 2025.423.1928

- Added $() and $$()

## 2025.423.1946

- $() and $$() accept ignoreError optional name parameter

## 2025.423.2215

- Added splitCommandLine() and removed $() and $$()

## 2025.423.2241

- Fixed a bug in splitCommandLine()

## 2025.424.6

- Changed parser spec

## 2025.424.12

- Modified makeCommandLine()

## 2025.424.28

- Modified makeCommandLine() again

## 2025.424.56

- Modified makeCommandLine()

## 2025.424.118

- Removed all of the dependencies

## 2025.424.1249

- Modified makeCommandLine()

## 2025.426.348

- Renamed makeCommandLine() to joinCommandLine()

## 2025.426.359

- [misc] A dependncy less dart package.

## 2025.426.1656

- Backport form std package

## 2025.426.2309

- Modified lib/misc.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.426.1656
+version: 2025.426.2309
-  output: ^1.0.7
+  output: ^2025.426.2027
```

## 2025.501.111

- Backport from std package

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.426.2309
+version: 2025.501.111
+dependencies:
+  path: ^1.9.1
```

## 2025.503.25

- Backport from package:std/misc.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.501.111
+version: 2025.503.25
-  output: ^2025.430.1731
+  output: ^2025.502.1958
+  crypto: ^3.0.6
+  uuid: ^4.5.1
```

## 2025.504.1246

- Backport from package:std/misc.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.503.25
+version: 2025.504.1246
+  system_info2: ^4.0.0
```
