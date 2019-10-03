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
 $(error SOFTWARE is not defined)
endif
override SOFTWARE := $(strip $(SOFTWARE))
ifeq "$(SOFTWARE)" "exe|lib"
 $(error Makefile is not configured)
endif
ifneq "$(SOFTWARE)" "exe"
 ifneq "$(SOFTWARE)" "lib"
  $(error Software type ("$(SOFTWARE)") is unknown)
 endif
endif

ifndef TARGET
 $(error TARGET is not defined)
endif
override TARGET := $(strip $(TARGET))

ifndef SRC
 $(error SRC is not defined)
endif
override SRC := $(strip $(SRC))

ifndef BIN
 $(error BIN is not defined)
endif
override BIN := $(strip $(BIN))

ifneq "$(SOFTWARE)" "exe"
 ifndef INC
  $(error INC is not defined)
 endif
 override INC := $(strip $(INC))
endif

# warnings/errors about LINKS and LINK_DIRS
ifeq "$(SOFTWARE)" "exe"
 ifdef LINK_DIRS
  ifndef LINKS
   $(warning LINK_DIRS defined, but no libaries to link with specified)
  endif
 endif
else
 ifdef LINKS
  $(error Can only link libaries to an executable)
 endif
 ifdef LINK_DIRS
  $(warning LINK_DIRS is defined but we're building a library; consider removing LINK_DIRS)
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

# === constants ============================================================== #

override LINK_FLAGS := $(addprefix -L,$(LINK_DIRS)) $(addprefix -l,$(LINKS))

override C_SOURCES   := $(foreach \
		__file, \
		$(shell find '$(SRC)' \
				-type f \
				-name '*.[ci]' \
		), \
		$(__file:$(SRC)/%=%) \
)
override CXX_SOURCES := $(foreach \
		__file, \
		$(shell find '$(SRC)' \
				-type f \
				'(' \
						-name '*.C'   -o \
						-name '*.cc'  -o \
						-name '*.cp'  -o \
						-name '*.ii'  -o \
						-name '*.c++' -o \
						-name '*.cpp' -o \
						-name '*.CPP' -o \
						-name '*.cxx'    \
				')' \
		), \
		$(__file:$(SRC)/%=%) \
)

# checking if source files were found
ifeq "$(C_SOURCES)$(CXX_SOURCES)" ""
 $(error No source files found)
endif

# shared objects
override SHARED_C_OBJECTS   := $(foreach __source_file,$(C_SOURCES), \
	$(BIN)/$(__source_file).$(shared_object_ext) \
)
override SHARED_CXX_OBJECTS := $(foreach __source_file,$(CXX_SOURCES), \
	$(BIN)/$(__source_file).$(shared_object_ext) \
)
override SHARED_OBJECTS     := $(SHARED_C_OBJECTS) $(SHARED_CXX_OBJECTS)

# static objects
override STATIC_C_OBJECTS   := $(foreach __source_file,$(C_SOURCES), \
	$(BIN)/$(__source_file).$(static_object_ext) \
)
override STATIC_CXX_OBJECTS := $(foreach __source_file,$(CXX_SOURCES), \
	$(BIN)/$(__source_file).$(static_object_ext) \
)
override STATIC_OBJECTS     := $(STATIC_C_OBJECTS) $(STATIC_CXX_OBJECTS)

# targets
override SHARED_LIB_TARGET := $(shared_lib_prefix)$(TARGET)$(shared_lib_suffix)
override STATIC_LIB_TARGET := $(static_lib_prefix)$(TARGET)$(static_lib_suffix)
override EXE_TARGET        := $(exe_prefix)$(TARGET)$(exe_suffix)

# === default rule =========================================================== #

# exe: all
# lib: all

ifeq "$(SOFTWARE)" "exe"
 all: $(EXE_TARGET)
 .PHONY: all
else
 all: targets
 .PHONY: all
endif

# === building object files ================================================== #

# exe: objects $(STATIC_OBJECTS)
# lib: objects objects/shared objects/static $(SHARED_OBJECTS) $(STATIC_OBJECTS)

ifeq "$(SOFTWARE)" "exe"
 objects: $(STATIC_OBJECTS)
 $(STATIC_C_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CC) $(CCFLAGS) -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects
else
 objects: objects/shared objects/static
 objects/shared: $(SHARED_OBJECTS)
 objects/static: $(STATIC_OBJECTS)
 $(SHARED_C_OBJECTS): $(BIN)/%.$(shared_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CC) $(CCFLAGS) -c '$<' -o '$@' -fPIC
 $(SHARED_CXX_OBJECTS): $(BIN)/%.$(shared_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@' -fPIC
 $(STATIC_C_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CC) $(CCFLAGS) -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC)/%
	@mkdir -p '$(dir $@)'
	$(info Building file '$@'...)
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects objects/shared objects/static
endif

# === building targets ======================================================= #

# exe: $(EXE_TARGET)
# lib: targets $(SHARED_LIB_TARGET) $(STATIC_LIB_TARGET)

ifeq "$(SOFTWARE)" "exe"
 $(EXE_TARGET): objects
	$(info Building target '$(EXE_TARGET)'...)
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CCFLAGS)  $(STATIC_OBJECTS) -o '  $(EXE_TARGET)' $(LINK_FLAGS)
  else
	@$(CXX) $(CXXFLAGS) $(STATIC_OBJECTS) -o '$(EXE_TARGET)' $(LINK_FLAGS)
  endif
