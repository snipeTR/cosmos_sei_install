#!/bin/bash

#  discord
#
#  snipeTR#8374 & karboran#2719
# beta1.5v

echo tnx for kj89
sleep 1
cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}
#update script download
if [ -f stratos_cosmovisor_update.sh ]; then rm -rf stratos_cosmovisor_update.sh; fi
wget -O "stratos_cosmovisor_update.sh" "https://raw.githubusercontent.com/snipeTR/cosmos_sei_install/main/stratos_cosmovisor_update.sh> /dev/null 2>&1 && chmod +x stratos_cosmovisor_update.sh"

if [ -f ".bash_profile" ]; then 
		if [ -f ".bsh_profil_org" ]; then
			 cp .bash_profile .bsh_profile_org
		fi
fi
if [ -f ".bash_profile" ]; then source "$HOME"/.bash_profile; fi

# delete old line for dublicate.

if [ -f ".bash_profile" ]; then 
sed -i.org '/DAEMON_DATA_BACKUP_DIR\|DAEMON_RESTART_AFTER_UPGRADE\|DAEMON_NAME\|DAEMON_HOME\|UNSAFE_SKIP_BACKUP\|stratos_PORT\|STRATOS_CHAIN_ID\|WALLET\|NODENAME/d' "$HOME/.bash_profile"
fi

# set vars
if [ "$NODENAME" ]; then 
  echo -e "\nNode name \e[1m\e[32mseting before\e[0m, NODE NAME..:\e[1m\e[32m$NODENAME\e[0m"
  echo -e "Press [ANY KEY] to use the \e[1m\e[32msame node name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$NODENAME\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
    	NODENAME=''
    	 while [ ! "$(echo $NODENAME | wc -m)" -gt "1" ]; do
         	read -p "Enter Node name: " NODENAME
         	if [ ! "$(echo $NODENAME | wc -m)" -gt "1" ]; then echo -e "\e[1m\e[31m*** Node name cannot be empty.\e[0m" ; fi
         done 
      echo "export NODENAME=$NODENAME" >> "$HOME"/.bash_profile
    fi
  else
    while [ ! "$(echo $NODENAME | wc -m)" -gt "1" ]; do
       	read -p "Enter Node name: " NODENAME
       	if [ ! "$(echo $NODENAME | wc -m)" -gt "1" ]; then echo -e "\e[1m\e[31m*** Node name cannot be empty.\e[0m" ; fi
       done 
fi
echo "export NODENAME=$NODENAME" >> "$HOME"/.bash_profile

if [ ! "$stratos_PORT" ]; then stratos_PORT=7; fi

if [ "$WALLET" ]; then 
	echo -e "\nWallet name \e[1m\e[32mseting before\e[0m, WALLET NAME..:\e[1m\e[32m$WALLET\e[0m"
  echo -e "Press ANY KEY to use the \e[1m\e[32msame wallet name\e[0m."
  echo -e "Press [Y/y] to change \e[1m\e[32m$WALLET\e[0m."
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
    	WALLET=''
    	 while [ ! "$(echo $WALLET | wc -m)" -gt "1" ]; do 
         	read -p "Enter Wallet name: " WALLET
         	if [ ! "$(echo $WALLET | wc -m)" -gt "1" ] ; then echo -e "\e[1m\e[31m*** Wallet name cannot be empty.\e[0m" ; fi
         done 
      echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile
    fi
  else
       while [ ! "$(echo $WALLET | wc -m)" -gt "1" ]; do
       	read -p "Enter Wallet name: " WALLET
       	if [ ! "$(echo $WALLET | wc -m)" -gt "1" ]; then echo -e "\e[1m\e[31m*** Wallet name cannot be empty.\e[0m" ; fi
       done 
fi
echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile

echo "export STRATOS_CHAIN_ID=tropos-4" >> "$HOME"/.bash_profile
echo "export stratos_PORT=${stratos_PORT}" >> "$HOME"/.bash_profile

echo "export UNSAFE_SKIP_BACKUP=true" >> "$HOME"/.bash_profile
echo "export DAEMON_HOME=~/.stchaind" >> "$HOME"/.bash_profile
echo "export DAEMON_NAME=stchaind" >> "$HOME"/.bash_profile
echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> "$HOME"/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stchain" >> "$HOME"/.bash_profile

source "$HOME"/.bash_profile

echo '================================================='
echo -e "Your node name(moniker): \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$STRATOS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$stratos_PORT\e[0m"
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
sudo apt install curl build-essential git wget jq make gcc tmux tree mc software-properties-common net-tools bashtop qrencode htop -y

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
#remove old stratos-chain directory
DIR="stratos-chain"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo -e "\e[1m\e[32m2. remove old stratos-chain directory... \e[0m" && sleep 1
  sudo rm -rf stratos-chain
