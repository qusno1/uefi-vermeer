# vermeer firmware platform

The platform targets the Redmi K70 (vermeer), Qualcomm SM8550. It uses Kailua
platform support and the vermeer memory reservations from the pinned DTS and
stock firmware. Source and firmware inputs are recorded in the platform
configuration and import tools.

## Status

The firmware volume builds. It has not run on the phone, and the stock vermeer
`uefiplat.cfg` has not been imported: the UEFI allocation windows in
`MemoryMapLib.c` are still the reference platform's layout candidates, with this
board's three high DRAM banks added.

## Memory and firmware inputs

The stock ABL device tree of this board (HyperOS OS3.0.307.0.WNKCNXM, pulled
from `/sys/firmware/fdt`) describes a 16 GiB part. Its usable extents start at
`0x80000000` with carveouts, and continue at `0x880000000 + 0x38700000`,
`0x8C0000000 + 0x140000000` and `0xA00000000 + 0x200000000`. Its
`reserved-memory` node has 65 children.

`MemoryMapLib.c` carries 78 descriptors: the reference platform's reservations
plus the three high banks above. The 3 MiB FD at `0xa7100000` occupies the stock
4 MiB FD window at `0xa7000000`; the stock `uefi.elf` loads at `0xa7000000` with
`0x2CD000` bytes of ELF `PT_LOAD`.

The reference board aborted while clearing memory above `0x8BB300000`, so the
small `0x8B8900000` extent (`0x1E00000`) is kept out of the UEFI map until it is
verified here.

## Display and interrupts

ABL supplies a linear framebuffer and needs
`/reserved-memory/splash_region` (`0xb8000000`, `0x2b00000`) to keep the panel
scanning out; the boot image step restores that node from `[bootimg.dtb_node]`.

The panel is 1440x3200 and the stock boot argument names
`qcom,mdss_dsi_n11_42_02_0a_dsc_cmd`. The reference platform's N81A panel XMLs
therefore do not describe this board and are not in the firmware volume:
`Include/RAW.inc` makes `USE_CUSTOM_DISPLAY_DRIVER = 1` fail until the n11 XMLs
are extracted from this board's own UEFI image with their original FFS GUIDs.

With `VERMEER_VENDOR_HW = 0`, SimpleFbDxe publishes GOP for the framebuffer and
the previous stage's scanout continues. With `VERMEER_VENDOR_HW = 1`, vendor
initialization reaches ClockDxe and the panel becomes black while the backlight
stays on. That failure is inherited from the reference platform and has not been
diagnosed on this board.

SEC selects SP_ELx. `Resources/MuPatches/Gic-Spurious.patch` masks interrupts
with an unregistered handler, including IPCC INTID `0x105`.

## UniXNU integration

UniXNU supplies the application package and registrar. DarwinBoot loads the
XNU kernel and ADT sidecar. UniXNU-vermeer selects board firmware and boot-image
parameters. UniXNU-sm8550-common supplies shared XNU platform operations.

`UniXNURamDiskDxe` comes from UniXNU's shared package. It publishes the FDT
initrd as Block I/O; DiskIoDxe and FAT expose the payload filesystem.
`VermeerBootMemoryDxe` adds DRAM within the board's mapping limits: holes the
GCD does not know, in pieces of at least 16 MiB, capped at 1 GiB and below
4 GiB. Both modules are listed in the platform DSC and firmware volume.

## Verification report

Record the firmware configuration and source revisions, build result,
container inspection, device boot, GOP output, and interrupt behavior.
Record QEMU observations with their machine and boot inputs. Record pending
hardware checks with the required device or firmware inputs.

Host result at UniXNU-vermeer `c802711` and uefi-vermeer `009f9f7`:
`SILICIUM_UEFI.fd` built at 3145728 bytes; FVMAIN used 5565584 of 5566464 bytes
(880 free) and FVMAIN_COMPACT 1056872 of 3145728.
