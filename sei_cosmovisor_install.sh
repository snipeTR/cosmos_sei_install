﻿#!/bin/bash
echo tnx for kj89
sleep 1
cd $HOME
#update script download
if [sei_cosmovisor_update.sh]; then rm -rf sei_cosmovisor_update.sh; fi
wget -b -O sei_cosmovisor_update.sh https://raw.githubusercontent.com/snipeTR/cosmos_sei_install/main/sei_cosmovisor_update.sh && chmod +x sei_cosmovisor_update.sh

if [ .bash_profile ]
	then 
		if [ .bsh_profil_org ]
			then cp .bash_profile .bsh_profil_org
		fi
fi
source $HOME/.bash_profile

# delete old line for dublicate.
sed -i.org '/DAEMON_DATA_BACKUP_DIR\|DAEMON_RESTART_AFTER_UPGRADE\|DAEMON_NAME\|DAEMON_HOME\|UNSAFE_SKIP_BACKUP\|SEI_PORT\|SEI_CHAIN_ID\|WALLET\|NODENAME/d' "$HOME/.bash_profile"

# set vars
if [ $NODENAME ]; then 
	echo -e "Node name \e[1m\e[32mseting before\e[0m, NODE NAME..:\e[1m\e[32m$NODENAME\e[0m"
  echo -e "Press ANY KEY to use the \e[1m\e[32msame node name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$NODENAME\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      read -p "Enter node name: " NODENAME
      echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
    else
      echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
    fi
  else
  read -p "Enter node name: " NODENAME
  echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi


if [ ! $SEI_PORT ]; then SEI_PORT=12; fi

if [ $WALLET ]; then 
	echo -e "Wallet name \e[1m\e[32mseting before\e[0m, WALLET NAME..:\e[1m\e[32m$WALLET\e[0m"
  echo -e "Press ANY KEY to use the \e[1m\e[32msame wallet name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$WALLET\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      read -p "Enter wallet name: " WALLET
      echo 'export WALLET='$WALLET >> $HOME/.bash_profile
    else
      echo 'export WALLET='$WALLET >> $HOME/.bash_profile
    fi
  else
  read -p "Enter wallet name: " WALLET
  echo 'export WALLET='$WALLET >> $HOME/.bash_profile
fi


echo "export SEI_CHAIN_ID=atlantis-1" >> $HOME/.bash_profile
echo "export SEI_PORT=${SEI_PORT}" >> $HOME/.bash_profile

echo 'export UNSAFE_SKIP_BACKUP=true' >> $HOME/.bash_profile
echo 'export DAEMON_HOME=~/.sei' >> $HOME/.bash_profile
echo 'export DAEMON_NAME=seid' >> $HOME/.bash_profile
echo 'export DAEMON_RESTART_AFTER_UPGRADE=true' >> $HOME/.bash_profile
echo 'export DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_sei' >> $HOME/.bash_profile

