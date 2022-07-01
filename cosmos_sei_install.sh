#wget https://raw.githubusercontent.com/snipeTR/cosmos_sei_install/main/cosmos_sei_install.sh && chmod +x cosmos_sei_install.sh %% ./cosmos_sei_install.sh
if [ ! $NODENAME ]; then
	read -p "Node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=sei-testnet-2" >> $HOME/.bash_profile
echo "DAEMON_RESTART_AFTER_UPGRADE=true" >> $HOME/.bash_profile
echo "DAEMON_NAME=seid" >> $HOME/.bash_profile
echo "DAEMON_HOME=$HOME/.sei" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Node name: ' $NODENAME
echo 'wallet name: ' $WALLET
echo 'Chain ismi: ' $CHAIN_ID
echo '================================================='

echo -e "\e[1m\e[32m1. Update and Upgrade check... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. installing tools and libs... \e[0m" && sleep 1
# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install go
ver="1.18.3"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.Bash_Profile
go version

echo -e "\e[1m\e[32m3. kutuphaneler indirilip yukleniyor... \e[0m"

# download binary
cd $HOME
seidver=1.0.2beta
git clone --depth 1 --branch $seidver https://github.com/sei-protocol/sei-chain.git
cd sei-chain && make install
go build -o build/seid ./cmd/seid
chmod +x ./build/seid && sudo cp ./build/seid /usr/local/bin/seid

sleep 1

cp $HOME/go/bin/seid /usr/local/bin/

mv $HOME/.sei-chain $HOME/.sei
#mv $HOME/sei-chain $HOME/sei

# config
seid config chain-id $CHAIN_ID
seid config keyring-backend file

  CONFIG_PATH="$HOME/.sei/config/config.toml"


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 150/g' $CONFIG_PATH
  sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 150/g' $CONFIG_PATH
  sed -i 's/max_packet_msg_payload_size =.*/max_packet_msg_payload_size = 10240/g' $CONFIG_PATH
  sed -i 's/send_rate =.*/send_rate = 20480000/g' $CONFIG_PATH
  sed -i 's/recv_rate =.*/recv_rate = 20480000/g' $CONFIG_PATH
  sed -i 's/max_txs_bytes =.*/max_txs_bytes = 10737418240/g' $CONFIG_PATH
  sed -i 's/^size =.*/size = 5000/g' $CONFIG_PATH
  sed -i 's/max_tx_bytes =.*/max_tx_bytes = 2048576/g' $CONFIG_PATH
  sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_PATH
  sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_PATH
  sed -i 's/timeout_commit =.*/timeout_commit = "100ms"/g' $CONFIG_PATH
  sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = true/g' $CONFIG_PATH
else
  printf "Platform not supported, please ensure that the following values are set in your config.toml:\n"
  printf "###          Mempool Configuration Option          ###\n"
  printf "\t size = 5000\n"
  printf "\t max_txs_bytes = 10737418240\n"
  printf "\t max_tx_bytes = 2048576\n"
  printf "###           P2P Configuration Options             ###\n"
  printf "\t max_num_inbound_peers = 150\n"
  printf "\t max_num_outbound_peers = 150\n"
  printf "\t max_packet_msg_payload_size = 10240\n"
  printf "\t send_rate = 20480000\n"
  printf "\t recv_rate = 20480000\n"
  printf "###         Consensus Configuration Options         ###\n"
  printf "\t timeout_prevote = \"100ms\"\n"
  printf "\t timeout_precommit = \"100ms\"\n"
  printf "\t timeout_commit = \"100ms\"\n"
  printf "\t skip_timeout_commit = true\n"
  exit 1
fi




# init
seid init $NODENAME --chain-id $CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-testnet-2/genesis.json"
wget -qO $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-testnet-2/addrbook.json"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei/config/app.toml

# PEERS="8c6d2fc68f02ba8127fb8d5a7a65cbc75f57d05b@167.172.186.140:36656,6a605a26b1b4ac6baac1f06dcc5bc6e6d0a8be46@213.136.88.4:26656,17381b81322b23371b4882b2139fe06bcbf4d29e@173.212.212.197:36376,c951b5be19b4406e95a50abed0f1886ed38ed28a@89.163.164.207:26656,b03f9917af7556b4958f7eb23f18a77eba81bc1f@194.146.12.169:36376,3370dab8eaa935f4bc6cfad81e0af751caee5686@195.2.84.133:26656"
# sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei/config/app.toml

sleep 1

#Change port 37
#sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:36378\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:36377\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6371\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:36376\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":36370\"%" $HOME/.sei/config/config.toml
#sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9370\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9371\"%" $HOME/.sei/config/app.toml
#sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:36377\"%" $HOME/.sei/config/client.toml
#external_address=$(wget -qO- eth0.me)
#sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:36376\"/" $HOME/.sei/config/config.toml

sleep 1 

# reset
seid unsafe-reset-all

echo -e "\e[1m\e[32m4. Servisler baslatiliyor... \e[0m" && sleep 1
# create service
tee $HOME/seid.service > /dev/null <<EOF
[Unit]
Description=seid
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which seid) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/seid.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
#sudo systemctl enable seid
#sudo systemctl restart seid

#cosmovisor install

#~/.sei/cosmovisor
#├── current -> genesis or upgrades/<name>
#├── genesis
#│   └── bin
#│       └── seid
#├── upgrades
#│   └── 1.0.3beta
#│       ├── bin
#│       │   └── seid
#│       └── upgrade-info.json
#├── upgrades
#│   └── 1.0.4beta
#│       ├── bin
#│       │   └── seid
#│        └── upgrade-info.json
#└── upgrades
#    └── 1.0.5beta%20upgrade
#        ├── bin
#        │   └── seid
#        └── upgrade-info.json


