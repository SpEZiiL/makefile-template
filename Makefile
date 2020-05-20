#!/usr/bin/make -f
# C/C++ Makefile Template for applications and libraries.
# Copyright (C) 2020 Michael Federczuk
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

# === configuration ========================================================== #

SOFTWARE = exe|lib|hlib

ROOT = .

TARGETDIR = .
TESTDIR   = .

NAME    =
PACKAGE = $(NAME)
TARGET  = $(NAME)

SRC      = src
SRC_MAIN = src/main
SRC_TEST = src/test
INCLUDE  = include/$(PACKAGE)
BIN      = bin

TEST_CMD    = $(__built_in_test_cmd__)
MAIN_SOURCE = $(__auto_main_source__)

CLINKS    =
CXXLINKS  =
LINKS     =
LINK_DIRS =

CFLAGS   = -std=c17
CXXFLAGS = -std=c++17
FLAGS    = -Iinclude -Wall -Wextra

HOOKSCRIPT =

# ============================================================================ #



################################################################################
##                                                                            ##
## You should definitely know what you're doing when changing anything beyond ##
## this point.                                                                ##
##                                                                            ##
################################################################################



# === debug makefile ========================================================= #

-include _debug.mk

# === constants ============================================================== #

override TRUE  := x
override FALSE :=

# always use:
#   ifneq "$(...)" "$(FALSE)"
# DON'T use:
#   ifeq "$(...)" "$(TRUE)"
# as it might fail

override EXE_SOFTWARE  := exe
override LIB_SOFTWARE  := lib
override HLIB_SOFTWARE := hlib

override NO_TARGET      := :[no_target]:
override NO_SRC         := :[no_src]:
override NO_TEST        := :[no_test]:
override NO_BIN         := :[no_bin]:
override NO_INCLUDE     := :[no_include]:
override NO_TEST_CMD    := :[no_test_cmd]:
override NO_MAIN_SOURCE := :[no_main_source]:
override NO_HOOKSCRIPT  := :[no_hookscript]:

override BUILT_IN_TEST_CMD     := :[built_in_test_cmd]:
override __built_in_test_cmd__ := $(BUILT_IN_TEST_CMD)

override AUTO_MAIN_SOURCE_NO_RESULT  := :[auto_main_source_no_result]:
override AUTO_MAIN_SOURCE            := :[auto_main_source]:
override __auto_main_source__        := $(AUTO_MAIN_SOURCE)

# === custom conditional functions =========================================== #

# === strings === #

# expands to a non-empty string if argument 1 is an empty string, expands to an
# empty string otherwise
override not = $(if $(1),$(FALSE),$(TRUE))

# expands to a non-empty string if argument 1 is an empty string, expands to an
# empty string otherwise
override is_empty = $(call not,$(1))
# expands to a non-empty string if argument 1 is a non-empty string, expands to
# an empty string otherwise
override is_not_empty = $(call not,$(call is_empty,$(1)))

# expands to a non-empty string if argument 1 and 2 are equal, expands to an
# empty string otherwise
override is_equal = $(or \
	$(and \
		$(call is_empty,$(1)), \
		$(call is_empty,$(2)) \
	), \
	$(and \
		$(findstring $(1),$(2)), \
		$(findstring $(2),$(1)) \
	) \
)
# expands to a non-empty string if argument 1 and 2 are not equal, expands to an
# empty string otherwise
override is_not_equal = $(call not,$(call is_equal,$(1),$(2)))

# === variables === #

# expands to a non-empty string if the variable given as argument 1 is defined,
# expands to an empty string otherwise
override is_def = $(call is_not_equal,$(origin $(1)),undefined)
# expands to a non-empty string if the variable given as argument 1 is undefined,
# expands to an empty string otherwise
override is_undef = $(call not,$(call is_def,$(1)))

# expands to a non-empty string if the variable given as argument 1 is defined
# and is equal to argument 2, expands to an empty string otherwise
override is_value = $(and \
	$(call is_def,$(1)), \
	$(call is_equal,$($(1)),$(2)) \
)

# === files/directories/paths === #

# expands to a non-empty string if the path given as argument 1 exists, expands to
# an empty string otherwise
override exists = $(shell test -e '$(1)' && printf $(TRUE))

# expands to a non-empty string if the path given as argument 1 is a regular file,
# expands to an empty string otherwise
override is_file = $(shell test -f '$(1)' && printf $(TRUE))
# expands to a non-empty string if the path given as argument 1 is a directory,
# expands to an empty string otherwise
override is_dir = $(shell test -d '$(1)' && printf $(TRUE))

# expands to a non-empty string if the path given as argument 1 is executable,
# expands to an empty string otherwise
override is_executable = $(shell test -x '$(1)' && printf $(TRUE))

# expands to a non-empty string if the path given as argument 1 is accessable by
# the current user, expands to an empty string otherwise
override is_accessable = $(shell \
	if [ -d '$(1)' ]; then \
		test -r && test -x && printf $(TRUE); \
	else \
		test -r && printf $(TRUE); \
	fi \
)

# === colors ================================================================= #

# checks if the terminal supports colors
override COLOR_SUPPORT != case "$$TERM" in \
	xterm-color|*-256color) printf $(TRUE) ;; \
esac

# if the `color` variable is 'always', we force colored output, even if the
# terminal would not support it
# if the variable is 'never', we disable colored output, even if the terminal
# would support it
# any other value, and we enable it if the terminal supports colored output

