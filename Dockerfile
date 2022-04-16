FROM alpine:3.15 as build
LABEL autodelete="true"

# Create app directory
WORKDIR /opt/influx-opcua-server

# Install dependencies
RUN apk update && apk upgrade && apk add --no-cache \
  nodejs \
  npm \
  openssl \
  bash \ 
  musl-dev \
  make

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# Install dependencies
RUN npm install

# Bundle app source
COPY . .

# Create Binary
RUN npm run build-alpine

FROM alpine:3.15

# Install dependencies
RUN apk add --no-cache ca-certificates

WORKDIR /opt/influx-opcua-server

# Copy build output
COPY --from=build /opt/influx-opcua-server/example_config/config.json /opt/influx-opcua-server/config.json
COPY --from=build /opt/influx-opcua-server/influx-opcua-server-alpine /opt/influx-opcua-server/influx-opcua-server

# Expose port
EXPOSE 7000

# Command to run the executable
ENTRYPOINT [ "/opt/influx-opcua-server/influx-opcua-server" ]