else
 targets: $(SHARED_LIB_TARGET) $(STATIC_LIB_TARGET)
 $(SHARED_LIB_TARGET): objects/shared
	$(info Building target '$(SHARED_LIB_TARGET)'...)
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CCFLAGS)  $(SHARED_OBJECTS) -o '$(SHARED_LIB_TARGET)' -shared
  else
	@$(CXX) $(CXXFLAGS) $(SHARED_OBJECTS) -o '$(SHARED_LIB_TARGET)' -shared
  endif
 $(STATIC_LIB_TARGET): objects/static
	$(info Building target '$(STATIC_LIB_TARGET)'...)
	@$(AR) rs '$(STATIC_LIB_TARGET)' $(STATIC_OBJECTS) 2>/dev/null
 .PHONY: targets
endif

# === installing ============================================================= #

# exe: install
# lib: install install/targets
#      install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET)
#      install/headers

ifeq "$(SOFTWARE)" "exe"
 install: $(EXE_TARGET)
	$(info Installing target '$(EXE_TARGET)' to '$(DESTDIR)$(bindir)'...)
	@$(INSTALL) -m755 '$(EXE_TARGET)' '$(DESTDIR)$(bindir)'
 .PHONY: install
else
 install: install/targets install/headers
 install/targets: install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET)
 install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET): install/%: %
	$(info Installing target '$(@:install/%=%)' to '$(DESTDIR)$(libdir)'...)
	@$(INSTALL) -m644 '$(@:install/%=%)' '$(DESTDIR)$(libdir)'
 install/headers:
	$(info Installing headers to '$(DESTDIR)$(includedir)'...)
	@cp -r '$(INC)' '$(DESTDIR)$(includedir)'
 .PHONY: install install/targets \
         install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET) \
         install/headers
endif

# === uninstalling =========================================================== #

# exe: uninstall
# lib: uninstall uninstall/targets
#      uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET)
#      uninstall/headers

ifeq "$(SOFTWARE)" "exe"
 uninstall:
	@rm -f '$(DESTDIR)$(bindir)/$(EXE_TARGET)'
 .PHONY: uninstall
else
 uninstall: uninstall/targets uninstall/headers
 uninstall/targets: uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET)
 uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(DESTDIR)$(libdir)/$(@:uninstall/%=%)'
 uninstall/headers:
	@rm -rfv '$(DESTDIR)$(includedir)/$(notdir $(INC))'
 .PHONY: uninstall uninstall/targets \
         uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET) \
         uninstall/headers
endif

# === cleaning =============================================================== #

# exe: clean
#      clean/objects $(addprefix clean/,$(STATIC_OBJECTS))
#      clean/$(EXE_TARGET)
# lib: clean
#      clean/objects clean/objects/shared clean/objects/static
#      clean/targets clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)

override _clean_empty_bin_dirs := if [ -d '$(BIN)' ]; then \
	find '$(BIN)' -depth -type d -exec rm -dfv '{}' ';' 2>/dev/null ; \
fi

ifeq "$(SOFTWARE)" "exe"
 clean: clean/objects clean/$(EXE_TARGET)
 .PHONY: clean

 clean/objects:
	@rm -rfv '$(BIN)'
 $(addprefix clean/,$(STATIC_OBJECTS)): %:
	@rm -fv '$(@:clean/%=%)'
	@$(_clean_empty_bin_dirs)
 .PHONY: clean/objects $(addprefix clean/,$(STATIC_OBJECTS))

 clean/$(EXE_TARGET):
	@rm -fv '$(EXE_TARGET)'
 .PHONY: clean/$(EXE_TARGET)
else
 clean: clean/objects clean/targets
 .PHONY: clean

 clean/objects:
	@rm -rfv '$(BIN)'
 clean/objects/shared:
	@rm -fv $(SHARED_OBJECTS)
	@$(_clean_empty_bin_dirs)
 clean/objects/static:
	@rm -fv $(STATIC_OBJECTS)
	@$(_clean_empty_bin_dirs)
 $(addprefix clean/,$(SHARED_OBJECTS) $(STATIC_OBJECTS)): %:
	@rm -fv '$(@:clean/%=%)'
	@$(_clean_empty_bin_dirs)
 .PHONY: clean/objects clean/objects/shared clean/objects/static

 clean/targets: clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)
 clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(@:clean/%=%)'
 .PHONY: clean/targets clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)
endif

# === version ================================================================ #

_version:
	@echo 1.0.0
.PHONY: _version