ifneq "$(or \
	$(call is_equal,$(color),always), \
	$(and \
		$(call is_not_equal,$(color),never), \
		$(call is_not_empty,$(COLOR_SUPPORT)) \
	) \
)" "$(FALSE)"
 # reset:      0
 # bold:       1
 # italic:     3
 # underline:  4
 # black:     30  |  bright black:   90
 # red:       31  |  bright red:     91
 # green:     32  |  bright green:   92
 # yellow:    33  |  bright yellow:  93
 # blue:      34  |  bright blue:    94
 # magenta:   35  |  bright magenta: 95
 # cyan:      36  |  bright cyan:    96
 # white:     37  |  bright white:   97
 override _ascii_esc = $(shell printf '\033[$(1)m')

 override _green_clr_style_n      := 32
 override _yellow_clr_style_n     := 33
 override _blue_clr_style_n       := 34
 override _magenta_clr_style_n    := 35
 override _bright_red_clr_style_n := 91
 override _bold_style_n           := 1

 error_style        := $(_bright_red_clr_style_n);$(_bold_style_n)
 warning_style      := $(_yellow_clr_style_n)
 object_build_style := $(_blue_clr_style_n)
 target_build_style := $(_blue_clr_style_n);$(_bold_style_n)
 test_build_style   := $(_magenta_clr_style_n);$(_bold_style_n)
 install_style      := $(_green_clr_style_n)
 uninstall_style    := $(_bright_red_clr_style_n)
 clean_style        := $(_bright_red_clr_style_n)
 debug_style        := $(_magenta_clr_style_n)

 override reset_style        := $(call _ascii_esc,0)
 override error_style        := $(call _ascii_esc,$(error_style))
 override warning_style      := $(call _ascii_esc,$(warning_style))
 override object_build_style := $(call _ascii_esc,$(object_build_style))
 override target_build_style := $(call _ascii_esc,$(target_build_style))
 override test_build_style   := $(call _ascii_esc,$(test_build_style))
 override install_style      := $(call _ascii_esc,$(install_style))
 override uninstall_style    := $(call _ascii_esc,$(uninstall_style))
 override clean_style        := $(call _ascii_esc,$(clean_style))
 override debug_style        := $(call _ascii_esc,$(debug_style))
endif

override stylemsg = $($(1)_style)$(2)$(reset_style)

# === debug stuff ============================================================ #

override debug_var = $(if \
	$(call is_equal,$(__DEBUG),1), \
	$(info $(call stylemsg,debug,$(1):) $(call stylemsg,debug,')$($(1))$(call stylemsg,debug,')) \
)
override debug_ln = $(if \
	$(call is_equal,$(__DEBUG),1), \
	$(info ) \
)
# === error/warning message variables/functions ============================== #

override msg_software = building $(strip $(if \
	$(call is_equal,$(1),$(EXE_SOFTWARE)), \
	an executable, \
	$(if \
		$(call is_equal,$(1),$(LIB_SOFTWARE)), \
		a library, \
		$(if \
			$(call is_equal,$(1),$(HLIB_SOFTWARE)), \
			a header-only library \
		) \
	) \
))

override var_msg_used = the $(1) variable is used

override msg_tests_disabled = tests are disabled


override errmsg_makefile_unconfigured := The Makefile is unconfigured

override errmsg_invalid_software = Invalid software type ($(1))

override var_errmsg_undefined     = The $(1) variable is undefined
override var_errmsg_undefined_but = $(call var_errmsg_undefined,$(1)) but $(2)

override var_errmsg_empty = The $(1) variable is empty

override var_warnmsg_ignored      = The $(1) variable is ignored. Consider removing it
override var_warnmsg_ignored_when = The $(1) variable is ignored when $(2). Consider removing it

override var_warnmsg_useless_empty_var = The $(1) variable is unnecessary when it is empty. Consider removing it

override errmsg_file_not_exist      = The file '$(1)' does not exist
override errmsg_path_not_file       = The path '$(1)' does not lead to a file
override errmsg_file_not_accessable = The file '$(1)' is not accessable

override errmsg_dir_not_exist      = The directory '$(1)' does not exist
override errmsg_path_not_dir       = The path '$(1)' does not lead to a directory
override errmsg_dir_not_accessable = The directory '$(1)' is not accessable

override var_errmsg_file_not_exist      = The file '$($(1))' ($(1) variable) does not exist
override var_errmsg_path_not_file       = The path '$($(1))' ($(1) variable) does not lead to a file
override var_errmsg_file_not_accessable = The file '$($(1))' ($(1) variable) is not accessable

override var_errmsg_dir_not_exist      = The directory '$($(1))' ($(1) variable) does not exist
override var_errmsg_path_not_dir       = The path '$($(1))' ($(1) variable) does not lead to a directory
override var_errmsg_dir_not_accessable = The directory '$($(1))' ($(1) variable) is not accessable

override var_errmsg_paths_same = The paths '$($(1))' ($(1) variable) and '$($(2))' ($(2) variable) lead to the same location


override var_errmsg_not_basename = The string '$($(1))' ($(1) variable) is not a basename

override warnmsg_useless_link_dirs = The LINK_DIRS variable is unnecessary when no CLINKS, CXXLINKS or LINKS are set. Consider removing it

override errmsg_hookscript_not_exe = The hookscript ('$($(1))' ($(1) variable)) is not executable

override errmsg_object_ext_same = The shared object file extension ('$($(1))' ($(1) variable)) and the static object file extension ('$($(2))' ($(2) variable)) are equal

# === precondition functions ================================================= #

override err = $(error $(call stylemsg,error,$(1)))
override warn = $(warning $(call stylemsg,warning,$(1)))


override path = $(shell realpath -m '$(1)')


override require_var = $(if \
	$(call is_undef,$(1)), \
	$(call err,$(call var_errmsg_undefined,$(1))), \
	$(if \
		$(call is_empty,$($(1))), \
		$(call err,$(call var_errmsg_empty,$(1))) \
	) \
)
override require_var_but = $(if \
	$(call is_undef,$(1)), \
	$(call err,$(call var_errmsg_undefined_but,$(1),$(2))), \
	$(if \
		$(call is_empty,$($(1))), \
		$(call err,$(call var_errmsg_empty,$(1))) \
	) \
)

