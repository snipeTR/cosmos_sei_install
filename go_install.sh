#!/bin/bash

# install go function
installgo () 
  {
	  cd "$HOME" || { echo "Unable to enter $HOME directory";}
	  ver="$1"
	  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
	  sudo rm -rf /usr/local/go
	  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
	  rm "go$ver.linux-amd64.tar.gz"
	  sed -i.org '/GOROOT\|GOPATH\|GO111MODULE/d' "$HOME/.bash_profile"
	  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
	  echo "export GOROOT=/usr/local/go" >> "$HOME"/.bash_profile
	  echo "export GOPATH=$HOME/go" >> "$HOME"/.bash_profile
	  echo "export GO111MODULE=on" >> "$HOME"/.bash_profile
	  source "$HOME"/.bash_profile
	  echo "++++++++" && echo -e "\e[1m\e[32m Go installation complate... \e[0m" && echo -e "\e[1m\e[32m $(go version) \e[0m" && echo "++++++++" && sleep 1
	}

#go version variable, if need new version change variable
ver="1.18.2"

# /usr/local/go/bin/go
if [ -f "/usr/local/go/bin/go" ]; then
    checkgover=$(go version)
# /usr/local/go
elif [ -f "/usr/local/go" ]; then
	if [ ! -n "$checkgover" ]; then
    checkgover=$(go version)
  fi
else
  checkgover="NOT.HERE.GO.IM.SORY"
fi

if [ "${checkgover:13:4}" == "${ver:0:4}" ]; then 
	#NO NEED install go
	echo -e "\e[1m\e[32mNo need to install go-lang\e[0m, versions are compatible."
	echo -e "\e[1m\e[32mrequested\e[0m version $ver, \e[1m\e[32minstalled\e[0m version ${checkgover:13:6}"
else
  #installation required
  installgo "$ver"
fi
