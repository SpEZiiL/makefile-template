<!-- markdownlint-disable MD024 -->

# Changelog #

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] ##

[Unreleased]: https://github.com/mfederczuk/makefile-template/compare/v1.0.0...develop

### Added ###

* The output is now colored
* An `other.mk` file can be put in the same directory as the Makefile for other
  user defined targets (it is included at the end of the Makefile)
* Automatic test detection from source files inside the new `SRC_TEST` variable

### Changed ###

* Renamed `SRC` to `SRC_MAIN`
* When the `SRC_MAIN`, `BIN` or `INC` variables are not defined the Makefile
  will now throw an error and stop execution instead of just displaying a
  warning
* Defining `LINKS` when building a library will only display a warning instead
  of throwing an error

### Fixed ###

* The executable and library targets are no longer being rebuild even when the
  source files didn't change

## [1.0.1] - 2019-10-05 ##

[1.0.1]: https://github.com/mfederczuk/makefile-template/compare/v1.0.0...v1.0.1

### Fixed ###

* Built **C** executables will no longer have two spaces in front of them

## [1.0.0] - 2019-10-02 ##

[1.0.0]: https://github.com/mfederczuk/makefile-template/releases/tag/v1.0.0

### Added ###

* Base Makefile
* `exe` and `lib` software type
* Automatic source file detection
