#!/bin/bash
if [[ "$EUID" -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

rm ./*.deb

cd pacstall

rm -rf "./var"
rm -rf "./usr"
rm -rf "./bin"
rm -rf "DEBIAN"

mkdir -p "./usr/share/doc/pacstall"
wait
mkdir "DEBIAN"
cp ../control ./DEBIAN/
cp ../copyright ./usr/share/doc/pacstall/
cp ../changelog ./usr/share/doc/pacstall/
cp ../conffiles ./usr/share/doc/pacstall/

mkdir "./bin"
mkdir -p "./usr/share/pacstall/scripts"
mkdir -p "./usr/share/pacstall/repo"

mkdir -p "./var/log/pacstall/error_log"
chmod 755 "./var/log/pacstall/error_log"
mkdir -p "./usr/share/man/man8"
mkdir -p "./usr/share/bash-completion/completions"

touch "./usr/share/pacstall/repo/pacstallrepo.txt"
echo "https://raw.githubusercontent.com/pacstall/pacstall-programs/master" > ./usr/share/pacstall/repo/pacstallrepo.txt

for i in {error_log.sh,add-repo.sh,search.sh,download.sh,install-local.sh,upgrade.sh,remove.sh,update.sh,query-info.sh}; do
	wget -q --show-progress -N https://raw.githubusercontent.com/pacstall/pacstall/master/misc/scripts/"$i" -P "./usr/share/pacstall/scripts" &
done

wget -q --show-progress --progress=bar:force -O "./bin/pacstall" "https://raw.githubusercontent.com/pacstall/pacstall/master/pacstall" &
wget -q --show-progress --progress=bar:force -O "./usr/share/man/man8/pacstall.8.gz" "https://raw.githubusercontent.com/pacstall/pacstall/master/misc/pacstall.8.gz" &

mkdir -p "./usr/share/bash-completion/completions"
mkdir -p "./usr/share/fish/vendor_completions.d"
wget -q --show-progress --progress=bar:force -O "./usr/share/bash-completion/completions/pacstall" "https://raw.githubusercontent.com/pacstall/pacstall/master/misc/completion/bash" &
wget -q --show-progress --progress=bar:force -O "./usr/share/fish/vendor_completions.d/pacstall.fish" "https://raw.githubusercontent.com/pacstall/pacstall/master/misc/completion/fish" &

wait

chmod 755 "./bin/pacstall"
chmod 755 ./usr/share/pacstall/scripts/*

wait

cd ..

version=$(cat control | grep "Version: " | awk '{print $2;}')
dpkg -b ./pacstall
mv ./pacstall.deb "./pacstall_${version}_all.deb"
