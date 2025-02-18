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
# @date         07-09-2019
# @file         makefile
# @brief       	Makefile for IOTA2 HUB application.
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

NAME               := IOTA2_HUB

GLOBAL_DEFINES     := $(NAME)
GLOBAL_DEFINES     += STM32F40XX
export GLOBAL_DEFINES

TOOLS_ROOT         := $(CURDIR)/tools
TOOLCHAIN_PREFIX   := arm-none-eabi-
TOOLCHAIN_PATH     := $(TOOLS_ROOT)/ARM_GNU/Linux64/bin/

# MAP file parser
MAP_FILE_PARSER    := $(TOOLS_ROOT)/utilities/map_parser.pl

# Default disable make verbose level
VERBOSE_LEVEL      ?= 0

ifeq ($(VERBOSE_LEVEL),2)
GLOBAL_DEFINES += VERBOSE_LEVEL=2
else ifeq ($(VERBOSE_LEVEL),1)
GLOBAL_DEFINES += VERBOSE_LEVEL=1
else ifeq ($(VERBOSE_LEVEL),0)
GLOBAL_DEFINES += VERBOSE_LEVEL=0
.SILENT:
endif

# ------------------------------------------------------------------------------
# Compiler Paths
# ------------------------------------------------------------------------------
export CC      := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gcc
export CCDEP   := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gcc
export LD      := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gcc
export AR      := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)ar
export AS      := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gcc
export OBJCOPY := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objcopy
export OBJDUMP := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objdump
export GDB     := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gdb
export GCOV    := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)gcov
export SIZE    := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)size

OUTPUT_ROOT = build
ifeq ($(RELEASE), yes)
OUTPUT      = $(OUTPUT_ROOT)/$(NAME)/release
else
OUTPUT      = $(OUTPUT_ROOT)/$(NAME)/debug
endif

# ------------------------------------------------------------------------------
# Executables
# ------------------------------------------------------------------------------
ELF         = $(OUTPUT)/$(NAME).elf
BIN         = $(OUTPUT)/$(NAME).bin
HEX         = $(OUTPUT)/$(NAME).hex
LST         = $(OUTPUT)/$(NAME).list
MAP         = $(OUTPUT)/$(NAME).map
COV         = $(OUTPUT)/GCOV/

GIT_HASH   := $(shell git describe --dirty --always --abbrev=0)

CPU         = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard
STM32_OPT   = -DSTM32F407xx -DSTM32F407xx -DENABLE_RTOS_AWARE_HAL
STM32_OPT  += -DUSE_FULL_ASSERT -DENABLE_ASSERT
OTHER_OPT   = "-D__weak=__attribute__((weak))"
OTHER_OPT  += "-D__packed=__attribute__((__packed__))"
LDSCRIPT    = ./STM32F407IGTx_FLASH.ld

DRV_DIR    := ./drivers
MDL_DIR    := ./middleware

LIBINC     := -Iapp/inc
LIBINC     += -Iiota2/i2_Interface_Driver/inc
LIBINC     += -Iiota2/i2_STM32F4xx_HAL_Driver/inc
LIBINC     += -I$(DRV_DIR)/CMSIS/Include
LIBINC     += -I$(DRV_DIR)/CMSIS/RTOS/Template
LIBINC     += -I$(DRV_DIR)/CMSIS/Device/ST/STM32F4xx/Include
LIBINC     += -I$(DRV_DIR)/STM32F4xx_HAL_Driver/Inc
LIBINC     += -I$(MDL_DIR)/FreeRTOSv10.2.1/FreeRTOS/Source/include
LIBINC     += -I$(MDL_DIR)/FreeRTOSv10.2.1/FreeRTOS/Source/portable/GCC/ARM_CM4F

LIBS       := ./$(DRV_DIR)/STM32F4xx_HAL_Driver/lib_stm32f4xx_hal.a
LIBS       += ./$(MDL_DIR)/FreeRTOSv10.2.1/FreeRTOS/lib_freertos_v10_2_1.a

