# Developer image: run Hummingbot from source. Default is built-in clone; mount your own
# at /home/hummingbot/source (app-data/source) to use custom models / replaced files.
# pandas-ta>=0.4.71b requires Python >=3.12
FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libffi-dev \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# TA-Lib from source (Hummingbot dependency); --build needed for aarch64/Pi
RUN wget -q http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
    && tar -xzf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib/ \
    && ./configure --build=aarch64-unknown-linux-gnu --prefix=/usr \
    && make && make install \
    && cd .. && rm -rf ta-lib ta-lib-0.4.0-src.tar.gz

ENV PYTHONUNBUFFERED=1
WORKDIR /home/hummingbot

# Pre-install pandas-ta so "pip install -e" does not fail (requires Python >=3.12)
RUN pip install --no-cache-dir "pandas-ta>=0.4.71b0"

# ttyd for browser-based CLI (Pi = aarch64)
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
    arm64)  TTYD_ARCH=aarch64 ;; \
    amd64)  TTYD_ARCH=x86_64 ;; \
    *) TTYD_ARCH=x86_64 ;; esac \
    && wget -q "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" -O /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# No pre-install: you must put a Hummingbot clone in app-data/source/ (developer version).
# First run: clone into source/, then restart the app. Replace files in source/ for custom models.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
