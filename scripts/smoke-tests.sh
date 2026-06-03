#!/usr/bin/env bash
set -euo pipefail

: "${DOTNET_API_URL:?DOTNET_API_URL is required}"
: "${SPRING_API_URL:?SPRING_API_URL is required}"
: "${NODE_API_URL:?NODE_API_URL is required}"

SMOKE_TEST_MODE="${SMOKE_TEST_MODE:-full}"

if [[ "${SMOKE_TEST_MODE}" != "health" && "${SMOKE_TEST_MODE}" != "full" ]]; then
  echo "SMOKE_TEST_MODE must be health or full" >&2
  exit 1
fi

test_endpoint() {
  local service_name="$1"
  local base_url="$2"
  local path="$3"
  local response

  echo "Testing ${service_name} ${path}"
  response="$(curl -fsS --retry 5 --retry-all-errors --retry-delay 5 "${base_url%/}${path}")"

  if [[ "${path}" == "/secret" && "${response}" != *"secretResolved"* ]]; then
    echo "${service_name} ${path} did not include secretResolved" >&2
    exit 1
  fi
}

for service in \
  "dotnet-api|${DOTNET_API_URL}" \
  "spring-api|${SPRING_API_URL}" \
  "node-api|${NODE_API_URL}"; do
  service_name="${service%%|*}"
  base_url="${service#*|}"

  test_endpoint "${service_name}" "${base_url}" "/health"

  if [[ "${SMOKE_TEST_MODE}" == "health" ]]; then
    continue
  fi

  test_endpoint "${service_name}" "${base_url}" "/config"
  test_endpoint "${service_name}" "${base_url}" "/feature-flags"
  test_endpoint "${service_name}" "${base_url}" "/secret"
done

echo "Smoke tests completed successfully."
