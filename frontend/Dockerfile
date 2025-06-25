###################################################
#               Build Stage                       #
###################################################

# Debian based slim image
FROM node:18-bookworm-slim AS build

# Add a work directory
WORKDIR /app

# Cache and Install dependencies
COPY package*.json ./
RUN npm install

# Copy all frontend app files
COPY . .

# Build the frontend app
RUN npm run build

###################################################
#               Run Stage                         #
###################################################
# Run frontend app behind Nginx
FROM nginx:1.28-bookworm

# copy built assets from build stage
COPY --from=build /app/build /usr/share/nginx/html
# add default nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf 
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# expose frontend app over port 3000
EXPOSE 3000

# start Nginx
CMD ["nginx", "-g", "daemon off;"]