override ignore_var = $(if \
	$(call is_def,$(1)), \
	$(call warn,$(call var_warnmsg_ignored,$(1))) \
)
override ignore_var_when = $(if \
	$(call is_def,$(1)), \
	$(call warn,$(call var_warnmsg_ignored_when,$(1),$(2))) \
)

override useless_empty_var = $(if \
	$(and \
		$(call is_def,$(1)), \
		$(call is_empty,$($(1))) \
	), \
	$(call warn,$(call var_warnmsg_useless_empty_var,$(1))) \
)


override require_file = $(if \
	$(call not,$(call exists,$(call path,$(1)))), \
	$(call err,$(call errmsg_file_not_exist,$(1))), \
	$(if \
		$(call not,$(call is_file,$(call path,$(1)))), \
		$(call err,$(call errmsg_path_not_file,$(1))), \
		$(if \
			$(call not,$(call is_accessable,$(call path,$(1)))), \
			$(call err,$(call errmsg_file_not_accessable,$(1))) \
		) \
	) \
)
override require_dir = $(if \
	$(call not,$(call exists,$(call path,$(1)))), \
	$(call err,$(call errmsg_dir_not_exist,$(1))), \
	$(if \
		$(call not,$(call is_dir,$(call path,$(1)))), \
		$(call err,$(call errmsg_path_not_dir,$(1))), \
		$(if \
			$(call not,$(call is_accessable,$(call path,$(1)))), \
			$(call err,$(call errmsg_dir_not_accessable,$(1))) \
		) \
	) \
)


override require_var_file = $(if \
	$(call not,$(call exists,$(call path,$($(1))))), \
	$(call err,$(call var_errmsg_file_not_exist,$(1))), \
	$(if \
		$(call not,$(call is_file,$(call path,$($(1))))), \
		$(call err,$(call var_errmsg_path_not_file,$(1))), \
		$(if \
			$(call not,$(call is_accessable,$(call path,$($(1))))), \
			$(call err,$(call var_errmsg_file_not_accessable,$(1))) \
		) \
	) \
)
override require_var_dir = $(if \
	$(call not,$(call exists,$(call path,$($(1))))), \
	$(call err,$(call var_errmsg_dir_not_exist,$(1))), \
	$(if \
		$(call not,$(call is_dir,$(call path,$($(1))))), \
		$(call err,$(call var_errmsg_path_not_dir,$(1))), \
		$(if \
			$(call not,$(call is_accessable,$(call path,$($(1))))), \
			$(call err,$(call var_errmsg_dir_not_accessable,$(1))) \
		) \
	) \
)


override require_vars_not_same_paths = $(if \
	$(call is_equal,$(strip \
		$(call path,$($(1))) \
	),$(strip \
		$(call path,$($(2))) \
	)), \
	$(call err,$(call var_errmsg_paths_same,$(1),$(2))) \
)


override prep_path = $(shell realpath -ms --relative-to=. '$(ROOT)/$(1)')

override prep_var = $(eval override $(1) := $(strip $($(1))))
override prep_var_path = $(eval override $(1) := $(call prep_path,$($(1))))

# === preconditions ========================================================== #

# checking if the configuration variables have not bee changed
ifneq "$(and \
	$(call is_value,SOFTWARE,exe|lib|hlib), \
	\
	$(call is_value,ROOT,.), \
	\
	$(call is_value,TARGETDIR,.), \
	$(call is_value,TESTDIR,.), \
	\
	$(call is_value,NAME,), \
	$(call is_value,PACKAGE,$(NAME)), \
	$(call is_value,TARGET,$(NAME)), \
	\
	$(call is_value,SRC,src), \
	$(call is_value,SRC_MAIN,src/main), \
	$(call is_value,SRC_TEST,src/test), \
	$(call is_value,INCLUDE,include/$(PACKAGE)), \
	$(call is_value,BIN,bin), \
	\
	$(call is_value,TEST_CMD,$(__built_in_test_cmd__)), \
	$(call is_value,MAIN_SOURCE,$(__auto_main_source__)), \
	\
	$(call is_value,CLINKS,), \
	$(call is_value,CXXLINKS,), \
	$(call is_value,LINKS,), \
	$(call is_value,LINK_DIRS), \
	\
	$(call is_value,CFLAGS,-std=c17), \
	$(call is_value,CXXFLAGS,-std=c++17), \
	$(call is_value,FLAGS,-Iinclude -Wall -Wextra) \
	\
	$(call is_value,HOOKSCRIPT,) \
)" "$(FALSE)"
 $(call err,$(errmsg_makefile_unconfigured))
endif



# SOFTWARE variable
$(call require_var,SOFTWARE)
$(call prep_var,SOFTWARE)
ifneq "$(and \
	$(call is_not_equal,$(SOFTWARE),$(EXE_SOFTWARE)), \
	$(call is_not_equal,$(SOFTWARE),$(LIB_SOFTWARE)), \
	$(call is_not_equal,$(SOFTWARE),$(HLIB_SOFTWARE)) \
)" "$(FALSE)"
 $(call err,$(call errmsg_invalid_software,$(SOFTWARE)))
endif


# ROOT variable
$(call require_var,ROOT)
$(call prep_var,ROOT)
override ROOT := $(shell realpath -m --relative-to=. '$(ROOT)')
$(call require_var_dir,ROOT)


# TARGETDIR variable
$(call require_var,TARGETDIR)
$(call prep_var,TARGETDIR)
$(call prep_var_path,TARGETDIR)

# TESTDIR variable
$(call require_var,TESTDIR)
$(call prep_var,TESTDIR)
$(call prep_var_path,TESTDIR)


# NAME variable
$(call require_var,NAME)
$(call prep_var,NAME)

# PACKAGE variable
$(call require_var,PACKAGE)
$(call prep_var,PACKAGE)