INCLUDES    = $(LIBINC)
CFLAGS     += $(CPU) $(STM32_OPT) $(OTHER_OPT)
CFLAGS     += -fno-common -fno-short-enums
CFLAGS     += $(INCLUDES) -std=gnu99 -DGIT_VERSION=\"$(GIT_HASH)\"
CFLAGS     += -Wall -Werror -Wfatal-errors

ASFLAGS     = $(CFLAGS) -x assembler-with-cpp
LDFLAGS     = -Wl,--gc-sections,-Map=$(MAP),-cref -fno-short-enums
LDFLAGS    += -Wl,--no-enum-size-warning -T $(LDSCRIPT) $(CPU) -coverage
ARFLAGS     = cr
OBJFLAGS_C  = -Obinary
OBJFLAGS_D  = -S

# ------------------------------------------------------------------------------
# Build Type Modifiers
# ------------------------------------------------------------------------------
ifeq ($(RELEASE), yes)
CFLAGS 	   += -Os
LDFLAGS    += --specs=nosys.specs
else
xSTM32_OPT += -DENABLE_DEBUG
CFLAGS 	   += -ggdb -g3 -Og
LDFLAGS    += --specs=rdimon.specs -Og
endif

export CFLAGS
export ARFLAGS

# ------------------------------------------------------------------------------
# Code Coverage Computation
#   Adding -coverage to both CFLAGS and LDFLAGS
#   - This will enable both -fprofile-arcs and -ftest-coverage flags
# ------------------------------------------------------------------------------
ifeq ($(CODE_COV), yes)
COVERAGE   += -coverage
GCOV_PREFIX = $(COV)
GCOV_PREFIX_STRIP = 1
endif

VPATH       = app/src:
VPATH      += iota2/i2_Interface_Driver/src:
VPATH      += iota2/i2_STM32F4xx_HAL_Driver/src:
VPATH      += $(DRV_DIR)/CMSIS/Device/ST/STM32F4xx/Source/Templates:
VPATH      += $(DRV_DIR)/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc:

ASMS        = $(DRV_DIR)/CMSIS/Device/ST/STM32F4xx/Source/ \
              Templates/gcc/startup_stm32f407xx.s

SRCS        = $(DRV_DIR)/CMSIS/Device/ST/STM32F4xx/Source/ \
              Templates/system_stm32f4xx.c
SRCS       += app/src/main.c
SRCS       += app/src/stm32f4xx_it.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_assert.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_common.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_clock.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_gpio.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_rtc.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_uart.c
SRCS       += iota2/i2_STM32F4xx_HAL_Driver/i2_stm32f4xx_hal_spi.c
SRCS       += iota2/i2_Interface_Driver/src/i2_fifo.c
SRCS       += iota2/i2_Interface_Driver/src/i2_led.c
SRCS       += iota2/i2_Interface_Driver/src/i2_font5x7.c
SRCS       += iota2/i2_Interface_Driver/src/i2_oled_ssd1306.c


ASMS_TEMP  := $(notdir $(ASMS))
SRCS_TEMP  := $(notdir $(SRCS))

AOBJS      := $(patsubst %.s, $(OUTPUT_ROOT)/%.o, $(ASMS_TEMP) )
OBJS       := $(patsubst %.c, $(OUTPUT_ROOT)/%.o, $(SRCS_TEMP) )

DEPS        = $(AOBJS:.o=.d)
DEPS       += $(OBJS:.o=.d)

all: $(OUTPUT) $(ELF) $(BIN) $(HEX)
	$(OBJDUMP) $(OBJFLAGS_D) $(ELF) > $(LST)
	$(SIZE) $(ELF)
	@echo "\n"
	$(MAP_FILE_PARSER) -w $(MAP)
	@echo HEAD GIT HASH : $(GIT_HASH)
	@echo Make finished

flash: $(BIN)
	@echo "Starting Flashing Target..."
	st-flash --format binary write $< 0x8000000

erase:
	@echo "Erasing Target..."
	st-flash erase

$(OUTPUT):
ifeq ($(RELEASE), yes)
	@echo "Initiating RELEASE build..."