source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name(moniker): \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$SEI_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$SEI_PORT\e[0m"
echo '================================================='
   echo -e "\e[1m\e[35mPlease check the accuracy of the information \e[1m\e[36mCAREFULLY.\e[0m"
   echo -e "\e[1m\e[31mAre the above values correct? [Y/N]\e[0m"
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      echo Yes
    else
      echo No
      sleep 3
    exit 13
    fi

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo add-apt-repository ppa:bashtop-monitor/bashtop -y
sudo apt install curl build-essential git wget jq make gcc tmux tree mc software-properties-common net-tools bashtop qrencode -y

# install go function
installgo () 
  {
	  cd $HOME
	  ver=$1
	  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
	  sudo rm -rf /usr/local/go
	  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
	  rm "go$ver.linux-amd64.tar.gz"
	  sed -i.org '/GOROOT\|GOPATH\|GO111MODULE/d' "$HOME/.bash_profile"
	  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
	  echo 'export GOROOT=/usr/local/go' >> "$HOME"/.bash_profile
	  echo 'export GOPATH=$HOME/go' >> "$HOME"/.bash_profile
	  echo 'export GO111MODULE=on' >> "$HOME"/.bash_profile
	  source ~/.bash_profile
	  echo -e "\e[1m\e[32m Go installation complate... \e[0m" && sleep 2
	}

#go version variable, if need new version change variable
ver="1.18.2"
checkgover=$(go version)
if [ "${checkgover:13:4}" == "${ver:0:4}" ]; then 
	#no need install
	echo "No need to install go-lang, versions are compatible."
	echo "requested version "$ver", installed version "${checkgover:13:6}""
else
  #installation required
  installgo "$ver"
fi


echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
#remove old sei-chain directory
DIR="sei-chain"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo -e "\e[1m\e[32m2. remove old sei-chain directory... \e[0m" && sleep 1
  sudo rm -rf sei-chain
fi
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.6beta
make install 
sudo cp ~/go/bin/seid /usr/local/bin/seid

# config
seid config chain-id $SEI_CHAIN_ID
seid config keyring-backend test
seid config node tcp://localhost:${SEI_PORT}657

# init
seid init $NODENAME --chain-id $SEI_CHAIN_ID

# download genesis and addrbook


# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SEI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SEI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SEI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SEI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SEI_PORT}660\"%" $HOME/.sei/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SEI_PORT}317\"%; s%^address = \":8080\"%address = \":${SEI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SEI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SEI_PORT}091\"%" $HOME/.sei/config/app.toml

#port_description file
echo -e "\e[1m\e[32m create port_description file port_description.txt \e[0m" && sleep 1
echo proxy_app = :${SEI_PORT}658 >port_description_sei.txt
echo laddr = :${SEI_PORT}657 >>port_description_sei.txt
echo pprof_laddr = :${SEI_PORT}060 >>port_description_sei.txt
echo laddr = :${SEI_PORT}656 >>port_description_sei.txt
echo prometheus_listen_addr = :${SEI_PORT}660 >>port_description_sei.txt
echo address = :${SEI_PORT}317 >>port_description_sei.txt
echo address = :${SEI_PORT}080 >>port_description_sei.txt
echo address = :${SEI_PORT}090 >>port_description_sei.txt
echo address = :${SEI_PORT}091 >>port_description_sei.txt

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sei/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei/config/app.toml

# set minimum gas price (developers don't want 0usei min gasfee.)
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"10usei\"/" $HOME/.sei/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei/config/config.toml

# reset
seid tendermint unsafe-reset-all --home $HOME/.sei

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=sei
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start --home $HOME/.sei
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
echo sudo systemctl enable seid
echo sudo systemctl restart seid

echo -e "\e[1m\e[32m5. installing Cosmovisor... \e[0m" && sleep 1

cd $HOME
rm -rf ./cosmos-sdk
git clone --depth 1 --branch main https://github.com/cosmos/cosmos-sdk
cd cosmos-sdk
make cosmovisor

#check binary cosmovisor
if [ ! -f "$HOME/cosmos-sdk/cosmovisor/cosmovisor" ]; then
    echo "cosmovisor not build. \e[1m\e[31mERROR ERROR\e[0m"
    read -r -s -n 1 -p "Press any key to EXIT . . ."
  	exit 13
fi
mkdir -p "$HOME"/.sei/cosmovisor/genesis/bin
cp "$HOME"/go/bin/seid "$HOME"/.sei/cosmovisor/genesis/bin
if [ -f "$HOME/.sei/cosmovisor/genesis/bin/seid" ]; then
     echo "$HOME"/.sei/cosmovisor/genesis/bin/seid file copy successful
     sleep 2
else
      	echo -e "\e[1m\e[31m ERROR $HOME/go/bin/seid not copy $HOME/.sei/cosmovisor/genesis/bin \e[0m"
      	echo -e "\e[1m\e[31m please check $HOME/go/bin/seid file \e[0m"
      	read -r -s -n 1 -p "Press any key to EXIT . . ."
    	exit 13
fi
cd $HOME || { echo "$HOME dizinine girilemiyor"; sleep 10; exit 13;}

#install helpsei command
sudo wget https://raw.githubusercontent.com/snipeTR/sei_help/main/sei_help.sh && chmod +x ./sei_help.sh &&sudo mv ./sei_help.sh /usr/local/bin/helpsei

#run first cosmovisor for $HOME/.sei/cosmovisor/current/bin/seid file link create.
DAEMON_HOME=$HOME/.sei DAEMON_NAME=seid DAEMON_RESTART_AFTER_UPGRADE=true ./cosmos-sdk/cosmovisor/cosmovisor run start
sleep 3
kill "$(pidof cosmovisor)"

#remove execute file from local/bin
rm -rf /usr/local/bin/seid

#add link current seid execute to local/bin
ln -s "$HOME"/.sei/cosmovisor/current/bin/seid /usr/local/bin/seid

mkdir ~/bkup_cosmovisor_sei
echo ulimit -n 1000000 >seid_start_with_cosmovisor.sh
echo UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.sei DAEMON_NAME=seid DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_sei cosmovisor run start init ~/.sei>>seid_start_with_cosmovisor.sh
chmod +x seid_start_with_cosmovisor.sh


echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32m."/"seid_start_with_cosmovisor.sh\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${SEI_PORT}657/status | jq .result.sync_info\e[0m"