# TARGET variable
ifneq "$(SOFTWARE)" "$(HLIB_SOFTWARE)"
 # exe or lib software

 $(call require_var,TARGET)
 $(call prep_var,TARGET)
 ifneq "$(findstring /,$(TARGET))" "$(FALSE)"
  $(call err,$(call var_errmsg_not_basename,TARGET))
 endif
 override TARGET := $(TARGETDIR)/$(TARGET)
 $(call prep_var_path,TARGET)
else
 # hlib software

 $(call ignore_var_when,TARGET,$(call msg_software,$(SOFTWARE)))
 override TARGET := $(NO_TARGET)
endif # exe or lib software?


# note about SRC, SRC_MAIN and SRC_TEST:
#  internally, we always use SRC_MAIN and SRC_TEST
#  if tests are supposed to be disabled, SRC_TEST will be set to NO_TEST

# SRC, SRC_MAIN & SRC_TEST variables
ifneq "$(SOFTWARE)" "$(HLIB_SOFTWARE)"
 # exe or lib software

 ifneq "$(call is_def,SRC_MAIN)" "$(FALSE)"
  # exe or lib software
  # SRC_MAIN defined

  $(call require_var,SRC_MAIN)
  $(call prep_var,SRC_MAIN)
  $(call prep_var_path,SRC_MAIN)
  $(call require_var_dir,SRC_MAIN)

  $(call require_var_but,SRC_TEST,$(call var_msg_used,SRC_MAIN))
  $(call prep_var,SRC_TEST)
  $(call prep_var_path,SRC_TEST)
  $(call require_var_dir,SRC_TEST)

  $(call ignore_var_when,SRC,$(call var_msg_used,SRC_MAIN))
  override SRC := $(NO_SRC)
 else
  # exe or lib software
  # SRC_MAIN undefined

  ifneq "$(call is_def,SRC)" "$(FALSE)"
   # exe or lib software
   # SRC_MAIN undefined
   # SRC defined

   $(call require_var,SRC)
   $(call prep_var,SRC)
   $(call prep_var_path,SRC)
   $(call require_var_dir,SRC)
   override SRC_MAIN := $(SRC)

   $(call ignore_var_when,SRC_TEST,$(call var_msg_used,SRC))
   override SRC_TEST := $(NO_TEST)
  else
   # exe or lib software
   # SRC_MAIN undefined
   # SRC undefined

   $(call require_var,SRC_MAIN)
  endif # SRC defined?
 endif # SRC_MAIN defined?
else
 # hlib software

 $(call ignore_var_when,SRC_MAIN,$(call msg_software,$(SOFTWARE)))
 $(call ignore_var_when,SRC,$(call msg_software,$(SOFTWARE)))

 ifneq "$(call is_def,SRC_TEST)" "$(FALSE)"
  # hlib software
  # SRC_TEST defined

  $(call require_var,SRC_TEST)
  $(call prep_var,SRC_TEST)
  $(call prep_var_path,SRC_TEST)
  $(call require_var_dir,SRC_TEST)
 else
  # hlib software
  # SRC_TEST undefined

  override SRC_TEST := $(NO_TEST)
 endif # SRC_TEST defined?

 override SRC      := $(NO_SRC)
 override SRC_MAIN := $(NO_SRC)
endif # exe or lib software?

# INCLUDE variable
ifneq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 # lib or hlib software

 $(call require_var,INCLUDE)
 $(call prep_var,INCLUDE)
 $(call prep_var_path,INCLUDE)
 $(call require_var_dir,INCLUDE)
else
 # exe software

 ifneq "$(call is_def,INCLUDE)" "$(FALSE)"
  # exe software
  # INCLUDE defined

 $(call require_var,INCLUDE)
 $(call prep_var,INCLUDE)
 $(call prep_var_path,INCLUDE)
 $(call require_var_dir,INCLUDE)
 else
  # exe software
  # INCLUDE undefined

  override INCLUDE := $(NO_INCLUDE)
 endif # INCLUDE defined?
endif # lib or hlib software?

# BIN variable
ifneq "$(SOFTWARE)" "$(HLIB_SOFTWARE)"
 # exe or lib software

 $(call require_var,BIN)
 $(call prep_var,BIN)
 $(call prep_var_path,BIN)
else
 # hlib software

 ifneq "$(SRC_TEST)" "$(NO_TEST)"
  # hlib software
  # SRC_TEST used

  $(call require_var_but,BIN,$(call var_msg_used,SRC_TEST))
  $(call prep_var,BIN)
  $(call prep_var_path,BIN)
 else
  # hlib software
  # SRC_TEST unused

  override BIN := $(NO_BIN)
 endif # SRC_TEST used?
endif # exe or lib software?


# TEST_CMD variable
ifneq "$(SRC_TEST)" "$(NO_TEST)"
 # tests enabled

 $(call require_var,TEST_CMD)
 $(call prep_var,TEST_CMD)
else
 # test disabled

 $(call ignore_var_when,TEST_CMD,$(msg_tests_disabled))
endif # tests enabled?

# MAIN_SOURCE variable
ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 # exe software

 ifneq "$(SRC_TEST)" "$(NO_TEST)"
  # exe software
  # tests enabled

  $(call require_var,MAIN_SOURCE)
  $(call prep_var,MAIN_SOURCE)

  ifneq "$(MAIN_SOURCE)" "$(AUTO_MAIN_SOURCE)"
   # exe software?
   # tests enabled
   # main source not automatically detected

   $(call require_file,$(SRC_MAIN)/$(MAIN_SOURCE))
  endif # main source not automatically detected?
 else
  # exe software
  # tests disabled

  $(call ignore_var_when,MAIN_SOURCE,$(msg_tests_disabled))
 endif # tests enabled?
else
 # lib or hlib software?

 $(call ignore_var_when,MAIN_SOURCE,$(call msg_software,$(SOFTWARE)))
endif # exe software?


