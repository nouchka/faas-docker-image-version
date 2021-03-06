#!/bin/bash

set -- "${1:-$(</dev/stdin)}" "${@:2}"

main() {
  check_args "$@"

  local image=$1
  local tag=$2
  local token=$(get_token $image)
  local digest=$(get_digest $image $tag $token)

  echo $digest
  ## get_image_configuration $image $token $digest
}

get_image_configuration() {
  local image=$1
  local token=$2
  local digest=$3

  curl \
    --silent \
    --location \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/blobs/$digest" \
  | jq -r '.config .labels'
}

get_token() {
  local image=$1

  curl \
    --silent \
    "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io" \
    | jq -r '.token'
}

# Retrieve the digest, now specifying in the header
# that we have a token (so we can pe...
get_digest() {
  local image=$1
  local tag=$2
  local token=$3

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/manifests/$tag" \
    | jq -r '.config.digest'
}

check_args() {
  if (($# != 2)); then
    echo "Error:
    Two arguments must be provided - $# provided.
  
    Usage:
      ./get-image-config.sh <image> <tag>
      
Aborting."
    exit 1
  fi
}

main $1 $2
