# apex-atomic justfile
# Requires: podman, just
# Built for: jammar-debug/apex-atomic

IMAGE      := "apex-atomic"
REGISTRY   := "ghcr.io/jammar-debug"
TAG        := "latest"
FULL_REF   := REGISTRY / IMAGE + ":" + TAG

# ── Build ─────────────────────────────────────────────────────────
# Build the image locally with podman
build:
    podman build \
        --tag {{IMAGE}}:{{TAG}} \
        .

# Build and push to GHCR
build-push: build
    podman tag {{IMAGE}}:{{TAG}} {{FULL_REF}}
    podman push {{FULL_REF}}

# ── Rebase ────────────────────────────────────────────────────────
# Rebase your running Atomic system onto the locally-built image
rebase-local:
    rpm-ostree rebase \
        ostree-unverified-registry:localhost/{{IMAGE}}:{{TAG}}

# Rebase onto the published GHCR image
rebase:
    rpm-ostree rebase \
        ostree-unverified-registry:{{FULL_REF}}

# ── Dev ───────────────────────────────────────────────────────────
# Drop into a shell inside the image for debugging
shell:
    podman run --rm -it {{IMAGE}}:{{TAG}} bash

# Show image info
info:
    podman inspect {{IMAGE}}:{{TAG}} | jq '.[0].Config.Labels'
