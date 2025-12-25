# React App with Nginx (Docker + Buildx + SSH)

A production-ready Docker image for a React application, built with a multi-stage Dockerfile and served by Nginx. The private React source is cloned during the build using SSH agent forwarding so no SSH keys are baked into the image.

Live demo: Serve the final static build with Nginx — small, secure, and fast.

---

Table of contents
- [Key features](#key-features)
- [Architecture overview](#architecture-overview)
- [How it works (high level)](#how-it-works-high-level)
- [Dockerfile summary](#dockerfile-summary)
- [Security highlights](#security-highlights)
- [Prerequisites](#prerequisites)
- [Build the image (local)](#build-the-image-local)
- [Run the container](#run-the-container)
- [Example: Docker Compose (optional)](#example-docker-compose-optional)
- [Example: GitHub Actions workflow (CI)](#example-github-actions-workflow-ci)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Contributing](#contributing)
- [License](#license)

---

## Key features
- Multi-stage Docker build:
  - Build stage: Node.js (builds the React production bundle)
  - Runtime stage: Nginx (serves compiled static files)
- Clones private repository at build time using SSH agent forwarding
- Final image contains only static assets + Nginx — no Node, no source code, no SSH keys
- Optimized for production and CI/CD usage

---

## Architecture overview
1. Build stage (node:lts-alpine)
   - Clone the private React repo via SSH (agent forwarding)
   - Install dependencies and build production assets
   - Output: compiled files (e.g., `/app/build`)

2. Runtime stage (nginx:alpine)
   - Copy build artifacts into Nginx static root
   - Serve files on port 80

This yields a lightweight runtime image and separates build-time secrets from runtime.

---

## How it works (high level)
- Use Docker BuildKit / Buildx because BuildKit supports the `--ssh` mount for forwarding the host SSH agent into the build.
- An SSH agent runs on your host and has an unlocked key that is added to GitHub. During the build the container can use that agent to clone a private repository.
- No SSH private keys are written to the image or its layers.

---

## Dockerfile summary

Build stage (React)
```dockerfile
FROM node:lts-alpine AS build

RUN apk add --no-cache git openssh-client
WORKDIR /app
RUN mkdir -p -0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Uses BuildKit SSH mount to access the host SSH agent (no keys stored in image)
RUN --mount=type=ssh git clone git@github.com:hazem324/e-commerce-temp.git .

RUN npm install && npm run build
```

Runtime stage (Nginx)
```dockerfile
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Security highlights
- No SSH keys copied into image layers
- Only the built static output is included in the final image
- Minimal runtime surface (Nginx + static files)
- Use BuildKit's SSH forwarding to keep secrets on the host only

---

## Prerequisites
- Docker (with Buildx / BuildKit enabled)
- An SSH key on your host added to GitHub and loaded in an ssh-agent
  - Example:
    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    ```
- If building in CI, the runner must support BuildKit SSH forwarding (see CI snippet below)

---

## Build the image (local)

1. Ensure BuildKit is enabled (optional; many modern Docker installations already enable it).

2. Start ssh-agent and add your key:
```bash
# macOS / Linux
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

3. Build with Buildx and forward the SSH agent:
```bash
docker buildx build --ssh default --load -t react-nginx .
```

Flags explained:
- `--ssh default` — forward your host SSH agent into the build
- `--load` — load the built image into the local Docker images (useful for development)
- `-t react-nginx` — tags the resulting image

If you want to push directly to a registry, omit `--load` and use `--push` with a fully qualified image name.

---

## Run the container

Run locally:
```bash
docker run -p 8080:80 react-nginx
```

Open your browser:
- http://localhost:8080

---

## Example: Docker Compose (optional)
A minimal compose file to run the image locally:
```yaml
version: "3.8"
services:
  web:
    image: react-nginx
    ports:
      - "8080:80"
    restart: unless-stopped
```

---

## Example: GitHub Actions workflow (CI)
This example demonstrates building using Buildx and forwarding SSH to clone a private repository during the build. Save as `.github/workflows/build.yml`.

```yaml
name: Build and push
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Checkout (for workflow files)
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-buildx-action@v3

      - name: Configure SSH for actions
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Login to registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}  # or another registry token

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/react-nginx:latest
          ssh: default
```

Notes:
- Store an SSH private key in your repository or organization secrets (e.g., `SSH_PRIVATE_KEY`) that has read access to the private repo.
- Prefer deploy keys or machine/user keys with limited scope to reduce risk.

---

## Troubleshooting & FAQ

Q: "I get permission denied when cloning via SSH during build."
- Ensure your SSH key is loaded into the agent with `ssh-add`.
- Confirm the key is added to GitHub and has read access to the repo.
- Verify BuildKit is active and you're using `docker buildx build --ssh default`.

Q: "Buildx not found / BuildKit errors"
- Install/enable Docker Buildx. Recent Docker versions ship with Buildx enabled by default.
- Run: `docker buildx create --use` if you need to create a builder instance.

Q: "How do I avoid committing secrets to Git?"
- Never add private keys to the repo. Use SSH agent forwarding and CI secrets as shown above.

---

## Contributing
Contributions, fixes, and improvements are welcome. Please open issues or pull requests with descriptions of what you changed and why.

---

## License
This project is provided for educational and deployment purposes. Adapt and customize to your organization’s policies and license preferences.