else
	@echo "Initiating DEBUG build..."
endif
	mkdir -p $(OUTPUT)
	mkdir -p $(COV)

$(ELF): $(LIBS) $(AOBJS) $(OBJS)
	$(CC) $(AOBJS) $(OBJS) $(LDFLAGS) $(LIBS) -o $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary -S $< $@

$(LIBS): libs

libs:
	@echo Building libraries...
	@$(MAKE) -C $(DRV_DIR)
	@$(MAKE) -C $(MDL_DIR)

libclean: clean
	@echo Cleaning libraries...
	@$(MAKE) -C $(DRV_DIR) clean
	@$(MAKE) -C $(MDL_DIR) clean

get_mem_map:
	@echo "Detailed Memory Mapping:"
	$(SIZE) $(AOBJS) $(OBJS) $(LIBS)
	@echo "\n\nExecutables:"
	$(SIZE) $(ELF) $(HEX)
	$(MAP_FILE_PARSER) -w $(MAP)

clean:
	@echo Removing executables...
	rm -fr $(OUTPUT_ROOT)
	@$(MAKE) -C $(DRV_DIR) clean
	@$(MAKE) -C $(MDL_DIR) clean

$(OUTPUT_ROOT)/%.o: %.c
ifeq ($(VERBOSE_LEVEL),1)
	@echo cc $<
endif
	@$(CC) $(CFLAGS) $(COVERAGE) -c $< -o $@ -MMD -MF $(@:.o=.d)

$(OUTPUT_ROOT)/%.o: %.s
ifeq ($(VERBOSE_LEVEL),1)
	@echo as $<
endif
	@$(AS) $(ASFLAGS) $(COVERAGE) -c -o $@ $<

get_code_cov:
	@echo "#################################"
	@echo "#   Computing code coverage...   "
	@echo "#################################"
	$(GCOV) -k -c -d **/*.gcno

test: $(AOBJS) $(OBJS)
	@echo ----- ASM -----
	@echo $(ASMS)
	@echo ----- SRC -----
	@echo $(SRCS)
	@echo ---- AOBJ -----
	@echo $(AOBJS)
	@echo ----- OBJ -----
	@echo $(OBJS)
	@echo ----- DEP -----
	@echo $(DEPS)

gcc_path:
	@echo "Set paths for toolchain:"
	@echo "\tCC:      $(CC)"
	@echo "\tCCDEP:   $(CCDEP)"
	@echo "\tLD:      $(LD)"
	@echo "\tAR:      $(AR)"
	@echo "\tAS:      $(AS)"
	@echo "\tOBJCOPY: $(OBJCOPY)"
	@echo "\tOBJDUMP: $(OBJDUMP)"
	@echo "\tGDB:     $(GDB)"
	@echo "\tGCOV:    $(GCOV)"
	@echo "\tSIZE:    $(SIZE)"

help:
	@echo "==== $(NAME) ===="
	@echo "Make Options:"
	@echo "[all]           make complete project"
	@echo "[libs]          make libraries again"
	@echo "[get_mem_map]   Get Detailed memory profiling"
	@echo "[clean]         Clean complete project"
	@echo "[libclean]      Clean all libraries"
	@echo "[test]          Test complete project by test making all targets"
	@echo "[gcc_path]      Display all configured GCC paths"
	@echo "[flash]         Flash build to target"
	@echo "[erase]         Erase target"
	@echo "[get_code_cov]  Compute code coverage reports"
	@echo "\nMake Configurations:"
	@echo "[VERBOSE_LEVEL]"
	@echo "   Define the make verbose level to print debug messages"
	@echo "     0 : No make debug message will be printed <default>"
	@echo "     1 : Only additional make messages will be printed"
	@echo "     2 : All debug messages of make will be printed"
	@echo "[RELEASE]"
	@echo "   yes : Make Release build, else Debug build will be made"
	@echo "[CODE_COV]"
	@echo "   yes : Compile with code coverage flags"

# *********************** (C) COPYRIGHT iota2 ***[i2]******END OF FILE**********
