report() {
	local report_file=$build_dir/"build-report-"$dirname".txt"

	[ -d "$build_dir" ] || { oops "Couldn't build Pharo VM"; }
	{
		printf "Built in : %s\n" $build_dir
		printf '== are we in docker =============================================\n'
		if curl -s --unix-socket /var/run/docker.sock http/_ping 2>&1 >/dev/null; then
			printf "Running\n"
		else
			printf "Not running\n"
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