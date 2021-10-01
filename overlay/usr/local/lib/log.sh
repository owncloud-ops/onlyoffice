#!/usr/bin/env bash

# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
    level="$1"
    message="$2"
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    script_name="$(basename "$0")"
    >&2 echo -e "${timestamp} [${level}] [$script_name] ${message}"
}

# Log the given message at INFO level. All logs are written to stderr with a timestamp.
function log_info {
    message="$1"
    log "INFO" "$message"
}

# Log the given message at WARN level. All logs are written to stderr with a timestamp.
function log_warn {
    message="$1"
    log "WARN" "$message"
}

# Log the given message at ERROR level. All logs are written to stderr with a timestamp.
function log_error {
    message="$1"
    log "ERROR" "$message"
}
