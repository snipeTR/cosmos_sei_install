#!/bin/bash
#wget -O stafihub_cosmovisor_install.sh https://raw.githubusercontent.com/snipeTR/cosmos_stafihub_install/main/stafihub_cosmovisor_install.sh && chmod +x stafihub_cosmovisor_install.sh
echo tnx for kj89
	
sleep 1
cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}
#update script download
if [ -f stafihub_cosmovisor_update.sh ]; then rm -rf stafihub_cosmovisor_update.sh; fi
	#alt satir olusturulunca eklencek
#wget -O stafihub_cosmovisor_update.sh https://raw.githubusercontent.com/snipeTR/cosmos_stafihub_install/main/stafihub_cosmovisor_update.sh && chmod +x stafihub_cosmovisor_update.sh

if [ -f ".bash_profile" ]; then 
		if [ -f ".bsh_profil_org" ]; then
			 cp .bash_profile .bsh_profile_org
		fi
fi
if [ -f ".bash_profile" ]; then source "$HOME"/.bash_profile; fi

# delete old line for dublicate.

if [ -f ".bash_profile" ]; then 
sed -i.org '/DAEMON_DATA_BACKUP_DIR\|DAEMON_RESTART_AFTER_UPGRADE\|DAEMON_NAME\|DAEMON_HOME\|UNSAFE_SKIP_BACKUP\|stafihub_PORT\|stafihub_CHAIN_ID\|WALLET\|NODENAME/d' "$HOME/.bash_profile"
fi

# set vars
if [ "$NODENAME" ]; then 
	echo -e "Node name \e[1m\e[32mseting before\e[0m, NODE NAME..:\e[1m\e[32m$NODENAME\e[0m"
  echo -e "Press ANY KEY to use the \e[1m\e[32msame node name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$NODENAME\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      read -p "Enter node name: " NODENAME
      echo "export NODENAME=$NODENAME" >> "$HOME"/.bash_profile
    else
      echo "export NODENAME=$NODENAME" >> "$HOME"/.bash_profile
    fi
  else
  read -p "Enter node name: " NODENAME
  echo "export NODENAME=$NODENAME" >> "$HOME"/.bash_profile
fi


if [ ! "$stafihub_PORT" ]; then stafihub_PORT=13; fi

if [ "$WALLET" ]; then 
	echo -e "Wallet name \e[1m\e[32mseting before\e[0m, WALLET NAME..:\e[1m\e[32m$WALLET\e[0m"
  echo -e "Press ANY KEY to use the \e[1m\e[32msame wallet name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$WALLET\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      read -p "Enter wallet name: " WALLET
      echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile
    else
      echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile
    fi
  else
  read -p "Enter wallet name: " WALLET
  echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile
fi


echo "export stafihub_CHAIN_ID=stafihub-public-testnet-3" >> "$HOME"/.bash_profile
echo "export stafihub_PORT=${stafihub_PORT}" >> "$HOME"/.bash_profile

echo "export UNSAFE_SKIP_BACKUP=true" >> "$HOME"/.bash_profile
echo "export DAEMON_HOME=~/.stafihub" >> "$HOME"/.bash_profile
echo "export DAEMON_NAME=stafihubd" >> "$HOME"/.bash_profile
echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> "$HOME"/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stafihub" >> "$HOME"/.bash_profile

source "$HOME"/.bash_profile

echo '================================================='
echo -e "Your node name(moniker): \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$stafihub_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$stafihub_PORT\e[0m"
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
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:bashtop-monitor/bashtop -y
sudo apt install curl build-essential git wget jq make gcc tmux tree mc software-properties-common net-tools bashtop qrencode -y

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

# download binary
echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}
#remove old stafihub-chain directory
DIR="stafihub"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo -e "\e[1m\e[32m2. remove old stafihub directory... \e[0m" && sleep 1
  sudo rm -rf stafihub
fi
git clone https://github.com/stafihub/stafihub.git
cd stafihub || { echo "Unable to enter stafihub directory"; sleep 1; exit 13;}
git checkout public-testnet-v3
make install 
sudo cp ~/go/bin/stafihubd /usr/local/bin/stafihubd
echo -e "\e[1m\e[32m  stafihubd build end... \e[0m"

