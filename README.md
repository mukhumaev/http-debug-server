# HTTP Debug Server

A simple HTTP debug server written in Go that logs incoming requests and returns request details in JSON format.

## Features

- Handles all incoming HTTP requests.
- Returns request parameters, headers, URI, and path in JSON format.
- Logs request details to the console.

## Prerequisites

- Go 1.20 or later
- Docker (optional, for containerization)

## Getting Started

### Build the Project

Clone the repository and build the project using the following commands:

```bash
git clone https://github.com/mukhumaev/http-debug-server.git
cd http-debug-server

# Build the local Go application
make build

# Builds the Docker image for the application with the specified tag
make build-image

# Build the application and the Docker image
make build-all
```

### Run the Server

You can run the server using the following commands:

```bash
# Start the binary
make start

# Start in Docker
make start-container
```

The server will start on port 5000. You can access it at `http://localhost:5000`.

## Making Requests

You can test the server using `curl` or any HTTP client. For example:

```bash
curl -s -X GET "http://localhost:5000/tester?param1=value1&param2=value2" -H "Custom-Header: CustomValue" | jq
```

### Example Response

The server will respond with a JSON object containing the request details:

```json
{
  "client_ip": "172.17.0.1",
  "headers": {
    "Accept": "*/*",
    "Custom-Header": "CustomValue",
    "User-Agent": "curl/8.11.1"
  },
  "request_details": {
    "args": {
      "param1": [
        "value1"
      ],
      "param2": [
        "value2"
      ]
    },
    "method": "GET",
    "path": "/tester",
    "uri": "/tester?param1=value1&param2=value2"
  }
}
```

## Clean Up

To clean up Docker images and unused resources, run:

```bash
make clean
```

## Release

To push the Docker image to your Docker repository, use:

```bash
make release
```

### Notes
- Ensure that Docker is running if you plan to use the containerization features.
- Adjust the port in the `make start-container` command if you need to run multiple instances.

