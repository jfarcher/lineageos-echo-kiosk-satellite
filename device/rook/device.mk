#
# What the Echo Spot (1st gen) gets on top of the Echo Spot tree in
# sources/device/amazon/rook, which lineage_rook.mk inherits. stage-tree.sh
# copies device/rook/ to device/kiosk-satellite/rook in the tree.
#
# NOT TESTED ON HARDWARE. The audio values below are the Echo Show 5 (2nd
# gen)'s, as a starting point. The Echo Spot has a different codec
# (TLV320AIC32X4), a 6 channel microphone FPGA firmware and a 4 microphone
# array, so each of them needs tuning on a real Spot.
#

# The network name EchoService gives the Spot: echo-spot-ks and the end of
# its serial.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.echo.hostname=echo-spot-ks

# Kiosk Satellite's MIC capture stays raw, as on the Echo Show 5 (2nd gen):
# the image's echo canceller (common/audio/amznaec) stays loaded but passes
# the microphones through. persist.vendor.amznaec.enable 1 brings it back.
# The gain and engine are the Echo Show 5 (2nd gen)'s until measured.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.amznaec.enable=0 \
    ro.vendor.amznaec.engine=2 \
    ro.vendor.amznaec.gain_db=20

# EchoParts' noise suppression off on a fresh install, so the audio HAL
# wrapper does not send every MIC recording through Amazon's VoIP pipeline.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.audio.noise_suppression=0

# Media volume 10 of 15 on a fresh install, as on the Echo Show 5 (2nd gen).
# Not measured on the Spot's speaker.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.media_vol_default=10

# The button is not set up yet: ro.echo.privacy_hold and
# ro.echo.button_long_press stay unset until the Spot's privacy circuit is
# known (the Echo Show 5 and 8 each behave differently).
