🚀 React App CI Pipeline with Jenkins & Docker

This repository demonstrates a simple CI pipeline built with Jenkins and Docker to automate the build and publication of a React application.

The main goal of this project is to practice CI/CD fundamentals: building an application, packaging it into a Docker image, and publishing that image automatically using Jenkins.

🧠 Project Overview

The application is a React frontend

The app is built using Node.js

The production build is served using Nginx

A Jenkins pipeline automates the full workflow

The final Docker image is pushed to Docker Hub

This project is intentionally kept simple and focused on learning and automation, not on application complexity.

🏗️ Architecture

The Docker image is built using a multi-stage Docker build:

1️⃣ Build Stage (Node.js)

Installs dependencies

Builds the React application (npm run build)

Produces static files

2️⃣ Runtime Stage (Nginx)

Serves the compiled React build

No Node.js in the final image

Lightweight and production-oriented

🔁 CI Workflow (Jenkins)

The Jenkins pipeline performs the following steps automatically:

Triggered on GitHub push

Clones the repository

Builds the React application

Builds a Docker image using the provided Dockerfile

Runs a basic container smoke test

Logs in to Docker Hub using Jenkins credentials

Pushes the Docker image to Docker Hub

Cleans up the Jenkins agent

The pipeline ensures that the Docker image is published only if all steps succeed.

🔐 Credentials Handling

Docker Hub credentials are stored securely in Jenkins Credentials

No secrets are hardcoded in the repository

Credentials are injected only at runtime during the push stage

This helps keep the pipeline safe and reproducible.

🐳 Build and Run Locally (Optional)

Build the Docker image locally:

docker build -t react-nginx-app .


Run the container:

docker run -p 8080:80 react-nginx-app


Open in browser:

http://localhost:8080

📦 Use Cases

Learning Jenkins pipelines

Practicing Docker multi-stage builds

Understanding CI workflows

Beginner DevOps portfolio project

📘 What I Learned

How Jenkins pipelines orchestrate CI steps

How Docker fits into a CI workflow

How to publish Docker images automatically

How to handle credentials securely in Jenkins

📄 License

This project is provided for learning and practice purposes.
You are free to reuse and adapt it.
