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

SRC_MAIN = src
BIN = bin
INC = include/$(TARGET)

LINKS =

TEST =

CCFLAGS  = -Iinclude -std=c17   -Wall -Wextra
CXXFLAGS = -Iinclude -std=c++17 -Wall -Wextra

# === colors ================================================================= #

# reset:     0
# bold:      1
# italic:    3
# underline: 4
# black:    30  |  bright black:   90
# red:      31  |  bright red:     91
# yellow:   33  |  bright yellow:  93
# green:    32  |  bright green:   92
# cyan:     36  |  bright cyan:    96
# blue:     34  |  bright blue:    94
# magenta:  35  |  bright magenta: 95
# white:    37  |  bright white:   97
_ascii_esc = $(shell printf '\033[$(1)m')

reset_fx  := $(call _ascii_esc,0)
error_fx := $(call _ascii_esc,91;1)
warning_fx := $(call _ascii_esc,33)
object_build_fx := $(call _ascii_esc,34)
target_build_fx := $(call _ascii_esc,34;1)
install_fx := $(call _ascii_esc,32)
uninstall_fx := $(call _ascii_esc,91)
clean_fx := $(call _ascii_esc,91)

# === preconditions ========================================================== #

-include _debug.mk

ifndef SOFTWARE
 $(error $(error_fx)SOFTWARE is not defined$(reset_fx))
endif
override SOFTWARE := $(strip $(SOFTWARE))
ifeq "$(SOFTWARE),$(TARGET),$(SRC_MAIN),$(BIN),$(INC),$(LINKS),$(LINK_DIRS),$(TEST),$(CCFLAGS),$(CXXFLAGS)" \
     "exe|lib,,src,bin,include/$(TARGET),,,,-Iinclude -std=c17   -Wall -Wextra,-Iinclude -std=c++17 -Wall -Wextra"
 $(error $(error_fx)Makefile is not configured$(reset_fx))
endif
ifneq "$(SOFTWARE)" "exe"
 ifneq "$(SOFTWARE)" "lib"
  $(error $(error_fx)Software type ("$(SOFTWARE)") is unknown$(reset_fx))
 endif
endif

ifndef TARGET
 $(error $(error_fx)TARGET is not defined$(reset_fx))
endif
override TARGET := $(strip $(TARGET))

ifndef SRC_MAIN
 $(error $(error_fx)SRC_MAIN is not defined$(reset_fx))
endif
override SRC_MAIN := $(strip $(SRC_MAIN))

ifndef BIN
 $(error $(error_fx)BIN is not defined$(reset_fx))
endif
override BIN := $(strip $(BIN))

ifneq "$(SOFTWARE)" "exe"
 ifndef INC
  $(error $(error_fx)INC is not defined$(reset_fx))
 endif
 override INC := $(strip $(INC))
endif

# warnings/errors about LINKS and LINK_DIRS
ifeq "$(SOFTWARE)" "exe"
 ifdef LINK_DIRS
  ifndef LINKS
   $(warning $(warning_fx)LINK_DIRS is defined, but LINKS isn't. \
             Specifying link directories without links doesn't do anything. \
             Consider either removing LINK_DIRS or defining LINKS$(reset_fx))
  endif
 endif
else
 ifdef LINKS
  $(warning $(warning_fx)LINKS is defined, but is ignored when building a \
            library. Consider removing LINKS$(reset_fx))
 endif
 ifdef LINK_DIRS
  $(warning $(warning_fx)LINK_DIRS is defined, but is ignored when building a \
            library. Consider removing LINK_DIRS$(reset_fx))
 endif
endif

