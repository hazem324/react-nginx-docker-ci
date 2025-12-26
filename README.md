# React App with Nginx (Docker + Buildx + SSH)

This project provides a production-ready Docker image for a React application, built using a multi-stage Docker build and served with Nginx.

The React source code is cloned from a private GitHub repository using SSH forwarding, ensuring that no SSH keys are stored inside the Docker image.

🧠 Architecture Overview

The Docker image uses two stages:

Build stage (Node.js)

Clones the private React repository

Installs dependencies

Builds the production React app

Runtime stage (Nginx)

Serves the compiled React build

Lightweight and optimized for production

This approach keeps the final image small, secure, and fast.

🐳 Dockerfile Explanation (Key Points)
1️⃣ Build Stage – React Application
```
FROM node:lts-alpine AS build
```

Uses a lightweight Node.js Alpine image

Named build for later reference

```
RUN apk add --no-cache git openssh-client
```

Installs git to clone the repository

Installs openssh-client for SSH authentication

```
WORKDIR /app
```

Sets /app as the working directory inside the container

```
RUN mkdir -p -0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
```

Creates a secure SSH directory

Adds GitHub to known_hosts to avoid SSH verification prompts

```
RUN --mount=type=ssh git clone git@github.com:hazem324/e-commerce-temp.git .
```

Clones a private GitHub repository

Uses SSH agent forwarding

✅ SSH key is never copied into the image

```
RUN npm install && npm run build
```

Installs dependencies

Builds the React app for production

Output is generated in /app/build

2️⃣ Runtime Stage – Nginx
```
FROM nginx:alpine
```

Uses a minimal Nginx image for production serving

```
COPY --from=build /app/build /usr/share/nginx/html
```

Copies only the compiled React build

No source code, no Node.js, no secrets

```
EXPOSE 80
```

Exposes port 80 for HTTP traffic

```
CMD ["nginx", "-g", "daemon off;"]
```

Starts Nginx in the foreground (required for Docker)

🔐 Security Highlights

🔑 No SSH keys stored in the image

🔐 Uses SSH forwarding (--ssh)

🧼 Final image contains only static files + Nginx

📦 Smaller attack surface

🚀 Build the Image (Required)
Prerequisites

Docker : Required to build and run the container image.

Docker Buildx : Docker Buildx is an advanced build tool for Docker that uses BuildKit under the hood. 
Why Buildx is needed in this project:
This Dockerfile clones a private GitHub repository using SSH.
The --ssh option used during the build is only supported by Buildx, not by the classic docker build.

Without Buildx:

SSH forwarding does not work

Private repositories cannot be cloned securely during the build
SSH agent running

SSH key added to GitHub

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

Build command
```
docker buildx build --ssh default --load -t react-nginx .
```

--ssh default enables secure access to the private repository
--load makes the image available locally

▶️ Run the Container
```
docker run -p 8080:80 react-nginx
```

Open in browser:

http://localhost:8080

📦 Use Cases

Production React deployment

CI/CD pipelines (Jenkins, GitHub Actions)

Secure builds with private repositories

Docker + Nginx best practices

✅ Why This Approach Is Recommended

Multi-stage build = smaller image

Nginx = better performance

SSH forwarding = secure

Compatible with CI/CD pipelines
--

🧠 Good to Know — Docker Build, BuildKit & Secrets

This section explains core Docker build concepts that are important to understand, independent of this project.

🏗️ Docker Build vs Docker Buildx
Traditional Docker build (legacy)

Command:

docker build


Characteristics:

Limited build features

No secure secret handling

No SSH forwarding

Every command creates a permanent image layer

Secrets can accidentally be stored in image history

This build mode is not suitable for secure builds involving private repositories or credentials.

Modern Docker build (Buildx + BuildKit)

Command:

docker buildx build


Characteristics:

Uses BuildKit (modern build engine)

Supports advanced features:

--mount=type=ssh

--mount=type=secret

Better caching

Parallel execution

Designed for secure, production-grade builds

🔑 BuildKit — What It Really Is

BuildKit is Docker’s modern build engine.

Key idea:

BuildKit can give the build temporary access to sensitive resources WITHOUT saving them into the image.

This is the foundation of secure Docker builds.

BuildKit enables:

Temporary access to SSH authentication

Temporary access to secrets

Zero persistence of sensitive data

Clean final images

🔐 What Is an SSH Agent?

An SSH agent is a background process that:

Holds private SSH keys in memory

Performs cryptographic signing on your behalf

Never exposes the private key itself

Important points:

The private key never leaves the host machine

Other tools communicate with the agent via a Unix socket

The agent answers authentication challenges without sharing the key

This is why SSH agent forwarding is secure.

🔗 --mount=type=ssh

--mount=type=ssh allows a Docker build step to:

Access the host’s SSH agent

Authenticate to private Git repositories

Clone code securely during build

Key properties:

No SSH key is copied into the image

SSH access exists only during that RUN command

After the step finishes, access disappears completely

This is authentication forwarding, not secret copying.

🔐 What Is --mount=type=secret (Simple Definition)

--mount=type=secret allows you to securely pass sensitive data
(tokens, passwords, API keys) to a Docker build step without storing them in the image.

Key idea:

The secret is available only during that RUN step

It is never written to the image

It does not appear in:

Image layers

Docker history

Final image

⚠️ This feature is BuildKit-only.

⚙️ How --mount=type=secret Works Internally

Think of it as:

A temporary in-memory file that exists only while the command runs.

What actually happens:

You pass a secret at build time

BuildKit mounts it as a temporary file
(usually under /run/secrets/)

The command reads the secret

The command finishes

The secret file disappears forever

The image layer contains NO trace of the secret

Security guarantees:

🔐 No filesystem copy

🔐 No environment variable leakage

🔐 No Docker history exposure

⚠️ Why ARG and ENV Are Insecure for Secrets

Using ARG or ENV to handle secrets during a Docker build is not secure.

ARG (Build Arguments)

Values passed via ARG can appear in:

Image metadata

docker history

Even if not visible in the final filesystem, secrets may still be recoverable from image layers

Build logs in CI systems can accidentally expose them

👉 ARG is suitable only for non-sensitive build configuration.

ENV (Environment Variables)

ENV values are:

Stored permanently in the image

Visible via docker inspect

Inherited by all containers created from the image

Anyone with access to the image can read the secret

👉 ENV should never be used for build-time secrets.

🔥 Critical Docker Rule

Deleting a secret in a later Docker layer does NOT remove it from earlier layers.

Once a secret exists in a layer, it exists forever in the image history.

🔄 type=ssh vs type=secret (Very Important)
Feature	type=ssh	type=secret
Purpose	Git SSH authentication	Tokens, passwords, API keys
Uses SSH agent	✅ Yes	❌ No
File-based secret	❌	✅
Typical use	git clone	npm, pip, API auth
Secret leaves host	❌ Never	❌ Never
🧠 Final Mental Model (Remember Forever)

type=ssh → temporary access to authentication

type=secret → temporary access to data

Both:

Exist only during a RUN step

Leave no trace in the final image

Require BuildKit

Docker images should always be treated as public artifacts.

--

📄 License

This project is provided for educational and deployment purposes.
Customize it according to your organization’s needs.