# CLINKS, CXXLINKS, LINKS & LINK_DIRS variables
ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 # exe software

 ifneq "$(and \
	 $(call is_not_empty,$(LINK_DIRS)), \
	 $(call is_empty,$(strip $(CLINKS)$(CXXLINKS)$(LINKS))) \
 )" "$(FALSE)"
  # LINK_DIRS not empty and no links defined

  $(call warn,$(warnmsg_useless_link_dirs))
 else
  # LINK_DIRS empty or links defined

  $(call useless_empty_var,CLINKS)
  $(call useless_empty_var,CXXLINKS)
  $(call useless_empty_var,LINKS)
  $(call useless_empty_var,LINK_DIRS)
 endif # LINK_DIRS not empty and no links defined?

 override CLINKS   := $(strip $(LINKS) $(CLINKS))
 override CXXLINKS := $(strip $(LINKS) $(CXXLINKS))
else
 # lib or hlib software

 $(call ignore_var_when,CLINKS,$(call msg_software,$(SOFTWARE)))
 $(call ignore_var_when,CXXLINKS,$(call msg_software,$(SOFTWARE)))
 $(call ignore_var_when,LINKS,$(call msg_software,$(SOFTWARE)))
 $(call ignore_var_when,LINK_DIRS,$(call msg_software,$(SOFTWARE)))
endif # exe software?


# CFLAGS, CXXFLAGS & FLAGS variables
$(call useless_empty_var,CFLAGS)
$(call useless_empty_var,CXXFLAGS)
$(call useless_empty_var,FLAGS)
override CFLAGS   := $(strip $(FLAGS) $(CFLAGS))
override CXXFLAGS := $(strip $(FLAGS) $(CXXFLAGS))


# HOOKSCRIPT variable
ifneq "$(call is_def,HOOKSCRIPT)" "$(FALSE)"
 # HOOKSCRIPT defined

 $(call require_var,HOOKSCRIPT)
 $(call prep_var,HOOKSCRIPT)
 $(call prep_var_path,HOOKSCRIPT)
 $(call require_var_file,HOOKSCRIPT)

 ifeq "$(call is_executable,$(HOOKSCRIPT))" "$(FALSE)"
  # hookscript not executable

  $(call err,$(call errmsg_hookscript_not_exe,HOOKSCRIPT))
 endif # hookscript not executable?
endif # HOOKSCRIPT defined?



# making sure that no paths lead to the same location:

# TARGET variable
ifneq "$(TARGET)" "$(NO_TARGET)"
 # target used

 $(call require_vars_not_same_paths,TARGET,ROOT)
 ifneq "$(SRC_MAIN)" "$(NO_SRC)"
  # target used
  # src used

  ifneq "$(SRC)" "$(NO_SRC)"
   # target used
   # src used
   # SRC variable used

   $(call require_vars_not_same_paths,TARGET,SRC)
  else
   # target used
   # src used
   # SRC_MAIN variable used

   $(call require_vars_not_same_paths,TARGET,SRC_MAIN)
  endif # SRC variable used?
 endif # src used?

 ifneq "$(SRC_TEST)" "$(NO_TEST)"
  # target used
  # tests enabled

  $(call require_vars_not_same_paths,TARGET,SRC_TEST)
 endif # tests enabled?

 ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
  # target used
  # include used

  $(call require_vars_not_same_paths,TARGET,INCLUDE)
 endif # include used?

 ifneq "$(BIN)" "$(NO_BIN)"
  # target used
  # bin used

  $(call require_vars_not_same_paths,TARGET,BIN)
 endif # bin used?
endif # target used?

# ROOT variable
ifneq "$(SRC_MAIN)" "$(NO_SRC)"
 # src used

 ifneq "$(SRC)" "$(NO_SRC)"
  # src used
  # SRC variable used

  $(call require_vars_not_same_paths,ROOT,SRC)
 else
  # src used
  # SRC_MAIN variable used

  $(call require_vars_not_same_paths,ROOT,SRC_MAIN)
 endif # SRC variable used?
endif # src used?
ifneq "$(SRC_TEST)" "$(NO_TEST)"
 # tests enabled

 $(call require_vars_not_same_paths,ROOT,SRC_TEST)
endif # tests enabled?
ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
 # include used

 $(call require_vars_not_same_paths,ROOT,INCLUDE)
endif # include used?
ifneq "$(BIN)" "$(NO_BIN)"
 # bin used

 $(call require_vars_not_same_paths,ROOT,BIN)
endif # bin used?

# SRC/SRC_MAIN variable
ifneq "$(SRC_MAIN)" "$(NO_SRC)"
 # src used

 ifneq "$(SRC)" "$(NO_SRC)"
  # src used
  # SRC variable used

  ifneq "$(SRC_TEST)" "$(NO_TEST)"
   # src used
   # SRC variable used
   # tests enabled

   $(call require_vars_not_same_paths,SRC,SRC_TEST)
  endif # tests enabled?
  ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
   # src used
   # SRC variable used
   # include used

   $(call require_vars_not_same_paths,SRC,INCLUDE)
  endif # include used?
  ifneq "$(BIN)" "$(NO_BIN)"
   # src used
   # SRC variable used
   # bin used

   $(call require_vars_not_same_paths,SRC,BIN)
  endif # bin used?
 else
  # src used
  # SRC_MAIN variable used

  ifneq "$(SRC_TEST)" "$(NO_TEST)"
   $(call require_vars_not_same_paths,SRC_MAIN,SRC_TEST)
  endif
  ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
   $(call require_vars_not_same_paths,SRC_MAIN,INCLUDE)
  endif
  ifneq "$(BIN)" "$(NO_BIN)"
   $(call require_vars_not_same_paths,SRC_MAIN,BIN)
  endif
 endif # SRC variable used?
endif # src used?

# SRC_TEST variable
ifneq "$(SRC_TEST)" "$(NO_TEST)"
 # tests enabled

 ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
  # tests enabled
  # include used

  $(call require_vars_not_same_paths,SRC_TEST,INCLUDE)
 endif # include used?

 ifneq "$(BIN)" "$(NO_BIN)"
  # tests enabled
  # bin used

  $(call require_vars_not_same_paths,SRC_TEST,BIN)
 endif # bin used?
