// Board raw files must come from vermeer firmware, not QRD8550.
// The partition configuration is a vendor input imported by the board
// preflight once the vermeer firmware bring-up needs it; nothing consumes it
// while the vendor hardware stack is disabled.
!if $(VERMEER_VENDOR_HW) == 1
  FILE FREEFORM = A1E235DE-E825-4591-9623-C43175811826 {
    SECTION UI = "SecParti.cfg"
    SECTION RAW = Binaries/vermeer/RawFiles/SecParti.cfg
  }
!endif

// The stock panel data of this board is not imported yet. The K70 boots with
// qcom,mdss_dsi_n11_42_02_0a_dsc_cmd, so the reference platform's N81A XMLs do
// not apply and are not listed here: USE_CUSTOM_DISPLAY_DRIVER = 1 must fail
// until Binaries/vermeer/RawFiles carries the n11 XMLs with their original FFS
// GUIDs and UI names taken from this board's own UEFI image.
!if $(USE_CUSTOM_DISPLAY_DRIVER) == 1
  !error vermeer panel XMLs are not imported: extract them from the stock UEFI image first
!endif
