# Wrapper around getumbrel/app-proxy that injects UMBREL_AUTH_SECRET, JWT_SECRET, MANAGER_IP
# at runtime from the auth container so the proxy starts correctly every time (dashboard, reboot).
FROM getumbrel/app-proxy:1.0.0
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