endif # tests enabled?

# INCLUDE
ifneq "$(INCLUDE)" "$(NO_INCLUDE)"
 # include used

 ifneq "$(BIN)" "$(NO_BIN)"
  # include used
  # bin used

  $(call require_vars_not_same_paths,INCLUDE,BIN)
 endif # bin used?
endif # include used?

# === variables ============================================================== #

# conventional make variables
SHELL ?= /bin/sh
prefix      ?= /usr/local
exec_prefix ?= $(prefix)
bindir      ?= $(exec_prefix)/bin
includedir  ?= $(prefix)/include
libdir      ?= $(exec_prefix)/lib

# normally, shared object files also have the .o extension, to hold them apart
# we're going to use .so (which literally stands for shared object).
# it's important that these two variables are different
shared_object_ext ?= so
static_object_ext ?= o

# better not change those
shared_lib_prefix ?= lib
static_lib_prefix ?= lib
shared_lib_suffix ?= .so
static_lib_suffix ?= .a

# unix like executables usually don't have a suffix
exe_prefix ?=
exe_suffix ?=

# specifically for the test executables
test_prefix ?= $(exe_prefix)
test_suffix ?= _test$(exe_suffix)

# in case these are not defined for some reason
CC      ?= cc
CXX     ?= c++
AR      ?= ar
INSTALL ?= install

# === variable conditions ==================================================== #

ifeq "$(shared_object_ext)" "$(static_object_ext)"
 $(call err,$(call errmsg_object_ext_same,shared_object_ext,static_object_ext))
endif

# === pre-rule stuff ========================================================= #

# prevent make from automatically building object files from source files
.SUFFIXES:

# === custom functions ======================================================= #

# checks if argument 1 and 2 are equal
override _eq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))

# gets the target executable name of the test tuple
override _test_target = $(word 1,$(subst :, ,$(1)))
# gets the source file of the test tuple
override _test_source = $(word 2,$(subst :, ,$(1)))

# pipe commands into this function to color/style them
# argument should be an ascii escape sequence (the *_fx variables)
override _color_pipe = sed -E s/'.*'/'$(1)\0$(reset_fx)'/g

# gets the object file from a source file
override _static_object = $(BIN)/$(1).$(static_object_ext)
override _shared_object = $(BIN)/$(1).$(shared_object_ext)

