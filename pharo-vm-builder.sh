#!/bin/bash
# This script requires the pharo-vm (either upstream or a user fork) to be cloned into the directory where it resides.

set -u  # Check for undefined variables
set -o noclobber  # Avoid overlay files (echo "hi" > foo)
set -o errexit    # Used to exit upon error, avoiding cascading errors
set -o pipefail   # Unveils hidden failures
set -o nounset    # Exposes unset variables

source "${BASH_SOURCE%/*}"/libexec/report.sh
source "${BASH_SOURCE%/*}"/libexec/utils.sh

builds_root_dir="builds"
build_dir_prefix="$builds_root_dir"/"build-"
dirname=$(date +%Y-%m-%d-%S)
build_dir=$build_dir_prefix$dirname
pharo_vm_dir="pharo-vm"

# Configure to build Pharo in a new timestamed directory
configure_build_dir () {
	[ -d "$builds_root_dir" ] || { print_err "Creating builds root directory\n"; mkdir -v "$builds_root_dir"; }
	[ -d "$pharo_vm_dir" ] || { oops "pharo-vm git repository directory not found";}
	mkdir -v "$build_dir" || { oops "Cannot create timestamped directory"; }
}

# Generate configuration and build
build_vm () {
	flavour="$1"
	configure_build_dir
	cmake \
		-S "$pharo_vm_dir" \
		-B "$build_dir" \
		-DDEPENDENCIES_FORCE_BUILD=ON \
		-DFLAVOUR="$flavour"
	(cd "$build_dir" && make install)
}

parse_cmd_line () {
	case "$1" in
		clean )
			trash builds
			;;	
		druid )
			build_vm DruidVM
			;;
		cogit )
			build_vm CoInterpreter
			;;
		stack )
			build_vm StackVM
			;;
		version )
			print_version
			;;
		* )
			print_help
			exit 1
	esac
}

main() {
	parse_cmd_line ${@}
	report
}

main $*