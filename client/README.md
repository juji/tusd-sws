# Tusd + Static-Web-Server Upload Client

A Next.js client application that demonstrates file uploads using the tus protocol with tusd server, and displays uploaded files served by static-web-server.

## Features

- **Resumable Uploads**: Uses tus-js-client for reliable file uploads to tusd
- **Progress Tracking**: Real-time upload progress with visual progress bar
- **Image Display**: Automatically displays uploaded images from static-web-server
- **File Management**: Shows all uploaded files with direct links
- **Responsive Design**: Clean, modern UI built with Tailwind CSS

## Prerequisites

- Node.js 18+
- Running tusd server on `http://localhost:8080`
- Running static-web-server on `http://localhost:8787`

## Installation

```bash
npm install
```

## Usage

1. **Start the servers** (from the parent directory):
   ```bash
   # Start tusd (for uploads)
   docker-compose up

   # Start static-web-server (for serving files)
   ./sws.bash
   ```

2. **Start the client**:
   ```bash
   npm run dev
   ```

3. **Open** `http://localhost:3000` in your browser

4. **Upload files** using the file input - they'll be uploaded to tusd and displayed from static-web-server

## How It Works

1. **Upload**: Files are sent to tusd on port 8080 using the tus protocol (resumable uploads)
2. **Storage**: tusd stores files in the `./files` directory
3. **Serving**: static-web-server serves the uploaded files on port 8787
4. **Display**: The client fetches and displays images from the static-web-server URL

## Architecture

```
┌─────────────┐    ┌──────┐    ┌─────────────────┐
│   Browser   │────│ tusd │────│   ./files/      │
│             │    │ 8080 │    │                 │
└─────────────┘    └──────┘    └─────────────────┘
         │                    │
         │                    │
         └────────────────────┼────────────────────┘
                              │
                       ┌──────▼──────┐
                       │ static-web- │
                       │ server 8787 │
                       └─────────────┘
```

## Development

- **TypeScript**: Full type safety
- **Tailwind CSS**: Utility-first styling
- **Next.js 14**: App Router with React Server Components
- **tus-js-client**: Resumable upload library

## File Structure

```
client/
├── src/
│   ├── app/
│   │   ├── layout.tsx    # Root layout
│   │   ├── page.tsx      # Main upload page
│   │   └── globals.css   # Global styles
│   └── ...
├── package.json
└── README.md
```
