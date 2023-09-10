# ~/.profile: executed by Bourne-compatible login shells.
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

clear 
/usr/local/bin/bootmachine


if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
    green=$(tput setaf 2)
    normal=$(tput sgr0)
    printf "\nDOSBIAN-X was developed by David Weese, (c) 2023\n\n" 
    printf "If you liked this distro and want to leave a comment or get updated about new releases, please visit my blog at https://cmaiolino.wordpress.com/dosbian\n\n"
    printf "Need help/support about how to configure Dosbian and you don't know where to start from? Visit the Facebook community at www.facebook.com/groups/Dosbian\n\n"
    printf "DOSBIAN-X is a donationware project, this means you can modify, improve, customise as you like for your own use."
    printf "\n\nIT IS STRICTLY PROHIBITED:"
    printf "\n\n- USE DOSBIAN-X FOR COMMERCIAL PURPOSES.\n\n"
    printf "\n\n- DIFFUSE YOUR OWN CUSTOMIZED COPY OF DOSBIAN-X.\n\n"
fi
fi
clear

menu