# config
echo -e "\e[1m\e[32m-- stafihubd config chain-id "$stafihub_CHAIN_ID" \e[0m"
stafihubd config chain-id "$stafihub_CHAIN_ID"
echo -e "\e[1m\e[32m-- stafihubd config keyring-backend test \e[0m"
stafihubd config keyring-backend test
echo -e "\e[1m\e[32m-- stafihubd config node tcp://localhost:"${stafihub_PORT}657" \e[0m"
stafihubd config node tcp://localhost:"${stafihub_PORT}657"

# init
echo -e "\e[1m\e[32m-- stafihubd init "$NODENAME" --chain-id "$stafihub_CHAIN_ID" \e[0m"
stafihubd init "$NODENAME" --chain-id "$stafihub_CHAIN_ID"

# reset
stafihubd tendermint unsafe-reset-all --home "$HOME"/.stafihub

# download genesis and addrbook
wget -qO $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/stafihub/network/main/testnets/stafihub-public-testnet-3/genesis.json"
wget -qO $HOME/.stafihub/config/addrbook.json "https://raw.githubusercontent.com/stafihub/network/main/testnets/stafihub-public-testnet-3/addrbook.json"

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${stafihub_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${stafihub_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${stafihub_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${stafihub_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${stafihub_PORT}660\"%" "$HOME"/.stafihub/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${stafihub_PORT}317\"%; s%^address = \":8080\"%address = \":${stafihub_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${stafihub_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${stafihub_PORT}091\"%" "$HOME"/.stafihub/config/app.toml

#port_description file
sudo rm -rf usr/local/bin/stafihubport
echo -e "\e[1m\e[32m create stafihubport command /usr/local/bin \e[0m" && sleep 3
echo echo curl -s localhost:${stafihub_PORT}657/status >stafihubport
echo echo proxy_app = :${stafihub_PORT}658 >>stafihubport
echo echo laddr = :${stafihub_PORT}657 >>stafihubport
echo echo pprof_laddr = :${stafihub_PORT}060 >>stafihubport
echo echo laddr = :${stafihub_PORT}656 >>stafihubport
echo echo prometheus_listen_addr = :${stafihub_PORT}660 >>stafihubport
echo echo address = :${stafihub_PORT}317 >>stafihubport
echo echo address = :${stafihub_PORT}080 >>stafihubport
echo echo address = :${stafihub_PORT}090 >>stafihubport
echo echo address = :${stafihub_PORT}091 >>stafihubport
chmod +x ./stafihubport
sudo mv ./stafihubport /usr/local/bin

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" "$HOME"/.stafihub/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" "$HOME"/.stafihub/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" "$HOME"/.stafihub/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" "$HOME"/.stafihub/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" "$HOME"/.stafihub/config/app.toml

# set minimum gas price (developers don't want 0ufis min gasfee.)
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/" "$HOME"/.stafihub/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" "$HOME"/.stafihub/config/config.toml

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/stafihubd.service > /dev/null <<EOF
[Unit]
Description=stafihub
After=network-online.target

[Service]
User=$USER
ExecStart=$(which stafihubd) start --home "$HOME"/.stafihub
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
echo sudo systemctl enable stafihubd
echo sudo systemctl restart stafihubd

echo -e "\e[1m\e[32m5. installing Cosmovisor... \e[0m" && sleep 1

cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}
rm -rf ./cosmos-sdk
git clone --depth 1 --branch main https://github.com/cosmos/cosmos-sdk
cd cosmos-sdk || { echo "Unable to enter cosmos-sdk directory"; sleep 1; exit 13;}
make cosmovisor

#check binary cosmovisor
if [ ! -f "$HOME/cosmos-sdk/cosmovisor/cosmovisor" ]; then
    echo "cosmovisor not build. \e[1m\e[31mERROR ERROR\e[0m"
    read -r -s -n 1 -p "Press any key to EXIT . . ."
  	exit 13
fi
mkdir -p "$HOME"/.stafihub/cosmovisor/genesis/bin
cp "$HOME"/go/bin/stafihubd "$HOME"/.stafihub/cosmovisor/genesis/bin
if [ -f "$HOME/.stafihub/cosmovisor/genesis/bin/stafihubd" ]; then
     echo "$HOME"/.stafihub/cosmovisor/genesis/bin/stafihubd file copy successful
     sleep 2
else
      	echo -e "\e[1m\e[31m ERROR $HOME/go/bin/stafihubd not copy $HOME/.stafihub/cosmovisor/genesis/bin \e[0m"
      	echo -e "\e[1m\e[31m please check $HOME/go/bin/stafihubd file \e[0m"
      	read -r -s -n 1 -p "Press any key to EXIT . . ."
    	exit 13
fi
cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}

#install helpstafihub and helpstafihubupdate command
sudo wget https://raw.githubusercontent.com/snipeTR/stafihub_help/main/stafihub_help.sh && chmod +x ./stafihub_help.sh &&sudo mv ./stafihub_help.sh /usr/local/bin/helpstafi
sudo wget https://raw.githubusercontent.com/snipeTR/stafihub_help/main/helpstafihubupdate && chmod +x ./helpstafihubupdate &&sudo mv ./helpstafihubupdate /usr/local/bin/helpstafihubupdate

#Crontab remove old helpstafihubupdate
crontab -l | grep -v 'sudo /usr/local/bin/helpstafihubupdate'  | crontab -

#Crontab remove add helpstafihubupdate evry 00:00, 06:00, 12:00, 18:00 hour update helpstafihub
(crontab -l ; echo "0 0,6,12,18 * * * sudo /usr/local/bin/helpstafihubupdate") | crontab -


#run first cosmovisor for $HOME/.stafihub/cosmovisor/current/bin/stafihubd file link create.
sudo cp "./cosmos-sdk/cosmovisor/cosmovisor" "/usr/local/bin/"
DAEMON_HOME=$HOME/.stafihub DAEMON_NAME=stafihubd DAEMON_RESTART_AFTER_UPGRADE=true ./cosmos-sdk/cosmovisor/cosmovisor run start&
sleep 10
kill "$(pidof cosmovisor)"
read -p "                          kurulum duraklatildi."
#remove execute file from local/bin
sudo rm -rf /usr/local/bin/stafihubd
echo /usr/local/bin/stafihubd silindi

#add link current stafihubd execute to local/bin
sudo ln -s "$HOME"/.stafihub/cosmovisor/current/bin/stafihubd /usr/local/bin/stafihubd
echo /usr/local/bin/stafihubd link olusturuldu

mkdir ~/bkup_cosmovisor_stafihub
echo "ulimit -n 1000000" >stafihubd_start_with_cosmovisor.sh
echo ""if" [ ! \"\$(systemctl is-active stafihubd)\" == \"inactive\" ]; "then" systemctl stop stafihubd && systemctl disable stafihubd && echo -e \"\\e[1m\\e[36mstafihubd service has been shut down and disabled.\\n \\e[0m \"; "fi"" >>stafihubd_start_with_cosmovisor.sh
echo ""if" [ \"\$(systemctl is-active stafihubd)\" == \"inactive\"  ]; "then" echo -e \"\\e[1m\\e[36mstafihubd service is not running, no need to turn off stafihubd service.\\n \\e[0m \"; "fi"" >>stafihubd_start_with_cosmovisor.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stafihubd_start_with_cosmovisor.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n\\n\\n-Currently cosmovisor is already running..\\n-if you don't know what you are doing\\nplease close the running cosmovisor and try again.\\n-press \\e[1m\\e[32m[F/f]\\e[1m\\e[31m to go ahead and \\e[1m\\e[36mforce cosmovisor to run.\\n\\e[1m\\e[31m-press \\e[1m\\e[32mANY KEY\\e[1m\\e[31m run it again cosmovisor \\e[1m\\e[36m(The currently running cosmovisor is terminated.) \\n\\n\\n\\e[0m\"; "fi"" >>stafihubd_start_with_cosmovisor.sh
echo "read -rsn1 answer" >>stafihubd_start_with_cosmovisor.sh
echo  ""if" [ \""\$"answer\" == \"\${answer#[Ff]}\" ] ; "then" pkill cosmovisor; "fi"" >>stafihubd_start_with_cosmovisor.sh
echo "UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.stafihub DAEMON_NAME=stafihubd DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stafihub cosmovisor run start init ~/.stafihub" >>stafihubd_start_with_cosmovisor.sh
chmod +x stafihubd_start_with_cosmovisor.sh
echo stafihubd_start_with_cosmovisor.sh kontrol et.
read -p "                          kurulum duraklatildi."
echo "ulimit -n 1000000" >stafihubd_start_with_service.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stafihubd_start_with_service.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n\\n\\n-Currently cosmovisor is already running..\\n-cosmovisor shutdown..\\n\\e[0m\" && pkill cosmovisor; "fi"" >>stafihubd_start_with_service.sh
echo "sleep 2" >>stafihubd_start_with_service.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stafihubd_start_with_service.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n-Failed closing cosmovisor...\\n-cannot be terminated..\\n\\e[0m\" && exit 2; "fi"" >>stafihubd_start_with_service.sh
echo "systemctl enable stafihubd" >>stafihubd_start_with_service.sh
echo "systemctl start stafihubd" >>stafihubd_start_with_service.sh
echo "sleep 3" >>stafihubd_start_with_service.sh
echo ""if" [ \"\$(systemctl is-active stafihubd)\" == \"inactive\"  ]; "then" echo -e \"\\e[1m\\e[31mstafihubd service is not running, \\nTry running the script again.\\n\\e[0m \" && exit 2; "fi"" >>stafihubd_start_with_service.sh
echo ""if" [ ! \"\$(systemctl is-active stafihubd)\" == \"inactive\" ]; "then" echo -e \"\\e[1m\\e[32mstafihubd service is currently running.\\e[0m\"; "fi"" >>stafihubd_start_with_service.sh
chmod +x stafihubd_start_with_service.sh
echo stafihubd_start_with_service.sh kontrol et.
read -p "                          kurulum duraklatildi."


echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32m."/"stafihubd_start_with_cosmovisor.sh\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${stafihub_PORT}657/status | jq .result.sync_info\e[0m"
echo " "
echo " "
echo " "
echo -e "Do you want to create wallets? [Y/N]"
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
    	   echo -e "press \e[1m\e[32m[Y]\e[0m for \e[1m\e[34mnew wallet\e[0m. Press \e[1m\e[32many key\e[0m for \e[1m\e[34mrecover wallet\e[0m with mnemonic.\e[0m"
         read -rsn1 aanswer
         if [ "$aanswer" != "${aanswer#[Yy]}" ] ;then
         	  if [ $(stafihubd keys list --output json | jq .[0].name) == "\"$WALLET"\" ]; then 
         		  echo -e "The wallet named..:\e[1m\e[34m$WALLET\e[0m is already installed on your system,"
         		  read -p "Enter new wallet name: " WALLETT
         		  stafihubd keys add $WALLETT
         	  else
         	    stafihubd keys add $WALLET
         	  fi
         else
           echo -e "\e[1m\e[32mPlease enter the recovery words for wallet.\e[0m wallet name..: \e[1m\e[35m$WALLET.\e[0m"
           RET=987
           until [ ${RET} -eq 0 ]; do
              if [ ! ${RET} -eq 987 ]; then echo "\e[1m\e[31mYour recovery words are incorrect, please re-enter carefully.\e[0m"; fi
              stafihubd keys add $WALLET --recovery
              RET=$?
           done
         fi
    else
      echo No
      sleep 3
    exit 0
    fi

echo "----------------------------------------------------"
echo -e "\e[0m\e[36mThis is a testnet. you need stafihub token to create validator. \nFor detailed information, I recommend you to join the stafihub official discord group.\n \e[1m\e[32mhttps://discord.gg/vcCTGnqTW6\e[0m"
echo -e "\e[0m\e[36mYou can get detailed information about stafihub NODE commands with the helpstafi command.\e[0m"
echo -e "\e[0m\e[01mIf you want to run stafihub public-testnet-v3 NODE with cosmovisor. Run the script \e[0m\e[36m"stafihubd_start_with_cosmovisor.sh".\e[0m"
echo "----------------------------------------------------"