ifndef TEST
 $(error $(error_fx)TEST is not defined. \
         If you don't have any tests, define it as ':'$(reset_fx))
endif
override TEST := $(strip $(TEST))

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

test_prefix = $(exe_prefix)
test_suffix = _test$(exe_suffix)

# in case these are not defined for some reason
CC      ?= cc
CXX     ?= c++
AR      ?= ar
INSTALL ?= install

# === constants ============================================================== #

override LINK_FLAGS := $(addprefix -L,$(LINK_DIRS)) $(addprefix -l,$(LINKS))

override _find_c_files   = $(foreach \
		__file, \
		$(shell find '$(1)' \
				-type f \
				-name '*.[ci]' \
		), \
		$(__file:$(1)/%=%) \
)
override _find_cxx_files = $(foreach \
		__file, \
		$(shell find '$(1)' \
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
		$(__file:$(1)/%=%) \
)

override C_SOURCES   := $(call _find_c_files,$(SRC_MAIN))
override CXX_SOURCES := $(call _find_cxx_files,$(SRC_MAIN))

# checking if source files were found
ifeq "$(C_SOURCES)$(CXX_SOURCES)" ""
 $(error $(error_fx)No source files found$(reset_fx))
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
 $(STATIC_C_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC) $(CCFLAGS) -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects
else
 objects: objects/shared objects/static
 objects/shared: $(SHARED_OBJECTS)
 objects/static: $(STATIC_OBJECTS)
 $(SHARED_C_OBJECTS): $(BIN)/%.$(shared_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC) $(CCFLAGS) -c '$<' -o '$@' -fPIC
 $(SHARED_CXX_OBJECTS): $(BIN)/%.$(shared_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@' -fPIC
 $(STATIC_C_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC) $(CCFLAGS) -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(BIN)/%.$(static_object_ext): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects objects/shared objects/static
	@printf '$(clean_fx)'
endif

# === building targets ======================================================= #

# exe: $(EXE_TARGET)
# lib: targets $(SHARED_LIB_TARGET) $(STATIC_LIB_TARGET)

ifeq "$(SOFTWARE)" "exe"
 $(EXE_TARGET): objects
	$(info $(target_build_fx)Building target '$(EXE_TARGET)'...$(reset_fx))
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CCFLAGS)  $(STATIC_OBJECTS) -o '  $(EXE_TARGET)' $(LINK_FLAGS)
  else
	@$(CXX) $(CXXFLAGS) $(STATIC_OBJECTS) -o '$(EXE_TARGET)' $(LINK_FLAGS)
  endif
else
 targets: $(SHARED_LIB_TARGET) $(STATIC_LIB_TARGET)
 $(SHARED_LIB_TARGET): objects/shared
	$(info $(target_build_fx)Building target '$(SHARED_LIB_TARGET)'...$(reset_fx))
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CCFLAGS)  $(SHARED_OBJECTS) -o '$(SHARED_LIB_TARGET)' -shared
  else
	@$(CXX) $(CXXFLAGS) $(SHARED_OBJECTS) -o '$(SHARED_LIB_TARGET)' -shared
  endif
 $(STATIC_LIB_TARGET): objects/static
	$(info $(target_build_fx)Building target '$(STATIC_LIB_TARGET)'...$(reset_fx))
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
	$(info $(install_fx)Installing target '$(EXE_TARGET)' to '$(DESTDIR)$(bindir)'...$(reset_fx))
	@$(INSTALL) -m755 '$(EXE_TARGET)' '$(DESTDIR)$(bindir)'
 .PHONY: install
else
 install: install/targets install/headers
 install/targets: install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET)
 install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET): install/%: %
	$(info $(install_fx)Installing target '$(@:install/%=%)' to '$(DESTDIR)$(libdir)'...$(reset_fx))
	@$(INSTALL) -m644 '$(@:install/%=%)' '$(DESTDIR)$(libdir)'
 install/headers:
	$(info $(install_fx)Installing headers to '$(DESTDIR)$(includedir)'...$(reset_fx))
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
	@rm -f '$(DESTDIR)$(bindir)/$(EXE_TARGET)' | \
		sed -E s/'(.*)'/'$(uninstall_fx)\1$(reset_fx)'/g
 .PHONY: uninstall
else
 uninstall: uninstall/targets uninstall/headers
 uninstall/targets: uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET)
 uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(DESTDIR)$(libdir)/$(@:uninstall/%=%)' | \
		sed -E s/'(.*)'/'$(uninstall_fx)\1$(reset_fx)'/g
 uninstall/headers:
	@rm -rfv '$(DESTDIR)$(includedir)/$(notdir $(INC))' | \
		sed -E s/'(.*)'/'$(uninstall_fx)\1$(reset_fx)'/g
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
	find '$(BIN)' -depth -type d -exec rm -dfv '{}' ';' 2>/dev/null \
		| sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g ; \
fi

ifeq "$(SOFTWARE)" "exe"
 clean: clean/objects clean/$(EXE_TARGET)
 .PHONY: clean

 clean/objects:
	@rm -rfv '$(BIN)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
 $(addprefix clean/,$(STATIC_OBJECTS)): %:
	@rm -fv '$(@:clean/%=%)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
	@$(_clean_empty_bin_dirs)
 .PHONY: clean/objects $(addprefix clean/,$(STATIC_OBJECTS))

 clean/$(EXE_TARGET):
	@rm -fv '$(EXE_TARGET)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
 .PHONY: clean/$(EXE_TARGET)
else
 clean: clean/objects clean/targets
 .PHONY: clean

 clean/objects:
	@rm -rfv '$(BIN)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
 clean/objects/shared:
	@rm -fv $(SHARED_OBJECTS) | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
	@$(_clean_empty_bin_dirs)
 clean/objects/static:
	@rm -fv $(STATIC_OBJECTS) | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
	@$(_clean_empty_bin_dirs)
 $(addprefix clean/,$(SHARED_OBJECTS) $(STATIC_OBJECTS)): %:
	@rm -fv '$(@:clean/%=%)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
	@$(_clean_empty_bin_dirs)
 .PHONY: clean/objects clean/objects/shared clean/objects/static

 clean/targets: clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)
 clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(@:clean/%=%)' | sed -E s/'(.*)'/'$(clean_fx)\1$(reset_fx)'/g
 .PHONY: clean/targets clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)
endif

# === version ================================================================ #

_version:
	@echo 1.0.0
.PHONY: _version
