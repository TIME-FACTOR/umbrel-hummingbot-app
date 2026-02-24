# Developer image: run Hummingbot from source. Default is built-in clone; mount your own
# at /home/hummingbot/source (app-data/source) to use custom models / replaced files.
FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libffi-dev \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# TA-Lib from source (Hummingbot dependency)
RUN wget -q http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
    && tar -xzf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib/ && ./configure --prefix=/usr && make && make install \
    && cd .. && rm -rf ta-lib ta-lib-0.4.0-src.tar.gz

ENV PYTHONUNBUFFERED=1
WORKDIR /home/hummingbot

# No pre-install: you must put a Hummingbot clone in app-data/source/ (developer version).
# First run: clone into source/, then restart the app. Replace files in source/ for custom models.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
