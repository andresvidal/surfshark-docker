FROM arm32v7/alpine:latest
RUN apk add --no-cache openvpn curl && \
    rm -rf /tmp/*

# Uncommet the follwoing line to use Docker healthcheck
# HEALTHCHECK --interval=60s --timeout=15s --start-period=120s CMD curl -L 'https://api.ipify.org'

VOLUME ["/vpn"]
ENTRYPOINT ["openvpn"]
