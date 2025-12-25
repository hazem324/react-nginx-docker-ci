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

📄 License

This project is provided for educational and deployment purposes.
Customize it according to your organization’s needs.