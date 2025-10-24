# Static File Server

> **Note**: This is a learning project demonstrating a hybrid file serving setup. All services are configured for localhost development only and are not for production use.

This project sets up a hybrid file serving solution using:
- **Tusd** (Go): Resumable upload server for handling file uploads
- **Static-Web-Server** (Rust): High-performance static file server for downloads
- **Next.js Client**: Web interface for testing file uploads with progress tracking

## Architecture

- **Uploads**: Handled by tusd on port 8080 (uploads only, downloads disabled)
- **Downloads**: Handled by static-web-server on port 8787
- **Storage**: Files stored in `./files` directory
- **Metadata**: Tusd uses `.info` files for upload tracking

## LucidLines Dashboard

This project uses **LucidLines** - a terminal streaming server that provides a unified web interface for **monitoring logs** from all services simultaneously:

- **Log Aggregation**: View real-time output from tusd, static-web-server, and client in one place
- **Multi-terminal View**: No need to juggle multiple terminal tabs during development
- **Service Monitoring**: Track startup, errors, and activity across the entire stack
- **Web Interface**: Access logs via browser at `http://localhost:8888/`

**Services Monitored:**
- **SWS**: Static-Web-Server logs (port 8787 startup, requests, etc.)
- **tusd**: Upload server logs via Docker Compose (port 8080 activity, hooks, etc.)
- **client**: Next.js development server logs (port 3000 builds, requests, etc.)

Perfect for development and debugging - see everything happening across your services in real-time!

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Go (for scripts)
- Node.js and npm (for client and LucidLines)
- `wrk` (for benchmarking, optional)
- `jq` (for hooks to parse JSON metadata, required for non-Docker tusd installations)

### Setup

1. **Start LucidLines Dashboard** (recommended for monitoring):
   ```bash
   npm run dev
   ```
   Opens a web dashboard at `http://localhost:8888/` to monitor logs from all services.

2. **Alternative: Start services individually:**

   **Start Tusd** (for uploads):
   ```bash
   docker-compose up
   ```
   Tusd will be available at `http://localhost:8080/` for uploads only.

   **Start Static-Web-Server** (for downloads):
   ```bash
   ./sws.bash
   ```
   Static-Web-Server will be available at `http://localhost:8787/`.

   **Start the Next.js Client** (for testing uploads):
   ```bash
   cd client && npm run dev
   ```
   Client will be available at `http://localhost:3000/`.

   **Start Both Services (Non-Docker)**:
   ```bash
   ./run-parallel.bash
   ```
   Runs both tusd and static-web-server in parallel. Suitable for development and single-machine production deployments.

3. **Generate .info files** for existing files (optional, to make them recognizable by tusd):
   ```bash
   go run generate_info.go
   ```

## Usage

### Uploading Files

**Option 1: Use the Next.js Client (Recommended)**
1. Start the client: `cd client && npm run dev`
2. Open `http://localhost:3000/` in your browser
3. Click "Choose File" and select a file to upload
4. Watch the progress bar during upload
5. Uploaded files appear below with direct download links

**Option 2: Use tus-js-client directly**
Use any tus client to upload files to `http://localhost:8080/`. Example with tus-js-client:

```javascript
import { Upload } from 'tus-js-client';

const upload = new Upload(file, {
  endpoint: 'http://localhost:8080/',
  metadata: {
    filename: file.name,
    filetype: file.type,
  },
  onSuccess: () => console.log('Upload complete'),
  onError: (error) => console.error(error)
});

upload.start();
```

### Downloading Files
Access files via `http://localhost:8787/path/to/file`. For example:
- `http://localhost:8787/dir1/file_12394.txt`

### Managing .info Files

- **Generate** for existing files: `go run generate_info.go`
- **Remove all**: `./remove_info_files.sh` (warning: breaks resumable access)

## Scripts

| Script | Purpose |
|--------|---------|
| `generate_info.go` | Go script to create .info files for existing files |
| `remove_info_files.sh` | Remove all .info files |
| `benchmark.sh` | Compare performance between tusd and static-web-server |
| `run-parallel.bash` | Run both tusd and static-web-server in parallel (development/single-machine production) |
| `hooks/post-finish` | Post-upload hook to rename files and clean up .info files |
| `cleanup_stale_uploads.sh` | Script to remove stale .info files |
| `client/` | Next.js client application for testing uploads |
| `npm run dev` | Start LucidLines dashboard to monitor logs from all services |

## Download Performance

Based on benchmarks with `wrk` (4 threads, 100 connections, 30s):

| Server | Requests/sec | Transfer/sec | Latency |
|--------|-------------|--------------|---------|
| Static-Web-Server | 83,261 | 19.85 MB/s | 1.12ms |
| Tusd | 1,014 | 320.70 KB/s | 2.02ms |

**Key Findings:**
- Static-Web-Server is ~82x faster for static file serving
- Use tusd only for uploads, static-web-server for downloads
- Tusd has overhead from tus protocol even for GET requests

Run benchmarks with: `./benchmark.sh`

> **Note**: The current setup has tusd downloads disabled for production use. For running benchmarks that compare tusd vs static-web-server, temporarily enable tusd downloads by removing `-disable-download` from docker-compose.yml and disable hooks by removing the hooks volume mount.



