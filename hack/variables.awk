BEGIN {};

# Variables
match($0, /^export ([a-zA-Z_-]+) \?= (.*) ## (.*?)/, matches) {
    printf "  %s%-20s%s %s%20s%s %s%-20s%s %-20s\n",
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