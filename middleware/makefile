#
# @author       iota square [i2]
# <pre>
# ██╗ ██████╗ ████████╗ █████╗ ██████╗
# ██║██╔═══██╗╚══██╔══╝██╔══██╗╚════██╗
# ██║██║   ██║   ██║   ███████║ █████╔╝
# ██║██║   ██║   ██║   ██╔══██║██╔═══╝
# ██║╚██████╔╝   ██║   ██║  ██║███████╗
# ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝
# </pre>
#
# @date         14-09-2019
# @file         middleware/makefile
# @brief       	Makefile for Middleware.
#
# @copyright    GNU GPU v3
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Free Software, Hell Yeah!
#

ifeq ($(VERBOSE_LEVEL),2)
# All make debug messages will be printed
else
.SILENT:
endif

CFLAGS := $(patsubst -I%,-I../../%,$(CFLAGS))

SUBDIRS := FreeRTOSv10.2.1

.PHONY: subdirs $(SUBDIRS)
subdirs: ${SUBDIRS}

${SUBDIRS}:
	${MAKE} -C $@

.PHONY: clean
clean:
	-for d in $(SUBDIRS); do (echo "cleaning up in $$d"; cd $$d; $(MAKE) clean ); done

# *********************** (C) COPYRIGHT iota2 ***[i2]******END OF FILE**********