## Configuration

### Tusd (docker-compose.yml)
- Port: 8080 (host) → 8081 (container)
- Base path: `/`
- Uploads: `./files` (mounted to `/srv/tusd-data/data`)
- Hooks: `./hooks` (post-upload cleanup)
- Downloads: Disabled (`-disable-download`) - remove this flag to enable GET requests for benchmarking

### Static-Web-Server (sws.bash)
- Port: 8787
- Root: `./files`

## Hooks

Tusd supports file hooks for customization:
- `hooks/post-finish`: Renames uploaded files to original filenames and removes .info files after successful uploads (requires `jq` for JSON parsing)

## Upload Failure Handling

Tusd handles different upload failure scenarios:

### Terminated Uploads
When clients explicitly terminate uploads (DELETE request), tusd automatically removes both `.info` and data files.

### Stale/Failed Uploads
Uploads that fail due to network issues, crashes, or abandoned connections leave behind `.info` files and partial data files.

**Automatic Cleanup:**
- Run `./cleanup_stale_uploads.sh [hours]` to remove uploads not modified in the specified hours (default: 24 hours)
- This removes both `.info` files and their corresponding partial data files
- Also cleans up orphaned `.info` files without data files

**Examples:**
- `./cleanup_stale_uploads.sh` (default: 24 hours)
- `./cleanup_stale_uploads.sh 12` (12 hours)
- `./cleanup_stale_uploads.sh 48` (48 hours)
- `./cleanup_stale_uploads.sh 1` (1 hour)

**Scheduled Cleanup:**
Add to cron for automatic hourly cleanup:
```bash
# Edit crontab
crontab -e

# Add this line (replace /path/to with actual path):
0 * * * * /path/to/minio/cleanup_stale_uploads.sh
```



## API Endpoints

### Tusd (Upload Only)
- `POST /`: Create upload
- `PATCH /<id>`: Upload data
- `HEAD /<id>`: Get upload status
- `GET /<id>`: **Disabled** (enable by removing `-disable-download` for benchmarking)

### Static-Web-Server (Download Only)
- `GET /*`: Serve static files

## Development

### Adding Files
1. **Use the Next.js client**: `cd client && npm run dev` then upload via `http://localhost:3000/`
2. **Upload directly**: Use any tus client to upload to `http://localhost:8080/`
3. **Place manually**: Put files directly in `./files` and run `go run generate_info.go` if needed for tusd recognition
4. **Access files**: Download via static-web-server at `http://localhost:8787/filename`

### Cleanup
- Remove .info files: `./remove_info_files.sh`
- Clean stale uploads: `./cleanup_stale_uploads.sh`
- Clean uploads: `rm -rf ./files/*`

## Production Deployment

For production environments, use the containerized setup with both services running in parallel:

### Using Docker Compose (Recommended)

1. **Deploy both services:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

2. **Check service status:**
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```

3. **View logs:**
   ```bash
   docker-compose -f docker-compose.prod.yml logs -f
   ```

### Production Features

- **Health Checks**: Automatic monitoring of service availability
- **Auto-restart**: Services restart automatically on failure
- **Log Rotation**: JSON logging with size limits
- **Security Headers**: CORS and security headers enabled for SWS
- **Compression**: Gzip compression enabled for faster downloads
- **Network Isolation**: Dedicated Docker network for service communication

### Alternative: Systemd Services (Non-Docker Production)

For production environments without Docker, use systemd services for process management:

1. **Install services natively:**
   ```bash
   # Install tusd
   go install github.com/tus/tusd/cmd/tusd@latest
   
   # Install static-web-server (choose one method)
   # Option 1: Download binary
   curl -L https://github.com/static-web-server/static-web-server/releases/latest/download/static-web-server-x86_64-unknown-linux-gnu.tar.gz | tar xz
   sudo mv static-web-server /usr/local/bin/
   
   # Option 2: Build from source
   cargo install static-web-server
   ```

2. **Create systemd service files:**

   **Tusd service** (`/etc/systemd/system/tusd.service`):
   ```ini
   [Unit]
   Description=Tusd Upload Server
   After=network.target

   [Service]
   Type=simple
   User=www-data
   WorkingDirectory=/path/to/minio
   ExecStart=/usr/local/bin/tusd -port 8080 -base-path / -hooks-dir ./hooks -disable-download -behind-proxy
   Restart=always
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

   **Static-Web-Server service** (`/etc/systemd/system/static-web-server.service`):
   ```ini
   [Unit]
   Description=Static Web Server
   After=network.target

   [Service]
   Type=simple
   User=www-data
   WorkingDirectory=/path/to/minio
   ExecStart=/usr/local/bin/static-web-server -p 8787 -d ./files --compression gzip --cors-allow-origins "*"
   Restart=always
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

3. **Enable and start services:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable tusd static-web-server
   sudo systemctl start tusd static-web-server
   ```

4. **Monitor services:**
   ```bash
   sudo systemctl status tusd
   sudo systemctl status static-web-server
   journalctl -u tusd -f
   journalctl -u static-web-server -f
   ```

**Benefits of systemd approach:**
- Automatic restarts on failure
- Proper process management
- Log integration with journald
- Resource limits and security controls
- Integration with monitoring systems