# Description

Scripts to ease Pharo VM building

# Usage

```bash
git clone https://github.com/hernanmd/pharo-vm-builder
cd pharo-vm-builder
git clone https://github.com/pharo-project/pharo-vm.git
./pharo-vm-builder.sh
```

# Details

Currently it generates:

- A timestamped build directory for each usage.
- A compiler commands file (compile_commands.json) to help clangd find include paths in vscode.
- A timestamped report file with lots of build information, for example:
  - if we are in docker
  - ulimit
  - openssl, curl, wgetm git, etc versions
  - complete the tree of the build
