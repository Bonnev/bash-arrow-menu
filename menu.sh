#!/bin/bash

show_menu() {
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            # printf "\e[7m> ${options[i]}\e[0m\n"  # Inverted colors for selected
            printf "> ${options[i]}\n"
        else
            echo "  ${options[i]}"
        fi
    done
}

# Options setup
options=("Option 1" "Option 2" "Option 3" "Quit")
selected=0
menu_lines=${#options[@]}

# Save terminal state and setup
original_state="$(stty -g)"
trap "stty $original_state" EXIT  # Restore terminal on exit
stty -icanon -echo  # Disable canonical mode and echo

# Hide cursor
printf "\e[?25l"

# Main loop
while true; do
    show_menu
    # Read three characters (to capture escape sequences)
    read -rsn3 key
    case "$key" in
        $'\e[A')  # Up arrow
            (( selected-- ))
            if [ "$selected" -lt 0 ]; then
                selected=$((${#options[@]} - 1))
            fi
            ;;
        $'\e[B')  # Down arrow
            (( selected++ ))
            if [ "$selected" -ge "${#options[@]}" ]; then
                selected=0
            fi
            ;;
        "")  # Enter key (when no key is read, read returns an empty string)
            break
            ;;
    esac
    echo -en "\e[${menu_lines}A"
done

# Show cursor again
printf "\e[?25h"

echo "${options[selected]}"
