# C/C++ Makefile Template #

[version_shield]: https://img.shields.io/badge/version-N%2FA-blue.svg
[latest_release]: https://github.com/mfederczuk/makefile-template/releases/latest "Latest Release"
[![version: N/A][version_shield]][latest_release]
[![Changelog](https://img.shields.io/badge/-Changelog-blue)](./CHANGELOG.md "Changelog")

## About ##

**C/C++** [Makefile](https://www.gnu.org/software/make/) template for
 applications and libraries.

## Download ##

Download the Makefile from the [latest release][latest_release] and move it into
 your project directory.

You can also use `wget` to quickly get it from my **GitHub Pages** site.

	wget https://mfederczuk.github.io/makefile-template/Makefile

## Configuration ##

After you've added the Makefile into your project directory, you will need to
 configure it a little.  
Open it up and you will see various variable definitions under the
 "user definitions" section.

* `SOFTWARE`  
  The Makefile lets you build two kinds of software: executables and libraries.  
  Set this variable to `exe` to build an executable, set it to `lib` to build
   a shared (dynamic) and static library.  
  Any other value is invalid and will result in errors when trying to invoke the
   Makefile
* `TARGET`  
  The name of the executable or library to build.  
  Don't add any prefix or suffixes to this name. e.g.: instead of "`libfoo.so`"
   use just "`foo`".  
  If you want to change any prefix or suffixes you can do so by changing the
   `exe_prefix`, `exe_suffix`, `shared_lib_prefix`, `shared_lib_suffix`,
   `static_lib_prefix` and `static_lib_suffix` variables.
* `SRC`  
  The directory in which the source files are stored.  
  The Makefile will search this directory for any source files and will
   automatically add them.  
  Any file that is not a **C** or **C++** file will be ignored.  
  To see what file extensions are mapped to which language, refer to
   [Appendix A](#appendix-a-file-extensions)
* `BIN`  
  The directory in which the built object files will be stored.  
  It's generally a good idea to add this directory to your `.gitignore` file.  
  This directory does not need to exist before building.
* `INC`  
  The directory in which the header files are stored.  
  It's not needed to define this variable if you're building an executable,
   since we only need to know this directory so we can install it.  
  **Note:** This Makefile does *not* support having both the header and the
   source files mixed up (at least for libraries). You need to put your headers
   into a separate directory. This directory *may* be inside the `SRC`
   directory.  
  It's always good practice to have an `include` directory next to your `SRC`
   directory, have you headers in a subdirectory of this `include` directory and
   then add `-Iinclude` to your compiler flags.
* `LINK_DIRS`  
  A list of directories to search for when linking libraries.  
  (this option will not be already written in this section like the others,
   because you will rarely ever use it)
* `LINKS`  
  A list of libraries to link with.  
  **Note:** We *cannot* link any libraries when building a library ourself. The
   Makefile will throw an error if this variable is defined and `SOFTWARE` is
    set to `lib`
* `CCFLAGS` & `CXXFLAGS`  
  It's standard Makefile conventions  to use these variables as flags for the
   **C** and **C++** compiler, add include directories (`-I`), language
   standards (`-std=`) and warning flags like `-Wall` here.  
  Do *not* add compilation options like `-c`, output options like `-o` or
   linking options like `-l`

Several variables will already have a value written in them. This is what *I*
 perceive to be best practice. Feel free to change them however you like.

## Contributing ##

Read through the [C/C++ Makefile Template Contribution Guidelines](./CONTRIBUTING.md)
 if you want to contribute to this project.

## License ##

[GNU GPLv3+](./LICENSE)

## Appendix A: File Extensions ##

These file extensions were taken from the **GCC** man page.

**C:**

* `c`
* `ii`

**C++:**

* `C`
* `cc`
* `cp`
* `ii`
* `c++`
* `cpp`
* `CPP`
* `cxx`
