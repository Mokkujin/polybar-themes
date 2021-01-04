#!/usr/bin/env bash
var_style=$1

# Install script for polybar themes

# Dirs
DIR=$(dirname $(readlink -f ${0}))
FDIR="$HOME/.local/share/fonts"
PDIR="$HOME/.config/polybar"

# Install Fonts
install_fonts() {
	echo -e "\n[*] Installing fonts..."
	if [[ -d "$FDIR" ]]; then
		cp -rf "$DIR/fonts/*" "$FDIR"
	else
		mkdir -p "$FDIR"
		cp -rf "$DIR/fonts/*" "$FDIR"
	fi
}

# Install Themes
install_themes() {
	if [[ -d "$PDIR" ]]; then
		echo -e "[*] Creating a backup of your polybar configs..."
		mv "$PDIR" "${PDIR}.old"
		{ mkdir -p "$PDIR"; cp -rf $DIR/$STYLE/* "$PDIR"; }
	else
		{ mkdir -p "$PDIR"; cp -rf $DIR/$STYLE/* "$PDIR"; }	
	fi
	if [[ -f "$PDIR/launch.sh" ]]; then
		echo -e "[*] Successfully Installed.\n"
		exit 0
	else
		echo -e "[!] Failed to install.\n"
		exit 1
	fi
}

# Main
main() {
	clear
    # make it scriptable
	if  [[ -z "${var_style// }" ]]; then
		cat <<- EOF
			[*] Installing Polybar Themes...
			
			[*] Choose Style -
			[1] Simple
			[2] Bitmap
		
		EOF
		read -p "[?] Select Option : "
		case "$REPLY" in
		 1) var_style="simple" ;;
		 2) var_style="bitmap" ;;
		 *) echo "you have to choose SIMPLE OR BITMAP (1 or 2)"
		     exit 1 ;;
        esac
	else
	  case "$var_style" in
	   sim) var_style="simple" ;;
	   bit) var_style="bitmap" ;;
	   *) echo "please use sim or bit as Parameter"
	       exit 1 ;;
        esac
	fi
   	STYLE="$var_style"
	install_fonts
	install_themes
}

main
