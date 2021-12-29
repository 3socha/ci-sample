@test "curl" {
  run curl --help
  [ "${lines[0]}" = "Usage: curl [options...] <url>" ]
}

@test "echo" {
  run echo unko
  [ "${output}" = "hoge" ]
}
