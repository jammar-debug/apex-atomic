# =================================================================
#  apex-atomic
#  Base  : ghcr.io/ublue-os/base-main:latest (no desktop, NVIDIA
#          drivers baked in via ublue-akmod layer, always current
#          Fedora Atomic release)
#  Stack : niri  +  DankMaterialShell (dms)  +  DankGreeter  +  Steam (RPM)
# =================================================================

# ublue base-main already has:
#   • NVIDIA akmods (open + proprietary via ublue-os/akmods)
#   • RPMFusion repos (free + nonfree) pre-configured
#   • podman, distrobox, just, etc.
# It ships NO desktop environment, which is exactly what we want.
FROM ghcr.io/ublue-os/base-main:latest

LABEL org.opencontainers.image.title="apex-atomic"
LABEL org.opencontainers.image.description="Fedora Atomic: niri + DankMaterialShell + DankGreeter + NVIDIA + Steam"
LABEL org.opencontainers.image.source="https://github.com/jammar-debug/apex-atomic"

# -----------------------------------------------------------------
# 1.  Layer in our system_files overlay
# -----------------------------------------------------------------
COPY system_files/ /

# -----------------------------------------------------------------
# 2.  Enable COPRs and install everything in one transaction
#
#     avengemedia/danklinux  →  niri, quickshell, xwayland-satellite,
#                               cliphist, matugen, dsearch, dgop,
#                               dms-greeter (DankGreeter)
#     avengemedia/dms        →  dms (DankMaterialShell stable)
#
#     Steam comes from RPMFusion-nonfree, already enabled in ublue base.
# -----------------------------------------------------------------
RUN \
  # -- COPR: DankLinux ecosystem ------------------------------------
  dnf5 copr enable -y avengemedia/danklinux && \
  # -- COPR: DMS stable release -------------------------------------
  dnf5 copr enable -y avengemedia/dms && \
  \
  # -- Single install transaction ------------------------------------
  dnf5 install -y \
    niri \
    xwayland-satellite \
    dms \
    quickshell \
    dms-greeter \
    dsearch \
    dgop \
    cliphist \
    matugen \
    steam \
    polkit \
    acl \
    xdg-user-dirs \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    google-noto-fonts-common \
    google-noto-sans-fonts \
    ghostty \
    nautilus \
  && \
  \
  # -- Create DankGreeter cache directory ---------------------------
  # The greeter user needs write access to /var/cache/dms-greeter
  # for theme syncing (wallpapers, colour schemes).
  mkdir -p /var/cache/dms-greeter && \
  chown greeter:greeter /var/cache/dms-greeter && \
  \
  # -- Clean up -----------------------------------------------------
  dnf5 clean all && \
  ostree container commit

# -----------------------------------------------------------------
# 3.  Enable systemd services
# -----------------------------------------------------------------
RUN systemctl enable greetd.service && \
    systemctl enable dms-first-boot.service && \
    ostree container commit
