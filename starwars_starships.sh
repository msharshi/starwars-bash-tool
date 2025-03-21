#!/bin/bash

# Check for dependencies
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required."; exit 1; }

# Validate argument
if [ -z "$1" ]; then
  echo "Usage: $0 \"<Film Title>\""
  exit 1
fi

FILM_TITLE="$1"

# Get all films
FILMS_JSON=$(curl -s "https://swapi.dev/api/films/")
FILM=$(echo "$FILMS_JSON" | jq -r --arg title "$FILM_TITLE" '.results[] | select(.title == $title)')

if [ -z "$FILM" ]; then
  echo "Film titled '$FILM_TITLE' not found."
  exit 1
fi

# Extract starship URLs
STARSHIPS=$(echo "$FILM" | jq -r '.starships[]')

# Initialize JSON output
OUTPUT="{\"film\": \"$FILM_TITLE\", \"starships\": ["

FIRST=1
for URL in $STARSHIPS; do
  SHIP_JSON=$(curl -s "$URL")
  SHIP_NAME=$(echo "$SHIP_JSON" | jq -r '.name')

  # Get pilot names
  PILOT_URLS=$(echo "$SHIP_JSON" | jq -r '.pilots[]?')

  PILOTS_JSON="["
  if [ -z "$PILOT_URLS" ]; then
    PILOTS_JSON+="\"No known pilots\""
  else
    for PILOT_URL in $PILOT_URLS; do
      PILOT_NAME=$(curl -s "$PILOT_URL" | jq -r '.name')
      PILOTS_JSON+="\"$PILOT_NAME\","
    done
    # Remove trailing comma
    PILOTS_JSON=${PILOTS_JSON%,}
  fi
  PILOTS_JSON+="]"

  # Append starship and pilots to output JSON
  [ $FIRST -eq 0 ] && OUTPUT+=","
  OUTPUT+="{\"starship\": \"$SHIP_NAME\", \"pilots\": $PILOTS_JSON}"
  FIRST=0
done

OUTPUT+="]}"

# Output formatted JSON
echo "$OUTPUT" | jq .