fi
git clone https://github.com/stratosnet/stratos-chain.git
cd stratos-chain || { echo "Unable to enter stratos-chain directory"; sleep 1; exit 13;}
git checkout v0.8.0
make build
sudo cp ~/go/bin/stchaind /usr/local/bin/stchaind
echo -e "\e[1m\e[32m  stchaind build end... \e[0m"

# download genesis and addrbook
wget -qO $HOME/.stchaind/config/genesis.json "https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/tropos-4/genesis.json"
wget -qO $HOME/.stchaind/config/config.toml "https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/tropos-4/config.toml"

# config
echo -e "\e[1m\e[32m-- stchaind config chain-id "$STRATOS_CHAIN_ID" \e[0m"
stchaind config chain-id "$STRATOS_CHAIN_ID"
echo -e "\e[1m\e[32m-- stchaind config node tcp://localhost:"${stratos_PORT}657" \e[0m"
stchaind config node tcp://localhost:"${stratos_PORT}657"
echo -e "\e[1m\e[32m-- stchaind config keyring-backend test \e[0m"
stchaind config keyring-backend test

# init
echo -e "\e[1m\e[32m-- stchaind init "$NODENAME" --chain-id "$STRATOS_CHAIN_ID" \e[0m"
stchaind init "$NODENAME" --chain-id "$STRATOS_CHAIN_ID"

