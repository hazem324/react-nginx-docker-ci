FROM node:lts-alpine AS build 

# install git package
RUN apk add --no-cache git openssh-client

# create the work directory 
WORKDIR /app

RUN mkdir -p -0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone private repository using SSH forwarding (SECURE)
# The SSH key is NEVER stored in the image

RUN --mount=type=ssh git clone git@github.com:hazem324/e-commerce-temp.git .

# Install dependencies and build React app
RUN npm install && npm run build

FROM nginx:alpine

# Copy only the build output
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

