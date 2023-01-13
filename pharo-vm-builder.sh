#!/bin/bash

builds_root_dir="builds"
build_dir_prefix="$builds_root_dir"/"build-"
dirname=$(date +%Y-%m-%d-%S)
build_dir=$build_dir_prefix$dirname

oops() {
	echo "$0:" "$@" >&2
	exit 1
}

print_err(){
    echo "E: $*" >>/dev/stderr
}

show_usage() {
	cat <<-EOF
		Usage: $(basename $0) COMMAND
		
		Commands:
				-h|--help                   Shows usage
				-v|--version		        Shows version
		EOF
}

# Build Pharo in a new timestamed directory
build_vm () {
	mkdir -v "$build_dir" || { oops "Cannot create timestamped directory\n"; }
	cmake -S pharo-vm -B "$build_dir"
	(cd "$build_dir" && make install)
}

setup() {
	[ -d "$builds_root_dir" ] || { print_err "Creating builds root directory\n"; mkdir -v "$builds_root_dir"; }
}

report() {
	local report_file=$build_dir/"build-report-"$dirname".txt"

	[ -d "$build_dir" ] || { oops "Couldn't build Pharo VM"; }
	printf "Built: %s\n" $build_dir > $report_file
	[ -f $(which brew) ] && { exec >> $report_file; $(brew config); }
}

main() {
	setup
	build_vm
	report
}

main $*
