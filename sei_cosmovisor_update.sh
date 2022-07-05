#!/bin/bash
if [ ! $1 ]; then
   read -p "Enter the version you want to add to cosmovisor.(for example me:1.0.6beta)" SEIDVER
else
   echo "Is $1 the version you want to install? [Y/N]"
   read answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      echo Yes
      SEIDVER=$1
    else
      echo No
      sleep 3
    exit 13
    fi
fi

if [ ! $NODENAME ]; then
        read -p "Node name: " NODENAME
        echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export CHAIN_ID=sei-testnet-2" >> $HOME/.bash_profile
echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> $HOME/.bash_profile
echo "export DAEMON_NAME=seid" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$HOME/.sei" >> $HOME/.bash_profile
if [ ! $SEIDVER ]; then
echo "export SEIDVER=1.0.2beta" >> $HOME/.bash_profile
fi
if [ ! $VISORVER ]; then
echo "export VISORVER=v1.1.0" >> $HOME/.bash_profile
fi
source $HOME/.bash_profile

echo '==============VARIABLE  CONTROL=================='
echo NODENAME:$NODENAME
echo WALLET:$WALLET
echo CHAIN_ID:$CHAIN_ID
echo DAEMON_RESTART_AFTER_UPGRADE:$DAEMON_RESTART_AFTER_UPGRADE
echo DAEMON_NAME:$DAEMON_NAME
echo DAEMON_HOME:$DAEMON_HOME
echo SEIDVER:$SEIDVER
echo VISORVER:$VISORVER
echo '================================================='
echo "."
   echo "\e[1m\e[35mPlease check the accuracy of the information \e[1m\e[36mCAREFULLY.\e[0m"
   echo "\e[1m\e[31mAre the above values correct? [Y/N]\e[0m"
   sleep 2
   read answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      echo Yes
    else
      echo No
      sleep 3
    exit 13
    fi

# update
sudo apt update && sudo apt upgrade -y

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
#└── upgrades
#    └── 1.0.6beta%20upgrade
#        ├── bin
#        │   └── seid
#        └── upgrade-info.json

# Checkout the binary for 1.0.5beta
#SEIDVER=1.0.6beta
cd $HOME
#remove old sei-chain directory
rm -rf sei-chain
#clone sei-chain
git clone --depth 1 https://github.com/sei-protocol/sei-chain.git
cd sei-chain/
git fetch --tags -f
git checkout $SEIDVER
# Build the new version
make install
go build -o build/seid ./cmd/seid
# Checkout the binary for 1.0.xbeta
# if not right version exit script.
cd $HOME
#create cosmovisor upgrade directory
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin
#copy new seid version correct upgrade cosmovisor directory
cp $HOME/go/bin/seid $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin
if [ ! -f "$DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin/seid" ]; then
    echo "$DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin/seid FILE NOT EXIST"
    read -s -n 1 -p "Press any key to EXIT . . ."
    exit 13
else
		SEIDBUILDVER=$($DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin/seid version)
		if [ "$SEIDBUILDVER" == "$SEIDVER" ]; then
			echo $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin/seid version $SEIDVER
		else
    	echo -e "\e[1m\e[31m2. Error version not match $SEIDVER \e[0m"
    	echo -e "\e[1m\e[31m2. please check $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrades/bin version file \e[0m"
    	read -s -n 1 -p "Press any key to EXIT . . ."
			exit 13
		fi
fi
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER/bin
cp $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER%20upgrade/bin/seid $DAEMON_HOME/cosmovisor/upgrades/$SEIDVER/bin

#stop cosmovisor
kill $(pidof cosmovisor)

#remove execute file from local/bin
rm -rf /usr/local/bin/seid

#add solid link current seid execute to local/bin
ln -s $HOME/.sei/cosmovisor/current/bin/seid /usr/local/bin/seid

mkdir ~/bkup_cosmovisor_sei
UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.sei DAEMON_NAME=seid DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_sei cosmovisor run start --home ~/.sei

