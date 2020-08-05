BEGIN {};

# Headers
match($0, /^##@ (.*?)/, matches) {
    printf "%s%s%s\n",
        FORMATTING_BEGIN_HINT,
        matches[1],
        FORMATTING_END
}

# Tasks
match($0, /^([a-zA-Z0-9_-]+): ?(.*?) ## (.*?)/, matches) {
    printf "   %s%-40s%s %-20s\n",
        FORMATTING_BEGIN_TASK,
        matches[1],
        FORMATTING_END,

        matches[3]
}
