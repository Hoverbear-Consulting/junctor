BEGIN {};

# Variables
match($0, /^export ([a-zA-Z_-]+) \?= ([a-zA-Z_-]+) ## (.*?)/, matches) {
    sub(/[ \t\r\n]+$/, "", ENVIRON[matches[1]])
    printf "  %s%-10s%s %s%25s%s %s%-25s%s %-25s\n",
        FORMATTING_BEGIN_KNOBS,
        matches[1],
        FORMATTING_END,
        
        FORMATTING_BEGIN_CONFIGURED,
        ENVIRON[matches[1]],
        FORMATTING_END,

        FORMATTING_BEGIN_DEFAULT,
        matches[2],
        FORMATTING_END,
        
        matches[3]
}