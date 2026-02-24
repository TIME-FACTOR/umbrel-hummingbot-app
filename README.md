# Run Hummingbot as an Umbrel Community App

This folder contains everything needed to run [Hummingbot](https://github.com/hummingbot/hummingbot) from the [Umbrel Community App Store](https://github.com/getumbrel/umbrel-community-app-store).

## How the Umbrel Community App Store works

1. **Template repo**: [getumbrel/umbrel-community-app-store](https://github.com/getumbrel/umbrel-community-app-store) is a template. You click "Use this template" to create your own GitHub repo (e.g. `yourname/umbrel-apps`).
2. **App store ID**: In `umbrel-app-store.yml` you set an `id` (e.g. `mystore`) and `name`. Every app in that store must have an app ID starting with that id (e.g. `mystore-hummingbot`).
3. **Each app** = one folder with:
   - `umbrel-app.yml` — name, description, icon, category, port (for the proxy)
   - `docker-compose.yml` — services; Umbrel injects `APP_DATA_DIR` for persistent data
   - Optional `data/` subdirs with `.gitkeep` for dirs that must exist

You then add your repo URL in Umbrel: **Settings → App Store → Add community app store** and install apps from it.

## What’s in this folder

- `umbrel-app-store.yml` — Example store (id: `mystore`, name: My App Store). Replace with your own.
- `mystore-hummingbot/` — The Hummingbot app (**developer version**, runs from source):
  - `umbrel-app.yml` — Listing for Umbrel
  - `docker-compose.yml` — Builds from `Dockerfile`, mounts `source/` so you can replace files for custom models
  - `Dockerfile` — Python + build deps + TA-Lib; runs Hummingbot from mounted source
  - `entrypoint.sh` — On first run clones the repo into `source/`; installs with `pip install -e` so your edits are used
  - `data/` — Placeholder dirs including `source/` (the Hummingbot repo lives here after first run)

**Developer version:** The app runs Hummingbot from the **source** folder, not the pre-built Docker image. On first start the container clones the repo into `source/`. Replace any files you need (e.g. for custom models) in that folder, then restart the app so changes apply. Hummingbot is a **CLI** app—use Terminal or SSH to attach. Optionally **Gateway** (DEX) is on port 15888.

## Step-by-step: run Hummingbot as a community app

### 1. Create your community app store repo

1. Go to [github.com/getumbrel/umbrel-community-app-store](https://github.com/getumbrel/umbrel-community-app-store).
2. Click **Use this template** → **Create a new repository**.
3. Name it (e.g. `umbrel-apps`), set visibility, create.

### 2. Add the Hummingbot app to your repo

1. Clone your new repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/umbrel-apps.git
   cd umbrel-apps
   ```
2. **Either** copy the contents of this folder into the repo:
   - Copy `umbrel-app-store.yml` (or merge its `id`/`name` into your existing one).
   - Copy the whole `mystore-hummingbot` folder into the repo root.
   - If your store id is not `mystore`, rename the app folder (e.g. `mystore-hummingbot` → `mystore-hummingbot`) and set the same id in `mystore-hummingbot/umbrel-app.yml` (e.g. `id: mystore-hummingbot`).
3. **Or** add Hummingbot as a second app next to the template’s “Hello World” app (keep `sparkles-hello-world`, add `sparkles-hummingbot` with `id: sparkles-hummingbot` in `umbrel-app.yml` and matching folder name).
4. Commit and push:
   ```bash
   git add .
   git commit -m "Add Hummingbot community app"
   git push
   ```

### 3. Add the store in Umbrel

1. Open your Umbrel dashboard.
2. Go to **Settings** → **App Store** (or **Community App Stores**).
3. Add your store URL: `https://github.com/YOUR_USERNAME/umbrel-apps` (or the raw repo URL Umbrel expects).
4. Save/refresh. Your store (e.g. “My App Store”) should appear with the Hummingbot app.

### 4. Install and run Hummingbot

1. In the app store, open your community store and click **Install** on Hummingbot.
2. After install, click **Open**. You’ll see an info page that says Hummingbot is running and how to connect.
3. **Connect to the CLI**:
   - **Option A (Umbrel Terminal)**: If Umbrel has an app or a “Terminal” for the app, open it and run:
     ```bash
     docker exec -it hummingbot_hummingbot_1 bash
     ```
     Then start the bot (e.g. `hummingbot` or whatever the image uses).
   - **Option B (SSH)**: SSH into your Umbrel device and run the same `docker exec` command.

Container name depends on your app store id (e.g. `mystore-hummingbot_hummingbot_1` or `sparkles-hummingbot_hummingbot_1`). Check with:

```bash
docker ps -a | grep hummingbot
```

### 5. Developer: custom models / replace files

The app runs from the **source** folder (e.g. `/mnt/data/umbrel/app-data/mystore-hummingbot/source/` on the Pi). On first start the container clones the Hummingbot repo there. To use your own code or custom models:

1. Replace or add files under `source/` (e.g. `source/hummingbot/...`).
2. Restart the app so the container runs `pip install -e` again and picks up changes.
3. Attach with `docker exec -it mystore-hummingbot_hummingbot_1 bash` and run `hummingbot`.

### 6. (Optional) Use Gateway for DEX

The included `docker-compose` can run **Hummingbot Gateway** (DEX middleware) so Hummingbot can talk to DEXs. Gateway listens on port **15888**. If you use it, point Hummingbot at your Umbrel host and port 15888 (e.g. in Hummingbot config or when prompted for Gateway URL).

---

## Files reference

| File | Purpose |
|------|--------|
| `umbrel-app-store.yml` | Store id and name (one per repo). |
| `mystore-hummingbot/umbrel-app.yml` | App listing: id, name, description, icon, category, port. |
| `mystore-hummingbot/docker-compose.yml` | Hummingbot service + info server (+ optional Gateway). |
| `mystore-hummingbot/data/*/.gitkeep` | So Umbrel creates data dirs (conf, logs, etc.). |

## Important notes

- **CLI only**: Hummingbot has no built-in web UI; you interact via terminal. The “Open” page in Umbrel is only for instructions.
- **Data**: All config and logs live under Umbrel’s app data (e.g. `APP_DATA_DIR`). Back up that path if you care about strategies and keys.
- **Store id**: The app folder name and `id` in `umbrel-app.yml` must match and must start with your store id (e.g. `mystore-hummingbot` for store id `mystore`).

For Hummingbot docs and support: [hummingbot.org](https://hummingbot.org) · [Discord](https://discord.gg/hummingbot) · [GitHub](https://github.com/hummingbot/hummingbot).
