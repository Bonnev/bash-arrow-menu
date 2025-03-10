#!/bin/bash

# example usage:
# git log --oneline | head -n 10 | ./menu.sh | grep -oE "^[a-zA-Z0-9]+" | xargs -I{} git checkout {}

show_menu() {
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then # show arrow for current selection
            # printf "\e[7m> ${options[i]}\e[0m\n"  # Inverted colors for selected
            printf "> ${options[i]}\n" >/dev/tty
        else
            echo "  ${options[i]}" >/dev/tty
        fi
    done
}

# readarray -t options < <(git log --oneline | head -n 10) # read options from command
mapfile -t options # get options from standard input
menu_lines=${#options[@]}

selected=0

# Save terminal state and setup
# /dev/tty means terminal output. We use this and not the standard output which will be used when piping the script
original_state="$(stty -g </dev/tty)"
trap 'stty "$original_state" </dev/tty' EXIT  # Restore terminal on exit
stty -icanon -echo </dev/tty # Disable canonical mode and echo

# Hide cursor
printf "\e[?25l" >/dev/tty

# Main loop
while true; do
    show_menu
    # Read three characters (to capture escape sequences)
    read -rsn3 key </dev/tty
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
    echo -en "\e[${menu_lines}A" >/dev/tty
done

# Show cursor again
printf "\e[?25h" >/dev/tty

option=("${options[selected]}")
echo $option

# experiment: ./menu.sh cat {} # should execute cat <option>
# store all command arguments in a string
# cmd_template="$*"
# echo $cmd_template
# substitute {} for option in cmd_template and execute command
# cmd="${cmd_template//\{\}/$option}"
# echo $cmd
# eval "$cmd"

# experiment: ./menu.sh grep 6c # should execute grep 6c with <option> as input
# Store all command arguments in an array (this preserves each word separately)
# cmd=("$@")
# "${cmd[@]}" <<< "$option"
# echo "$option" | "${cmd[@]}"