visorver=v1.1.0
cd $HOME
#git clone git@github.com:cosmos/cosmos-sdk
git clone https://github.com/cosmos/cosmos-sdk
cd cosmos-sdk
git checkout cosmovisor/$visorver
make cosmovisor

# Checkout the binary for genesis 1.0.2beta 
# if not right version exit script.
mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin
seidbuildver=$($HOME/go/bin/seid version)
if [ "$seidbuildver" == "$seidver" ]; then
    cp $HOME/go/bin/seid $DAEMON_HOME/cosmovisor/genesis/bin
else
    echo -e "\e[1m\e[31m2. Error version not match $seidver \e[0m"
    echo -e "\e[1m\e[31m2. please check $HOME/go/bin/seid version file \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
exit 13
fi



# Checkout the binary for 1.0.3beta
seidver=1.0.3beta
cd $HOME
rm -rf sei-chain
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain/
git fetch --tags -f
git checkout $seidver
# Build the new tool
make install
go build -o build/seid ./cmd/seid
# Checkout the binary for 1.0.xbeta
# if not right version exit script.
cd $HOME
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$seidver/bin

if [ "$seidbuildver" == "$seidver" ]; then
    cp $HOME/go/bin/seid $DAEMON_HOME/cosmovisor/upgrades/$seidver/bin
else
    echo -e "\e[1m\e[31m3. Error version not match $seidver \e[0m"
    echo -e "\e[1m\e[31m3. please check $HOME/go/bin/seid version file \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
exit 13
fi

# Checkout the binary for 1.0.4beta
seidver=1.0.4beta
cd $HOME
rm -rf sei-chain
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain/
git fetch --tags -f
git checkout $seidver
# Build the new tool
make install
go build -o build/seid ./cmd/seid
# Checkout the binary for 1.0.xbeta
# if not right version exit script.
cd $HOME
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$seidver/bin
seidbuildver=$($HOME/go/bin/seid version)

if [ "$seidbuildver" == "$seidver" ]; then
    cp $HOME/go/bin/seid $DAEMON_HOME/cosmovisor/upgrades/$seidver/bin
else
    echo -e "\e[1m\e[31m4. Error version not match $seidver \e[0m"
    echo -e "\e[1m\e[31m4. please check $HOME/go/bin/seid version file \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
exit 13
fi


# Checkout the binary for 1.0.5beta
seidver=1.0.5beta
cd $HOME
rm -rf sei-chain
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain/
git fetch --tags -f
git checkout $seidver
# Build the new tool
make install
go build -o build/seid ./cmd/seid
# Checkout the binary for 1.0.xbeta
# if not right version exit script.
cd $HOME
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$seidver%20upgrade/bin

seidbuildver=$($HOME/go/bin/seid version)
if [ "$seidbuildver" == "$seidver" ]; then
    cp $HOME/go/bin/seid $DAEMON_HOME/cosmovisor/upgrades/$seidver%20upgrade/bin
else
    echo -e "\e[1m\e[31m5. Error version not match $seidver \e[0m"
    echo -e "\e[1m\e[31m5. please check $HOME/go/bin/seid version file \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
exit 13
fi

cd $HOME
sudo wget https://raw.githubusercontent.com/snipeTR/sei_help/main/sei_help.sh && chmod +x ./sei_help.sh &&sudo mv ./sei_help.sh /usr/local/bin/helpsei

yapılacaklar
/usr/local/bin/seid bir link dosyasi olacak ve cosmovisor un current ine baglanacak

cosmovisor run start --home ~/.sei

echo -e '\e[0m\e[31m=============== \e[0m\e[32mCommands that will make your job easier. Please note..\e[0m\e[31m===================\e[0m'
echo -e '\e[0m\e[36mcheck LOGS:\t\t\t\t \e[0m\e[32mjournalctl -ujournalctl -u seid -f -o cat\e[0m'
echo -e '\e[0m\e[36msend sei token to other address:\t \e[0m\e[32mseid tx bank send \033[33;4m<WalletName> <ToAddress> <amount>\e[0m\e[32m000000usei -y\e[0m'
echo -e '\e[0m\e[36mCheck BALANCE:\t\t\t\t \e[0m\e[32mseid query bank balances \033[33;4m<Address>\e[0m\e[32m -o│json | jq -r .balances[0].amount\e[0m'
echo -e '\e[0m\e[36mLearn MONIKER NAME:\t\t\t \e[0m\e[32mseid status 2>&1 | jq -r .NodeInfo.moniker\e[0m'
echo -e '\e[0m\e[36msync info command:\t\t\t \e[0m\e[32mseid status 2>&1 | jq .SyncInfo\e[0m'
echo -e '\e[0m\e[36mwallet list:\t\t\t\t \e[0m\e[32mseid keys list\e[0m'
echo -e '\e[0m\e[36mvalidator info command:\t\t\t \e[0m\e[32mseid status 2>&1 | jq .ValidatorInfo\e[0m'
echo -e '\e[0m\e[36mNode info command:\t\t\t \e[0m\e[32mseid status 2>&1 | jq .NodeInfo\e[0m'
echo -e '\e[0m\e[36mWallet import/recover from mnemonic:\t \e[0m\e[32mseid keys add \033[33;4m<wallet name>\e[0m\e[32m --recover\e[0m'
echo -e '\e[0m\e[36mseid binary path:\t\t\t \e[0m\e[32mtype seid\e[0m'
echo -e '\e[0m\e[36mmissed block count:\t\t\t \e[0m\e[32mseid q slashing signing-info $(seid tendermint show-validator) -o json | jq '"Missed: " + .missed_blocks_counter + " block"'\e[0m'


