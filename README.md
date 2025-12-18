<!---
MIT License

CMake build script for GitVersionInfo module
Copyright (c) 2025 Tim Kaune

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--->

# GitVersionInfo #

This CMake module contains macros for triggering rebuilds on Git status changes
and providing the latest Git SHA1 hash as compile definition.

## Prerequisites ##

What you need:

- [Git](https://git-scm.com/) (optional) for getting the code and contributing
  to the project
- [CMake](https://cmake.org/) and [Ninja](https://ninja-build.org/) for building
  the project

### Linux (Ubuntu) ###

Use your distribution's package manager to install the necessary packages:

```shell
$ sudo apt-get install cmake ninja-build
```

### Mac OS X ###

You will need one of the community package managers for Mac OS X:
[Homebrew](https://brew.sh/) or
[MacPorts](https://www.macports.org/install.php). For installing one of these,
please refer to their respective installation instructions.

#### Homebrew ####

```shell
$ brew install cmake ninja
```

#### MacPorts ####

```shell
$ sudo port -v install cmake ninja
```

### Windows ###

The easiest thing to do is using the [Windows Subsystem for Linux
(WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) and follow the
Linux instructions above.

Otherwise, install [Git for Windows](https://gitforwindows.org/) for version
control and [cygwin](https://cygwin.com/install.html), which is a large
collection of GNU and Open Source tools which provide functionality similar to a
Linux distribution on Windows. During the `cygwin` installation you'll be
prompted to add additional packages. Search and select the following:

- `cmake` and `ninja` for the build system

After `cygwin` finishes installing, use the cygwin terminal to start the build
process.

## How to build ##

1. Clone the git repository or download the source code archive and unpack it to
   an arbitrary directory (e.g. `git-version-info`).
2. Go to this directory and type `cp ./CMakeUserPresets.template.json
   ./CMakeUserPresets.json`.
3. Next, type `cmake --workflow --list-presets`. A list of available build
   workflows will be shown to you.
4. For configuring, building and installing the project, type `cmake --workflow
   --preset user-install`. This will populate the `./build` directory with a CMake
   configuration tree, execute the build and install the project. By default,
   the configured installation directory is `./install`.

   You can specify a different install location by setting the
   `CMAKE_INSTALL_PREFIX` variable in the `"user-config"` preset in your
   `./CMakeUserPresets.json`:

   ```json
      "cacheVariables": {
         "CMAKE_INSTALL_PREFIX": "$env{HOME}/.local"
      }
   ```

   Please refer to the [CMake Documentation about presets][1] for further details.

5. For running the tests, type `cmake --workflow --preset user-test`.

[1]: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html

## How to use ##

With the `GitVersionInfo` module installed, you can use it in other projects.
The installed `GitVersionInfo` package is discoverable by CMake as
__GitVersionInfo__. In the `CMakeLists.txt` of the other project, do the
following:

```cmake
include(FetchContent)

FetchContent_Declare(
    GitVersionInfo
    GIT_REPOSITORY "https://github.com/lepus2589/GitVersionInfo.git"
    GIT_TAG v1.1.1
    SYSTEM
    FIND_PACKAGE_ARGS 1.1.1 CONFIG NAMES GitVersionInfo
)
set(GitVersionInfo_INCLUDE_PACKAGING TRUE)
FetchContent_MakeAvailable(GitVersionInfo)
```

This discovers an installed version of the GitVersionInfo module or adds it to
the other project's install targets. To help CMake discover an installed
GitVersionInfo package, call CMake for the other project like this:

```shell
$ cmake -B ./build -D "CMAKE_PREFIX_PATH=/path/to/GitVersionInfo/install/prefix"
```

Replace the path to the GitVersionInfo install prefix with the actual path on
your system! If GitVersionInfo is installed in a proper system-wide location,
the `CMAKE_PREFIX_PATH` shouldn't be necessary.

In the other project's package config CMake file, you can now use the module like this:

```cmake
include(GitVersionInfo)

git_version_info_add_dependant_source_files(
   TARGET <target_to_rebuild>
   SOURCES <source files to rebuild>...
)
```

The `find_package()` command in FetchContent adds the GitVersionInfo module to
the `CMAKE_MODULE_PATH` variable which enables the `include()` by name only.