# finds all C language source files in directory of argument 1
override _find_c_sources   = $(foreach \
		__file, \
		$(shell find '$(1)' \
				-type f \
				-name '*.[ci]' \
		), \
		$(__file:$(1)/%=%) \
)
# finds all C++ language source files in directory of argument 1
override _find_cxx_sources = $(foreach \
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

# === constants ============================================================== #

override LINK_FLAGS := $(addprefix -L,$(LINK_DIRS)) $(addprefix -l,$(LINKS))

# all main C/C++ source files
override C_SOURCES   := $(sort $(call _find_c_sources,$(SRC_MAIN)))
override CXX_SOURCES := $(sort $(call _find_cxx_sources,$(SRC_MAIN)))

# checking if source files were found
ifeq "$(C_SOURCES)$(CXX_SOURCES)" ""
 $(error $(error_fx)No source files found$(reset_fx))
endif

# all test C/C++ source files
override TEST_C_SOURCES   := $(sort $(call _find_c_sources,$(SRC_TEST)))
override TEST_CXX_SOURCES := $(sort $(call _find_cxx_sources,$(SRC_TEST)))

# shared objects
override SHARED_C_OBJECTS   := $(sort $(foreach __source_file,$(C_SOURCES), \
	$(call _shared_object,$(__source_file)) \
))
override SHARED_CXX_OBJECTS := $(sort $(foreach __source_file,$(CXX_SOURCES), \
	$(call _shared_object,$(__source_file)) \
))
override SHARED_OBJECTS     := $(sort $(SHARED_C_OBJECTS) $(SHARED_CXX_OBJECTS))

# static objects
override STATIC_C_OBJECTS   := $(sort $(foreach __source_file,$(C_SOURCES), \
	$(call _static_object,$(__source_file)) \
))
override STATIC_CXX_OBJECTS := $(sort $(foreach __source_file,$(CXX_SOURCES), \
	$(call _static_object,$(__source_file)) \
))
override STATIC_OBJECTS     := $(sort $(STATIC_C_OBJECTS) $(STATIC_CXX_OBJECTS))

# targets
override SHARED_LIB_TARGET := $(shared_lib_prefix)$(TARGET)$(shared_lib_suffix)
override STATIC_LIB_TARGET := $(static_lib_prefix)$(TARGET)$(static_lib_suffix)
override EXE_TARGET        := $(exe_prefix)$(TARGET)$(exe_suffix)

# test tuples
# these are in format of <test executable name>:<test source file>
override C_TESTS   := $(sort $(foreach __source_file,$(TEST_C_SOURCES), \
	$(test_prefix)$(basename $(notdir $(__source_file)))$(test_suffix):$(__source_file) \
))
override CXX_TESTS := $(sort $(foreach __source_file,$(TEST_CXX_SOURCES), \
	$(test_prefix)$(basename $(notdir $(__source_file)))$(test_suffix):$(__source_file) \
))

# extracts just the targets from the test tuples
override TEST_C_TARGETS   := $(sort $(foreach __test,$(C_TESTS), \
	$(call _test_target,$(__test)) \
))
override TEST_CXX_TARGETS := $(sort $(foreach __test,$(CXX_TESTS), \
	$(call _test_target,$(__test)) \
))
override TEST_TARGETS     := $(sort $(TEST_C_TARGETS) $(TEST_CXX_TARGETS))

# === default rule =========================================================== #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 all: target
 .PHONY: all
else
 all: targets
 .PHONY: all
endif

# === universe rule ========================================================== #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 ifneq "$(SRC_TEST)" "/dev/null"
  _universe: target tests
	$(warning $(warning_fx)The `_universe` target is deprecated, use the `universe` target instead$(reset_fx))
  .PHONY: _universe
 else
  _universe: target
	$(warning $(warning_fx)The `_universe` target is deprecated, use the `universe` target instead$(reset_fx))
  .PHONY: _universe
 endif
else
 ifneq "$(SRC_TEST)" "/dev/null"
  _universe: targets tests
	$(warning $(warning_fx)The `_universe` target is deprecated, use the `universe` target instead$(reset_fx))
  .PHONY: _universe
 else
  _universe: targets
	$(warning $(warning_fx)The `_universe` target is deprecated, use the `universe` target instead$(reset_fx))
  .PHONY: _universe
 endif
endif

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 ifneq "$(SRC_TEST)" "/dev/null"
  universe: target tests
  .PHONY: universe
 else
  universe: target
  .PHONY: universe
 endif
else
 ifneq "$(SRC_TEST)" "/dev/null"
  universe: targets tests
  .PHONY: universe
 else
  universe: targets
  .PHONY: universe
 endif
endif

# === building object files ================================================== #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 objects: $(STATIC_OBJECTS)
 $(STATIC_C_OBJECTS):   $(call _static_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC)  $(CFLAGS)  -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(call _static_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects
else
 objects: objects/shared objects/static
 objects/shared: $(SHARED_OBJECTS)
 objects/static: $(STATIC_OBJECTS)
 $(SHARED_C_OBJECTS):   $(call _shared_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC)  $(CFLAGS)  -c '$<' -o '$@' -fPIC
 $(SHARED_CXX_OBJECTS): $(call _shared_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@' -fPIC
 $(STATIC_C_OBJECTS):   $(call _static_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CC)  $(CFLAGS)  -c '$<' -o '$@'
 $(STATIC_CXX_OBJECTS): $(call _static_object,%): $(SRC_MAIN)/%
	@mkdir -p '$(dir $@)'
	$(info $(object_build_fx)Building file '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) -c '$<' -o '$@'
 .PHONY: objects objects/shared objects/static
endif

# === building targets ======================================================= #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 target: $(EXE_TARGET)
 $(EXE_TARGET): $(STATIC_OBJECTS)
	$(info $(target_build_fx)Building target '$@'...$(reset_fx))
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CFLAGS)   $^ -o '$@' $(LINK_FLAGS)
  else
	@$(CXX) $(CXXFLAGS) $^ -o '$@' $(LINK_FLAGS)
  endif
  .PHONY: target
else
 targets: $(SHARED_LIB_TARGET) $(STATIC_LIB_TARGET)
 $(SHARED_LIB_TARGET): $(SHARED_OBJECTS)
	$(info $(target_build_fx)Building target '$@'...$(reset_fx))
  ifeq "$(CXX_SOURCES)" ""
	@$(CC)  $(CFLAGS)   $^ -o '$@' -shared
  else
	@$(CXX) $(CXXFLAGS) $^ -o '$@' -shared
  endif
 $(STATIC_LIB_TARGET): $(STATIC_OBJECTS)
	$(info $(target_build_fx)Building target '$@'...$(reset_fx))
	@$(AR) rs '$@' $^ 2>/dev/null
 .PHONY: targets
endif

# === testing ================================================================ #

ifneq "$(SRC_TEST)" "/dev/null"
 # finds the test source file to a given test target from all test tuples
 override _find_test_source = $(foreach __test,$(C_TESTS) $(CXX_TESTS), \
	$(if \
		$(call _eq,$(1),$(call _test_target,$(__test))), \
		$(call _test_source,$(__test)) \
	) \
 )

 ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
  # static objects without the main file
  ifdef MAIN
   override STATIC_C_OBJECTS_FOR_EXE_TEST   := $(sort $(filter-out $(call _static_object,$(MAIN)),$(STATIC_C_OBJECTS)))
   override STATIC_CXX_OBJECTS_FOR_EXE_TEST := $(sort $(filter-out $(call _static_object,$(MAIN)),$(STATIC_CXX_OBJECTS)))
   override STATIC_OBJECTS_FOR_EXE_TEST     := $(sort $(STATIC_C_OBJECTS_FOR_EXE_TEST) $(STATIC_CXX_OBJECTS_FOR_EXE_TEST))
  endif

  tests: $(TEST_TARGETS)
  .SECONDEXPANSION:
  $(TEST_C_TARGETS): %:   $(STATIC_C_OBJECTS_FOR_EXE_TEST) \
                          $(SRC_TEST)/$$(strip $$(call _find_test_source,%))
	$(info $(test_build_fx)Building test '$@'...$(reset_fx))
	@$(CC)  $(CFLAGS)   $^ -o '$@'
  .SECONDEXPANSION:
  $(TEST_CXX_TARGETS): %: $(STATIC_OBJECTS_FOR_EXE_TEST) \
                          $(SRC_TEST)/$$(strip $$(call _find_test_source,%))
	$(info $(test_build_fx)Building test '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) $^ -o '$@'
  test: $(TEST_TARGETS)
	@$(TEST) $(addprefix ./,$^)
  .PHONY: tests test
 else
  tests: $(TEST_TARGETS)
  .SECONDEXPANSION:
  $(TEST_C_TARGETS): %:   $(STATIC_C_OBJECTS) \
                          $(SRC_TEST)/$$(strip $$(call _find_test_source,%))
	$(info $(test_build_fx)Building test '$@'...$(reset_fx))
	@$(CC)  $(CFLAGS)   $^ -o '$@'
  .SECONDEXPANSION:
  $(TEST_CXX_TARGETS): %: $(STATIC_OBJECTS) \
                          $(SRC_TEST)/$$(strip $$(call _find_test_source,%))
	$(info $(test_build_fx)Building test '$@'...$(reset_fx))
	@$(CXX) $(CXXFLAGS) $^ -o '$@'
  test: $(TEST_TARGETS)
	@$(TEST) $(addprefix ./,$^)
  .PHONY: tests test
 endif
endif

# === installing ============================================================= #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 install: install/target
 install/target: install/$(EXE_TARGET)
 install/$(EXE_TARGET): install/%: %
	$(info $(install_fx)Installing target '$(@:install/%=%)' to '$(DESTDIR)$(bindir)'...$(reset_fx))
	@mkdir -p '$(DESTDIR)$(bindir)'
	@$(INSTALL) -m755 '$(@:install/%=%)' '$(DESTDIR)$(bindir)'
 .PHONY: install install/target install/$(EXE_TARGET)
else
 install: install/targets install/headers
 install/targets: install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET)
 install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET): install/%: %
	$(info $(install_fx)Installing target '$(@:install/%=%)' to '$(DESTDIR)$(libdir)'...$(reset_fx))
	@mkdir -p '$(DESTDIR)$(libdir)'
	@$(INSTALL) -m644 '$(@:install/%=%)' '$(DESTDIR)$(libdir)'
 install/headers:
	$(info $(install_fx)Installing headers to '$(DESTDIR)$(includedir)'...$(reset_fx))
	@mkdir -p '$(DESTDIR)$(includedir)'
	@cp -r '$(INC)' '$(DESTDIR)$(includedir)'
 .PHONY: install install/targets \
         install/$(SHARED_LIB_TARGET) install/$(STATIC_LIB_TARGET) \
         install/headers
endif

# === uninstalling =========================================================== #

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 uninstall: uninstall/target
 uninstall/target: uninstall/$(EXE_TARGET)
 uninstall/$(EXE_TARGET):
	@rm -fv '$(DESTDIR)$(bindir)/$(@:uninstall/%=%)' | \
		$(call _color_pipe,$(uninstall_fx))
 .PHONY: uninstall uninstall/target uninstall/$(EXE_TARGET)
else
 uninstall: uninstall/targets uninstall/headers
 uninstall/targets: uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET)
 uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(DESTDIR)$(libdir)/$(@:uninstall/%=%)' | \
		$(call _color_pipe,$(uninstall_fx))
 uninstall/headers:
	@rm -rfv '$(DESTDIR)$(includedir)/$(notdir $(INC))' | \
		$(call _color_pipe,$(uninstall_fx))
 .PHONY: uninstall uninstall/targets \
         uninstall/$(SHARED_LIB_TARGET) uninstall/$(STATIC_LIB_TARGET) \
         uninstall/headers
endif

# === cleaning =============================================================== #

override _clean_empty_dir = if [ -d '$(1)' ]; then \
	find '$(1)' -depth -type d -exec rm -dfv '{}' ';' 2>/dev/null \
		| $(call _color_pipe,$(clean_fx)) ; \
fi

override CLEANING_STATIC_OBJECTS := $(addprefix clean/,$(STATIC_OBJECTS))
override CLEANING_SHARED_OBJECTS := $(addprefix clean/,$(SHARED_OBJECTS))
override CLEANING_OBJECTS        := $(CLEANING_SHARED_OBJECTS) \
                                    $(CLEANING_STATIC_OBJECTS)

override CLEANING_TEST_TARGETS := $(addprefix clean/,$(TEST_TARGETS))

ifeq "$(SOFTWARE)" "$(EXE_SOFTWARE)"
 ifneq "$(SRC_TEST)" "/dev/null"
  clean: clean/objects clean/target clean/tests
  .PHONY: clean
 else
  clean: clean/objects clean/target
  .PHONY: clean
 endif

 clean/objects: $(CLEANING_STATIC_OBJECTS)
 clean/$(BIN):
	@rm -rfv '$(BIN)' | $(call _color_pipe,$(clean_fx))
 $(CLEANING_STATIC_OBJECTS): %:
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
	@$(call _clean_empty_dir,$(BIN))
 .PHONY: clean/objects $(CLEANING_STATIC_OBJECTS)

 clean/target: clean/$(EXE_TARGET)
 clean/$(EXE_TARGET):
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
 .PHONY: clean/target clean/$(EXE_TARGET)

 ifneq "$(SRC_TEST)" "/dev/null"
  clean/tests: $(CLEANING_TEST_TARGETS)
  $(CLEANING_TEST_TARGETS): %:
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
  .PHONY: clean/tests $(CLEANING_TEST_TARGETS)
 endif
else
 ifneq "$(SRC_TEST)" "/dev/null"
  clean: clean/objects clean/targets clean/tests
  .PHONY: clean
 else
  clean: clean/objects clean/targets
  .PHONY: clean
 endif

 clean/objects: clean/objects/shared clean/objects/static
 clean/objects/shared: $(CLEANING_SHARED_OBJECTS)
 clean/objects/static: $(CLEANING_STATIC_OBJECTS)
 clean/$(BIN):
	@rm -rfv '$(BIN)' | $(call _color_pipe,$(clean_fx))
 $(CLEANING_OBJECTS): %:
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
	@$(call _clean_empty_dir,$(BIN))
 .PHONY: clean/objects \
         clean/objects/shared clean/objects/static \
         $(CLEANING_OBJECTS)

 clean/targets: clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)
 clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET): %:
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
 .PHONY: clean/targets clean/$(SHARED_LIB_TARGET) clean/$(STATIC_LIB_TARGET)

 ifneq "$(SRC_TEST)" "/dev/null"
  clean/tests: $(CLEANING_TEST_TARGETS)
  $(CLEANING_TEST_TARGETS): %:
	@rm -fv '$(@:clean/%=%)' | $(call _color_pipe,$(clean_fx))
  .PHONY: clean/tests $(CLEANING_TEST_TARGETS)
 endif
endif

# === version ================================================================ #

_version:
	@echo 2.3.0
.PHONY: _version

# = other.mk ================================================================= #

-include other.mk
