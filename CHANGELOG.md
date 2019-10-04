<!-- markdownlint-disable MD024 -->

# Changelog #

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] ##

[Unreleased]: https://github.com/mfederczuk/makefile-template/compare/v1.0.0...develop

## Changed ##

* When `SRC`, `BIN` or `INC`, the Makefile will now throw an error and stop
  execution
* Defining `LINKS` when building a library will only display a warning instead
  of throwing an error
* The output is now colored

## [1.0.0] - 2019-10-02 ##

[1.0.0]: https://github.com/mfederczuk/makefile-template/releases/tag/v1.0.0

### Added ###

* Base Makefile
* `exe` and `lib` software type
* Automatic source file detection
