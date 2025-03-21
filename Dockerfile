# Use Alpine Linux as base image
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache curl jq bash

# Set working directory
WORKDIR /app

# Copy script into container
COPY starwars_starships.sh .

# Make it executable
RUN chmod +x starwars_starships.sh

# Keep the container running (manual exec)
CMD ["bash"]

