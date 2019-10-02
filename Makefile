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

