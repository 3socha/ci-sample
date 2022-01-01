@test "curl" {
  run curl --help
  [ "${lines[0]}" = "Usage: curl [options...] <url>" ]
}

@test "echo" {
  run echo unko
  [ "${output}" = "unko" ]
}

@test "mecab with NEologd" {
  run bash -c "echo シェル芸 | mecab -Owakati"
  [ "$output" = "シェル芸 " ]
}

@test "egison" {
  run egison -e 'foldl (+) 0 (take 10 nats)'
  [ "$output" = "55" ]
}
