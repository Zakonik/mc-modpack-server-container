# mc-modpack-server-container

A Docker container for hosting any Minecraft modpack server. Provide a direct URL to a server pack `.zip` file and the container will download, extract, configure, and run it automatically — no manual setup required.

## Features

- Automatic modpack download and extraction on first start
- EULA acceptance via environment variable
- Configurable JVM memory allocation on first start
- `server.properties` auto-generated from environment variables on first start
- Persistent server data via Docker bind mount
- Runs as a non-root user (`minecraft:999`)
- RCON port exposed locally only (`127.0.0.1`)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/Zakonik/mc-modpack-server-container.git
   cd mc-modpack-server-container
   ```

2. **Create your `.env` file**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your values — see [Environment Variables](#environment-variables) below.

3. **Build and start the container**

   ```bash
   docker compose build
   docker compose up -d
   ```

4. **Check logs**

   ```bash
   docker compose logs -f
   ```

On the first start, the container downloads the modpack ZIP from `SERVER_PACK_URL`, extracts it,
generates `server.properties` from your environment variables, and launches the server.
On subsequent starts, both the download and the `server.properties` generation are skipped automatically.

> ⚠️ **EULA:** You must set `EULA=true` in your `.env` file to accept the
> [Minecraft End User License Agreement](https://www.minecraft.net/en-us/eula) before the server will start.

## Environment Variables

Copy `.env.example` to `.env` and adjust the values to your needs.
All variables are grouped by function below.

### Container Setup

| Variable | Required | Default | Description |
|---|---|---|---|
| `SERVER_PACK_URL` | Yes *(first start only)* | *(empty)* | Direct URL to the server pack `.zip` file |
| `EULA` | Yes | `false` | Set to `true` to accept the [Minecraft EULA](https://www.minecraft.net/en-us/eula) |
| `HOST_SERVER_PATH` | Yes | *(empty)* | Absolute path on the host where server files will be stored (Docker bind mount) |

> **Note:** `SERVER_PACK_URL` is only required on the first container start.
> Once the pack is downloaded and extracted, this variable can be removed from `.env`.

### JVM Settings

| Variable | Required | Default | Description |
|---|---|---|---|
| `JVM_XMX` | No | `8G` | Maximum RAM allocated to the JVM |
| `JVM_XMS` | No | `4G` | Initial RAM allocated to the JVM |

### Server Startup

| Variable | Required | Default | Description |
|---|---|---|---|
| `START_SCRIPT` | No | `start.sh` | Name of the startup script inside the extracted server pack |

### Server Configuration (`server.properties`)

These variables are used to generate `server.properties` on the first container start.
If a variable is not set, the listed default value will be used.

| Variable | Default | `server.properties` key | Description |
|---|---|---|---|
| `MC_MOTD` | `Minecraft Server` | `motd` | Message displayed in the server list |
| `MC_MAX_PLAYERS` | `20` | `max-players` | Maximum number of simultaneous players |
| `MC_DIFFICULTY` | `easy` | `difficulty` | `peaceful` \| `easy` \| `normal` \| `hard` |
| `MC_GAMEMODE` | `survival` | `gamemode` | `survival` \| `creative` \| `adventure` \| `spectator` |
| `MC_HARDCORE` | `false` | `hardcore` | Enable hardcore mode (permanent ban on death) |
| `MC_PVP` | `true` | `pvp` | Allow player-vs-player combat |
| `MC_LEVEL_SEED` | *(empty — random)* | `level-seed` | World generation seed |
| `MC_LEVEL_NAME` | `world` | `level-name` | Name of the world folder |
| `MC_LEVEL_TYPE` | *(empty — `DEFAULT`)* | `generator-settings` | World type (e.g. `FLAT`, `LARGEBIOMES`, or a modded preset) |
| `MC_VIEW_DISTANCE` | `10` | `view-distance` | Chunk render distance (3–32); higher values use more RAM |
| `MC_SPAWN_PROTECTION` | `16` | `spawn-protection` | Block radius around spawn protected from non-ops (`0` = disabled) |
| `MC_ONLINE_MODE` | `true` | `online-mode` | Authenticate players with Mojang servers; set `false` for offline/LAN play |
| `MC_WHITELIST` | `false` | `white-list` | Restrict the server to whitelisted players only |

### RCON (Remote Console)

| Variable | Required | Default | Description |
|---|---|---|---|
| `MC_ENABLE_RCON` | No | `false` | Enable RCON remote console access |
| `MC_RCON_PASSWORD` | **Yes if RCON enabled** | *(empty)* | RCON password — startup will fail if this is empty when `MC_ENABLE_RCON=true` |

> **Security:** The RCON port (`25575`) is bound to `127.0.0.1` only and is not exposed to the internet.

## Java Version

The container is built on **Java 21** (`eclipse-temurin:21-jre-jammy`), suitable for Minecraft 1.20.5+.

To use a different Java version, override the base image at build time:

```bash
docker compose build --build-arg BASE_IMAGE=eclipse-temurin:17-jre-jammy
```

| Java version | Base image | Minecraft versions |
|---|---|---|
| Java 8 | `eclipse-temurin:8-jre-jammy` | 1.12.2 and older |
| Java 17 | `eclipse-temurin:17-jre-jammy` | 1.18 – 1.20.4 |
| Java 21 | `eclipse-temurin:21-jre-jammy` | 1.20.5+ |

## Startup Sequence

On the first container start, the following steps run in order:

1. **Check EULA** — creates `eula.txt` if `EULA=true`, otherwise exits with an error
2. **Download & extract** the modpack ZIP from `SERVER_PACK_URL`
3. **Patch variables** — updates `variables.txt` in the extracted pack (if present)
4. **Generate `server.properties`** — from `MC_*` environment variables
5. **Start the server** — runs the `START_SCRIPT` from the extracted pack

On subsequent starts, steps 1–4 are skipped automatically.

## Known Limitations

- **Single Java version per image:** The image is built with a fixed Java version.
  Support for pre-built multi-tag images (e.g. `java8`, `java17`, `java21`) is planned.
  See [#20](https://github.com/Zakonik/mc-modpack-server-container/issues/20).
- **Direct ZIP links only:** `SERVER_PACK_URL` must point to a direct `.zip` download.
  CurseForge, Modrinth, and other platform-specific URLs are not supported.
- **No automatic mod updates:** The container does not update mods after the initial installation.
- **`server.properties` is only generated once:** Changing `MC_*` variables after the first start has no effect.
- **`variables.txt` is only changed once:** Changing `JVM_*` variables after the first start has no effect.

## Project Structure

```
.
├── Dockerfile                          # Container image definition
├── compose.yaml                        # Docker Compose configuration
├── .env.example                        # Template for environment variables
└── Scripts/
    ├── ContainerStart.sh               # Container entrypoint — orchestrates startup
    ├── CheckEula.sh                    # Validates and writes eula.txt
    ├── ChangeVariables.sh              # Patches variables.txt in the extracted server pack
    └── GenerateServerProperties.sh     # Generates server.properties from MC_* env variables
```

## License

This project is licensed under the **GNU General Public License v3.0**.
See the [LICENSE](LICENSE) file for details.
