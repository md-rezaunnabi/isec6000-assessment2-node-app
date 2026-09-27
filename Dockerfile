# use node 16 as the application base image
FROM node:16-alpine

# set the application working directory
WORKDIR /app

# copy dependency files first
COPY package*.json ./

# install only production dependencies
RUN npm ci --omit=dev

# copy the application files
COPY . .

# run the application as the non-root node user
USER node

# application listens on port 8080
EXPOSE 8080

# start the application
CMD ["npm", "start"]