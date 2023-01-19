#!/bin/bash
# This script requires the pharo-vm (either upstream or a user fork) to be cloned into the directory where it resides.

set -u  # Check for undefined variables
set -o noclobber  # Avoid overlay files (echo "hi" > foo)
set -o errexit    # Used to exit upon error, avoiding cascading errors
set -o pipefail   # Unveils hidden failures
set -o nounset    # Exposes unset variables

builds_root_dir="builds"
build_dir_prefix="$builds_root_dir"/"build-"
dirname=$(date +%Y-%m-%d-%S)
build_dir=$build_dir_prefix$dirname
pharo_vm_dir="pharo-vm"
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

show_usage() {
	printf "Usage: %s\n" $(basename $0) 

}

# Build Pharo in a new timestamed directory
build_vm () {
	[ -d "$pharo_vm_dir" ] || { oops "pharo-vm git repository directory not found";}
	mkdir -v "$build_dir" || { oops "Cannot create timestamped directory"; }
	cmake -S "$pharo_vm_dir" -B "$build_dir"
	(cd "$build_dir" && make install)
}

setup() {
	[ -d "$builds_root_dir" ] || { print_err "Creating builds root directory\n"; mkdir -v "$builds_root_dir"; }
}

report() {
	local report_file=$build_dir/"build-report-"$dirname".txt"

	[ -d "$build_dir" ] || { oops "Couldn't build Pharo VM"; }
	{
		printf '\n'
		printf "Built: %s\n" $build_dir > $report_file 
		printf '== are we in docker =============================================\n'
		num=$(cat /proc/1/cgroup | grep docker | wc -l);
		if [ $num -ge 1 ]; then
			echo "Yes"
		else
			echo "No"
		fi

		printf '\n'
		printf '== lsb_release =====================================================\n'
		cmd_exists lsb_release && lsb_release -a 2>&1

		printf '\n'
		printf '== uname =====================================================\n'
		uname -a 2>&1

		printf '\n'
		printf '== bash =====================================================\n'
		bash --version 2>&1

		printf '\n'
		printf '== zsh =====================================================\n'
		cmd_exists zsh && zsh --version 2>&1

		printf '\n'
		printf '== ulimit =====================================================\n'
		cmd_exists ulimit && ulimit -a 2>&1

		printf '\n'
		printf '== git =====================================================\n'
		cmd_exists git && git --version 2>&1

		printf '\n'
		printf '== wget =====================================================\n'
		cmd_exists wget && wget --version 2>&1

		printf '\n'
		printf '== curl =====================================================\n'
		cmd_exists curl && curl --version 2>&1

		printf '\n'
		printf '== openssl =====================================================\n'
		cmd_exists openssl && openssl version 2>&1    

		printf '\n'
		printf '==  apt-get =====================================================\n'
		cmd_exists apt-get && apt-get -v 2>&1  

		printf '\n'
		printf '== lsblk =====================================================\n'
		cmd_exists lsblk && lsblk 2>&1  

		printf '\n'
		printf '== lscpu =====================================================\n'
		cmd_exists lscpu && lscpu 2>&1

		printf '\n'
		printf "== dmidecode (system) ==========================================\n"
		cmd_exists dmidecode && sudo dmidecode -t system 2>&1

		printf '\n'
		printf "== dmidecode (processor) ========================================\n"
		cmd_exists dmidecode && sudo dmidecode -t processor 2>&1

		printf '\n'
		printf '== LD_LIBRARY_PATH/DYLD_LIBRARY_PATH =============================\n'
		if [ -z ${LD_LIBRARY_PATH+x} ]; then
			printf "LD_LIBRARY_PATH is unset\n";
		else
			printf LD_LIBRARY_PATH ${LD_LIBRARY_PATH} ;
		fi

		if [ -z ${DYLD_LIBRARY_PATH+x} ]; then
			printf "DYLD_LIBRARY_PATH is unset\n";
		else
			printf DYLD_LIBRARY_PATH ${DYLD_LIBRARY_PATH} ;
		fi

		printf
		printf '\n'
		printf "== tree =========================================================\n"
		cmd_exists tree && tree -f -C --gitignore $build_dir

		} >> ${report_file}

		printf "Wrote environment to ${report_file}. You can review the contents of that file.\n"
		printf "and use it to populate the fields in the github issue template.\n"
		printf '\n'
		printf "cat ${report_file}\n"
		printf '\n'
}

main() {
	setup
	build_vm
	report
}

main $*