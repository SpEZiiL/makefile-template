# C/C++ Makefile Template for applications and libraries.
# Copyright (C) 2019 Michael Federczuk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# === user definitions ======================================================= #

SOFTWARE = exe|lib

TARGET =

SRC = src
BIN = bin
INC = include/$(TARGET)

LINKS =

CCFLAGS  = -Iinclude -std=c17   -Wall -Wextra
CXXFLAGS = -Iinclude -std=c++17 -Wall -Wextra

# === preconditions ========================================================== #

-include _debug.mk

ifndef SOFTWARE
 $(error SOFTWARE not defined)
endif
override SOFTWARE := $(strip $(SOFTWARE))
ifeq "$(SOFTWARE)" "exe|lib"
 $(error It appears that you forgot to configure the Makefile)
endif
ifneq "$(SOFTWARE)" "exe"
 ifneq "$(SOFTWARE)" "lib"
  $(error Unknown software type "$(SOFTWARE)")
 endif
endif

ifndef TARGET
 $(error TARGET not defined)
endif
override TARGET := $(strip $(TARGET))

ifndef SRC
 $(warning W: SRC not defined, defaulting to "src")
 override SRC := src
endif
override SRC := $(strip $(SRC))

ifndef BIN
 $(warning W: BIN not defined, defaulting to "bin")
 override BIN := bin
endif
override BIN := $(strip $(BIN))

ifneq "$(SOFTWARE)" "exe"
 ifndef INC
  $(warning W: INC not defined, defaulting to "include/$(TARGET)")
  override INC := include/$(TARGET)
 endif
 override INC := $(strip $(INC))
endif

# warnings/errors about LINKS and LINK_DIR
ifeq "$(SOFTWARE)" "exe"
 ifdef LINK_DIRS
  ifndef LINKS
   $(warning W: LINK_DIRS defined, but no libaries to link with specified)
  endif
 endif
else
 ifdef LINKS
  $(error Can only link libaries to an executable)
 endif
 ifdef LINK_DIRS
  $(warning W: LINK_DIRS is defined but we're building a library; consider removing LINK_DIRS)
 endif
endif

# === variables ============================================================== #

SHELL = /bin/sh
prefix      = /usr/local
exec_prefix = $(prefix)
bindir      = $(exec_prefix)/bin
includedir  = $(prefix)/include
libdir      = $(exec_prefix)/lib

# normally, shared object files also have the .o extension, to hold them apart
# we're going to use .so (which literally stands for shared object).
# it's important that these two variables are different
shared_object_ext = so
static_object_ext = o

# better not change those
shared_lib_prefix = lib
static_lib_prefix = lib
shared_lib_suffix = .so
static_lib_suffix = .a

# *nix executables usually don't have a suffix, if you want you can change that
exe_prefix =
exe_suffix =

# in case these are not defined for some reason
CC      ?= cc
CXX     ?= c++
AR      ?= ar
INSTALL ?= install