# reset
stchaind tendermint unsafe-reset-all --home "$HOME"/.stchaind

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${stratos_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${stratos_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${stratos_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${stratos_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${stratos_PORT}660\"%" "$HOME"/.stchaind/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${stratos_PORT}317\"%; s%^address = \":8080\"%address = \":${stratos_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${stratos_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${stratos_PORT}091\"%" "$HOME"/.stchaind/config/app.toml

#port_description file
sudo rm -rf usr/local/bin/stchainport
echo -e "\e[1m\e[32m create stchainport command /usr/local/bin \e[0m" && sleep 3
echo echo curl -s localhost:${stratos_PORT}657/status >stchainport
echo echo proxy PORT = :${stratos_PORT}658 >>stchainport
echo echo RPC server PORT = :${stratos_PORT}657 >>stchainport
echo echo pprof listen PORT = :${stratos_PORT}060 >>stchainport
echo echo p2p PORT = :${stratos_PORT}656 >>stchainport
echo echo prometheus PORT = :${stratos_PORT}660 >>stchainport
echo echo api server PORT = :${stratos_PORT}317 >>stchainport
echo echo rosetta PORT = :${stratos_PORT}080 >>stchainport
echo echo gRPC server PORT = :${stratos_PORT}090 >>stchainport
echo echo gRPC-web server PORT = :${stratos_PORT}091 >>stchainport
chmod +x ./stchainport
sudo mv ./stchainport /usr/local/bin

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" "$HOME"/.stchaind/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" "$HOME"/.stchaind/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" "$HOME"/.stchaind/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" "$HOME"/.stchaind/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" "$HOME"/.stchaind/config/app.toml

# set minimum gas price (developers don't want 0ustos min gasfee.)
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"10ustos\"/" "$HOME"/.stchaind/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" "$HOME"/.stchaind/config/config.toml

echo -e "\e[1m\e[32m4. Creating service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/stchaind.service > /dev/null <<EOF
[Unit]
Description=stratos
After=network-online.target

[Service]
User=$USER
ExecStart=$(which stchaind) start --home "$HOME"/.stchaind
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
echo -e "\e[1m\e[32mservice command info... \e[0m"
sudo systemctl daemon-reload
echo -e "echo sudo systemctl enable stchaind\t\tfor automatic service start when the server is up"
echo -e "echo sudo systemctl disable stchaind\t\tdisable for automatic service start when the server is up"
echo -e "echo sudo systemctl start stchaind\t\tstarting validator for linux service \e[1m\e[31mplease dont use run cosmovisor\e[0m"
echo -e "echo sudo systemctl stop stchaind\t\tstop validator"
echo -e "echo sudo systemctl restart stchaind\t\tre start validator"
echo -e "\e[1m\e[32mNOTE:Please do not use these services while working with cosmovisor.\e[0m"

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
mkdir -p "$HOME"/.stchaind/cosmovisor/genesis/bin
cp "$HOME"/go/bin/stchaind "$HOME"/.stchaind/cosmovisor/genesis/bin
if [ -f "$HOME/.stchaind/cosmovisor/genesis/bin/stchaind" ]; then
     echo "$HOME"/.stchaind/cosmovisor/genesis/bin/stchaind file copy successful
     sleep 2
else
      	echo -e "\e[1m\e[31m ERROR $HOME/go/bin/stchaind not copy $HOME/.stchaind/cosmovisor/genesis/bin \e[0m"
      	echo -e "\e[1m\e[31m please check $HOME/go/bin/stchaind file \e[0m"
      	read -r -s -n 1 -p "Press any key to EXIT . . ."
    	exit 13
fi
cd "$HOME" || { echo "Unable to enter $HOME directory"; sleep 1; exit 13;}

#install helpstratos and helpstratosupdate command
sudo wget https://raw.githubusercontent.com/snipeTR/sei_help/main/stratos_help.sh && chmod +x ./stratos_help.sh &&sudo mv ./stratos_help.sh /usr/local/bin/helpstratos
sudo wget https://raw.githubusercontent.com/snipeTR/sei_help/main/helpstratosupdate && chmod +x ./helpstratosupdate &&sudo mv ./helpstratosupdate /usr/local/bin/helpstratosupdate

#Crontab remove old helpstratosupdate
crontab -l | grep -v 'sudo /usr/local/bin/helpstratosupdate'  | crontab -

#Crontab remove add helpstratosupdate evry 00:00, 06:00, 12:00, 18:00 hour update helpstratos
(crontab -l ; echo "0 0,6,12,18 * * * sudo /usr/local/bin/helpstratosupdate") | crontab -


#run first cosmovisor for $HOME/.stchaind/cosmovisor/current/bin/stchaind file link create.
sudo cp "./cosmos-sdk/cosmovisor/cosmovisor" "/usr/local/bin/"
echo "please wait..."
DAEMON_HOME=$HOME/.stchaind DAEMON_NAME=stchaind DAEMON_RESTART_AFTER_UPGRADE=true ./cosmos-sdk/cosmovisor/cosmovisor run start& > /dev/null 2>&1
sleep 4
kill "$(pidof cosmovisor)"
wait

#remove execute file from local/bin
sudo rm -rf /usr/local/bin/stchaind

#add link current stchaind execute to local/bin
sudo ln -s "$HOME"/.stchaind/cosmovisor/current/bin/stchaind /usr/local/bin/stchaind

mkdir ~/bkup_cosmovisor_stratos
echo "ulimit -n 1000000" >stchaind_start_with_cosmovisor.sh
echo ""if" [ ! \"\$(systemctl is-active stchaind)\" == \"inactive\" ]; "then" systemctl stop stchaind && systemctl disable stchaind && echo -e \"\\e[1m\\e[36mstchaind service has been shut down and disabled.\\n \\e[0m \"; "fi"" >>stchaind_start_with_cosmovisor.sh
echo ""if" [ \"\$(systemctl is-active stchaind)\" == \"inactive\"  ]; "then" echo -e \"\\e[1m\\e[36mstchaind service is not running, no need to turn off stchaind service.\\n \\e[0m \"; "fi"" >>stchaind_start_with_cosmovisor.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stchaind_start_with_cosmovisor.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n\\n\\n-Currently cosmovisor is already running..\\n-if you don't know what you are doing\\nplease close the running cosmovisor and try again.\\n-press \\e[1m\\e[32m[F/f]\\e[1m\\e[31m to go ahead and \\e[1m\\e[36mforce cosmovisor to run.\\n\\e[1m\\e[31m-press \\e[1m\\e[32mANY KEY\\e[1m\\e[31m run it again cosmovisor \\e[1m\\e[36m(The currently running cosmovisor is terminated.) \\n\\n\\n\\e[0m\"; "fi"" >>stchaind_start_with_cosmovisor.sh
echo "read -rsn1 answer" >>stchaind_start_with_cosmovisor.sh
echo  ""if" [ \""\$"answer\" == \"\${answer#[Ff]}\" ] ; "then" pkill cosmovisor; "fi"" >>stchaind_start_with_cosmovisor.sh
echo "UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.stchaind DAEMON_NAME=stchaind DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stratos cosmovisor run start init ~/.stchaind" >>stchaind_start_with_cosmovisor.sh
chmod +x stchaind_start_with_cosmovisor.sh

echo "ulimit -n 1000000" >stchaind_start_with_service.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stchaind_start_with_service.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n\\n\\n-Currently cosmovisor is already running..\\n-cosmovisor shutdown..\\n\\e[0m\" && pkill cosmovisor; "fi"" >>stchaind_start_with_service.sh
echo "sleep 2" >>stchaind_start_with_service.sh
echo "pgrep cosmovisor >/dev/null 2>&1" >>stchaind_start_with_service.sh
echo ""if" [ \"\$?\" -eq \"0\" ]; "then" echo -e \"\\e[1m\\e[31m\\n-Failed closing cosmovisor...\\n-cannot be terminated..\\n\\e[0m\" && exit 2; "fi"" >>stchaind_start_with_service.sh
echo "systemctl enable stchaind" >>stchaind_start_with_service.sh
echo "systemctl start stchaind" >>stchaind_start_with_service.sh
echo "sleep 3" >>stchaind_start_with_service.sh
echo ""if" [ \"\$(systemctl is-active stchaind)\" == \"inactive\"  ]; "then" echo -e \"\\e[1m\\e[31mstchaind service is not running, \\nTry running the script again.\\n\\e[0m \" && exit 2; "fi"" >>stchaind_start_with_service.sh
echo ""if" [ ! \"\$(systemctl is-active stchaind)\" == \"inactive\" ]; "then" echo -e \"\\e[1m\\e[32mstchaind service is currently running.\\e[0m\"; "fi"" >>stchaind_start_with_service.sh
chmod +x stchaind_start_with_service.sh


echo '=============== SETUP FINISHED ==================='
echo -e "\n\e[1m\e[32mHere are some \e[0mCOMANDS\e[1m\e[32m that will make your validator job easier.\n\n\e[1m\e[32mhelpstratos\n\e[1m\e[34mIt gives information about some commands about stratos-chain validator.\nstchaind service or application must be running.\n\n\e[1m\e[32mhelpstratosupdate\n\e[1m\e[34mhelpstratos updates the command.\n\n\e[1m\e[32mstratosport\n\e[1m\e[34mLists all ports used by stchaind.\ndetailed information in $HOME/.stchaind/config/config.toml\e[0m\n\n\n"
sleep 2
echo -e "Do you want to create wallets? [Y/N]"
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
    	   echo -e "press \e[1m\e[32m[Y]\e[0m for \e[1m\e[34mnew wallet\e[0m. \nPress \e[1m\e[32m[any key]\e[0m for \e[1m\e[34mrecover wallet\e[0m with mnemonic.\e[0m"
         read -rsn1 aanswer
         if [ "$aanswer" != "${aanswer#[Yy]}" ] ;then
         	  if [[ $(stchaind keys list --output json | jq .[0].name) == "\"$WALLET"\" || $(stchaind keys list --output json | jq .[1].name) == "\"$WALLET"\" || $(stchaind keys list --output json | jq .[2].name) == "\"$WALLET"\" || $(stchaind keys list --output json | jq .[3].name) == "\"$WALLET"\" ]]; then 
         		  echo -e "The wallet named..:\e[1m\e[34m$WALLET\e[0m is already installed on your system,"
         		  read -p "Enter \e[1m\e[34mnew\e[0m wallet name: " WALLETT
         		  
         		  echo "export WALLET=$WALLET" >> "$HOME"/.bash_profile
         		  stchaind keys add --hd-path "m/44'/606'/0'/0/0" --keyring-backend $WALLETT
         	  else
         	    stchaind keys add --hd-path "m/44'/606'/0'/0/0" --keyring-backend $WALLET
         	  fi
         	 echo -e "\n\e[0m\e[31mThe top line is 24 words.\e[0m \e[0m\e[36mThese words are a secret, do not publish, do not show in public.\e[0m\n\n\n"
         else
           echo -e "\n\e[1m\e[32mPlease enter the recovery words for wallet.\e[0m wallet name..: \e[1m\e[35m$WALLET.\e[0m"
           RET=987
           until [ ${RET} -eq 0 ]; do
              if [ ! ${RET} -eq 987 ]; then echo "\e[1m\e[31mYour recovery words are incorrect, please re-enter carefully.\e[0m"; fi
              stchaind keys add $WALLET --recover
              RET=$?
           done
         fi
    else
      echo Your answer No. please create wallet
      sleep 1
    exit 0
    fi

echo "----------------------------------------------------"
echo -e "\e[0m\e[36mThis is a testnet. you need stratos token to create validator. \nFor detailed information, I recommend you to join the stratos-chain official discord group.\n \e[1m\e[32mhttps://discord.gg/vcCTGnqTW6\e[0m"
echo -e "\e[0m\e[36mYou can get detailed information about stratos NODE commands with the helpstratos command.\e[0m"
echo -e "\e[0m\e[01mIf you want to run stratos-chain atlantic-1 NODE with cosmovisor. Run the script \e[0m\e[36m"stchaind_start_with_cosmovisor.sh".\e[0m"
echo -e "\e[0m\e[01mIf you want to run stratos-chai atlantic-1 NODE with linux services. Run the script \e[0m\e[36m"stchaind_start_with_service.sh".\e[0m"
echo "----------------------------------------------------"
