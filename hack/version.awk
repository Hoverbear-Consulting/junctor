# Version
match($0, /^(.*?)#(.*?)/, matches) {
    printf "%s",
        matches[2]
}