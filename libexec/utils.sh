oops() {
	echo "$0:" "$@" >&2
	exit 1
}

# Returns 0 if command was found in the current system, 1 otherwise
cmd_exists () {
	type "$1" &> /dev/null || [ -f "$1" ];
	return $?
}

print_err(){
	if [ -w /dev/stderr ]; then
        std_err=/dev/stderr
	else
        std_err=/dev/tty
	fi
    echo "E: $*" >> $std_err
}

print_version () {
	printf "Pharo VM Builder 1.0"
}

print_help () {
	printf "$0 [druid|cogit|stack]"
}
