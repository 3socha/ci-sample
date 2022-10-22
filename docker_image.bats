#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

@test "chromium" {
  if [ "$(uname -m)" = "aarch64" ]; then skip "chromium is not installed on aarch64"; fi
  run -0 chrome --version
  [[ "$output" =~ "Chromium" ]]
}
