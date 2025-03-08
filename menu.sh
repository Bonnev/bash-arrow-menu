#!/bin/bash

# Function to display the menu
show_menu() {
    clear
    echo "Use arrow keys to navigate, Enter to select:"
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            printf "\e[7m> ${options[i]}\e[0m\n"  # Inverted colors for selected
        else
            echo "  ${options[i]}"
        fi
    done
}

# Initial setup
options=("Option 1" "Option 2" "Option 3" "Quit")
selected=0

# Save terminal state and setup
original_state="$(stty -g)"
trap "stty $original_state" EXIT  # Restore terminal on exit
stty -icanon -echo  # Disable canonical mode and echo

# Hide cursor
printf "\e[?25l"

# Main loop
while true; do
    show_menu

    # Read input
    read -rsn1 key
    case "$key" in
        $'\x1b')  # Escape sequence
            read -rsn2 -t 0.1 key2
            case "$key2" in
                '[A') ((selected--))  # Up arrow
                    [ $selected -lt 0 ] && selected=$((${#options[@]}-1)) ;;
                '[B') ((selected++))  # Down arrow
                    [ $selected -ge ${#options[@]} ] && selected=0 ;;
            esac
            ;;
        '')  # Enter key
            break ;;
    esac
done

# Show cursor again
printf "\e[?25h"

# Handle selection
case "${options[selected]}" in
    "Option 1")
        echo "You chose Option 1" ;;
    "Option 2")
        echo "You chose Option 2" ;;
    "Option 3")
        echo "You chose Option 3" ;;
    "Quit")
        echo "Exiting..." ;;
esac