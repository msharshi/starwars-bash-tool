FROM alpine:latest

RUN apk add --no-cache curl jq bash

WORKDIR /app

COPY starwars_starships.sh .

RUN chmod +x starwars_starships.sh

CMD ["bash"]
#This ensures the script does NOT auto-execute; it allows bash access for manual usage.
