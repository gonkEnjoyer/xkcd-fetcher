# xkcd-fetcher
 A simple bash script to fetch and display xkcd comics inside your terminal
## Installation
1. Download the script and install the necessary [dependencies](#Dependencies).
2. Make the script executable by running the following in the directory where the script is placed:
   
   ```bash
   chmod +x ./xkcd.sh
   ```
4. (Optionally) add an alias or symlink to `~/.local/bin` to run the script from anywhere.
## Dependencies
 This script depends on some programs that may need to be installed separately depending on your distribution:
 - `jq`
 - `libxml2-utils`
 - `chafa`

**Note:** the script also requires modern versions of utilities such as `grep` with Perl regex support and `curl` that most distributions should have.
## Compatibility
 `chafa` uses various graphics protocols to provide the highest quality possible for your terminal. *Most* common terminal emulators like Kitty, Xterm and iTerm2 are supported for the highest quality protocols but some like ptyxis (the default for GNOME on modern Fedora and Ubuntu) are not. The script will still run on these but `chafa` will fall back to a low-quality ASCII rendering of the comics, so it is not recommended.
## License
 This script is licensed under **GNU GPLv3**. For more information, see the included [LICENSE](./LICENSE).
## Notice
 "XKCD" is a trademark of Randall Munroe. This is an independent project and is not affiliated, sponsored nor endorsed by the creator of xkcd.
