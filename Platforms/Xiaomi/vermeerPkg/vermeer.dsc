##
#  Copyright (c) 2011 - 2022, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2020, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#  Copyright (c) Microsoft Corporation.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = vermeer
  PLATFORM_GUID                  = 4BF6E6C5-9F8B-4172-AC95-77D9C49A66F1
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/vermeerPkg
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = RELEASE|DEBUG
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = vermeerPkg/vermeer.fdf
  USE_CUSTOM_DISPLAY_DRIVER      = 0

  #
  # 0 = Mu drivers only. The previous stage's display keeps scanning out, so
  #     the boot manager is visible without any vendor hardware driver.
  # 1 = also load the stock vendor hardware drivers (SMEM, clocks, RPMh, UFS,
  #     USB, charger, ...). Their initialization currently blanks the panel.
  #
  VERMEER_VENDOR_HW                = 0

  #
  # 0 = SM8550-AB
  # 1 = SM8550-AC
  #
  SOC_TYPE                       = 0

!include KailuaPkg/KailuaPkg.dsc.inc

!if ($(USE_CUSTOM_DISPLAY_DRIVER) == 1) && ($(VERMEER_VENDOR_HW) == 0)
  !error The stock DisplayDxe chain needs VERMEER_VENDOR_HW = 1
!endif

[PcdsFixedAtBuild]
  #
  # DDR Memory
  #
  gArmTokenSpaceGuid.PcdSystemMemoryBase|0x80000000

  #
  # UEFI Stack
  #
  gArmPlatformTokenSpaceGuid.PcdCPUCoresStackBase|0xA760D000
  gArmPlatformTokenSpaceGuid.PcdCPUCorePrimaryStackSize|0x40000

  #
  # SMBIOS
  #
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemManufacturer|"Xiaomi"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemModel|"vermeer"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"vermeer"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"vermeer"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemBoardModel|"vermeer"

  #
  # Simple Frame Buffer
  #
  # Active size from the panel timing of this board: the stock boot argument names
  # qcom,mdss_dsi_n11_42_02_0a_dsc_cmd, a 1440x3200 mode. Without these the DEBUG
  # frame-buffer log draws nothing after SEC clears "Display Reserved", leaving a
  # black screen. ABL's scan-out stride is assumed equal to the width; unverified.
  #
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferWidth|1440
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferHeight|3200
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferColorDepth|32
  # Scale 3 gives 56 lines. The log wraps, so the screen always shows the
  # newest lines; the platform debug level is left unchanged.
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferFontScale|3
  # Pause per log line so a video of the screen shows what loads last.
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferDelay|30000


  #
  # Platform PEI
  #
  gQcomPkgTokenSpaceGuid.PcdPlatformType|"LA"
!if $(VERMEER_VENDOR_HW) == 0
  # Intermittent stall right after "MMU: enabled" (int-103 photos): PlatformPeim scanned the stock UEFI's leftover FD window and
  # called into its scheduler protocol. Without the stock vendor drivers nothing reads those HOBs.
  gQcomPkgTokenSpaceGuid.PcdBuildXblHobs|FALSE
!endif

[LibraryClasses]
  #
  # Memory Libraries
  #
  MemoryMapLib|vermeerPkg/Library/MemoryMapLib/MemoryMapLib.inf

  #
  # QCOM Libraries
  #
  ConfigurationMapLib|vermeerPkg/Library/ConfigurationMapLib/ConfigurationMapLib.inf

[Components]
  #
  # ACPI Tables
  #
  UniXNUPkg/Application/UniXNU/UniXNU.inf
  UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf
  vermeerPkg/Drivers/VermeerDisplayDepexDxe/VermeerDisplayDepexDxe.inf
  vermeerPkg/Drivers/VermeerGopLogDxe/VermeerGopLogDxe.inf
  vermeerPkg/Drivers/VermeerBootMemoryDxe/VermeerBootMemoryDxe.inf
  UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.inf
  vermeerPkg/Drivers/VermeerKeyInputDxe/VermeerKeyInputDxe.inf
  DarwinBootPkg/Driver/DarwinBoot.inf

[LibraryClasses]
  UniXNULib|UniXNUPkg/Library/UniXNULib/UniXNULib.inf
  FdtLib|MdePkg/Library/BaseFdtLib/BaseFdtLib.inf
