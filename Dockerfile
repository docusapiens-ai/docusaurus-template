# Use an official Node.js runtime as a base image
FROM node:22-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package files to the container
COPY package*.json ./

# Install dependencies
RUN rm -rf node_modules && npm install

# Copy all application files
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "index.js"]
