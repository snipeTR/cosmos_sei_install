#!/bin/bash

cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}
echo tnx for \e[1m\e[32mkj89\e[0m
echo -e "\e[1m\e[32m0. cosmovisor is detected.... \e[0m" && sleep 1
DIR="$HOME/.stchaind/cosmovisor"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  clear
  echo -e "--------- \e[1m\e[32mCurrent Folder Structure\e[0m -----------"
  tree ~/.stchaind/cosmovisor
  echo "----------------------------------------------"
  sleep 3
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "COSMOVISOR application has not been installed on this server before."
  echo "You cannot install stratos-CHAIN with this script."
  echo "Please run 'stratos_cosmovisor_install.sh'."
  echo -e "\e[1m\e[32mNote:\e[0m Since stratos-chain is completely deleted, or you must install on a server that has not been installed before, with the stratos_cosmovisor_install.sh file."
  exit 13
fi

#enter arg or stratosd version
if [ ! $1 ]; then
	 echo -e "Enter the version you want to add to cosmovisor.(for example me:\e[1m\e[32m1.0.7beta\e[0m or \e[1m\e[32m1.0.6beta-val-count-fix\e[0m)"
   read -p "please make sure you ENTER the correct version number..: " stratosDVER
fi

cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}

source $HOME/.bash_profile

echo -e '\e[1m\e[35mm=================================================\e[0m'

echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
	if [ ! "$(echo $NODENAME | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mNode name not defined\e[0m---NODENAME\n"; fi
	
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
	if [ ! "$(echo $WALLET | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mNode name not defined\e[0m---WALLET\n"; fi
	
echo -e "Your chain name: \e[1m\e[32m$stratos_CHAIN_ID\e[0m"
	if [ ! "$(echo $stratos_CHAIN_ID | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---stratos_CHAIN_ID\n"; fi
	
echo -e "Your port: \e[1m\e[32m$stratos_PORT\e[0m"
	if [ ! "$(echo $stratos_PORT | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---stratos_PORT\n"; fi
	
echo " "

echo -e "UNSAFE_SKIP_BACKUP: \e[1m\e[32m$UNSAFE_SKIP_BACKUP\e[0m"
	if [ ! "$(echo $UNSAFE_SKIP_BACKUP | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---UNSAFE_SKIP_BACKUP\n"; fi
	
echo -e "DAEMON_HOME: \e[1m\e[32m$DAEMON_HOME\e[0m"
	if [ ! "$(echo $DAEMON_HOME | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---DAEMON_HOME\n"; fi
	
echo -e "DAEMON_NAME: \e[1m\e[32m$DAEMON_NAME\e[0m"
	if [ ! "$(echo $DAEMON_NAME | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---DAEMON_NAME\n"; fi
	
echo -e "DAEMON_RESTART_AFTER_UPGRADE: \e[1m\e[32m$DAEMON_RESTART_AFTER_UPGRADE\e[0m"
	if [ ! "$(echo $DAEMON_RESTART_AFTER_UPGRADE | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---DAEMON_RESTART_AFTER_UPGRADE\n"; fi
	
echo -e "DAEMON_DATA_BACKUP_DIR: \e[1m\e[32m$DAEMON_DATA_BACKUP_DIR\e[0m"
	if [ ! "$(echo $DAEMON_DATA_BACKUP_DIR | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---DAEMON_DATA_BACKUP_DIR\n"; fi
		
echo '================================================='

   echo -e "\e[1m\e[35mPlease check the accuracy of the information \e[1m\e[36mCAREFULLY.\e[0m"
   echo -e "\e[1m\e[31mAre the above ALL values correct? [Y/N]\e[0m"
   read -rsn1 answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
      echo Yes
    else
      echo No
      sleep 3
    exit 13
    fi

# update
echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y

#remove old stratos-chain directory
DIR="stratos-chain"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo -e "\e[1m\e[32m2. remove old stratos-chain directory... \e[0m" && sleep 1
  sudo rm -rf stratos-chain
fi

#clone stratos-chain
echo -e "\e[1m\e[32m3. Download, fetch and checkout ... \e[0m" && sleep 1
git clone --depth 1 https://github.com/stratosnet/stratos-chain.git
cd stratosi-chain/
git fetch --tags -f
git checkout $stratosDVER

# Build the new version
echo -e "\e[1m\e[32m4. Building executing binary file ... \e[0m" && sleep 1
make install
go build -o build/stchaind ./cmd/stchaind
cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}
	
# executable files are copied to the required folders.
echo -e "\e[1m\e[32m5. Copying the stchaind executable to the required folder ... \e[0m" && sleep 1

# if exist same directory delete it.
if [ -d "$DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin" ]; then
    rm -rf $DAEMON_HOME/cosmovisor/upgrades/$stratosDVER
fi

mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin
cp $HOME/go/bin/stchaind $DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin

# check right stchaind version number on upgrades directory.
if [ ! -f "$DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin/stchaind" ]; then
    echo -e "$DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin/stchaind \e[1m\e[31mFILE NOT EXIST\e[0m"
    echo -e "\e[1m\e[31m Upgrade fail \e[0m"
    echo -e "\e[1m\e[31m ERROR ERROR ERROR ERROR \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
    exit 13
else
		local stratosBUILDVER=$($DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin/stchaind version)
		if [ "$stratosBUILDVER" == "$stratosDVER" ]; then
			echo $DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin/stchaind version $stratosDVER
			echo -e "The stchaind binary with version number \e[1m\e[31m$stratosDVER\e[0m has been copied to the required folder."
			
			pkill --signal 2 cosmovisor
			
			if [ ! bkup_cosmovisor_stratos ]; then mkdir ~/bkup_cosmovisor_stratos ;fi 
			if [ ! stchaind_start_with_cosmovisor.sh ]; then rm -rf stchaind_start_with_cosmovisor.sh; fi 
			
      echo ulimit -n 1000000 >stchaind_start_with_cosmovisor.sh
      echo UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.stchaind DAEMON_NAME=stchaind DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stratos cosmovisor run start init ~/.stchaind>>stchaind_start_with_cosmovisor.sh
      chmod +x stchaind_start_with_cosmovisor.sh
		else
    	echo -e "\e[1m\e[31m Error version not match $stratosDVER \e[0m"
    	echo "stratosDVER=$stratosDVER***stratosBUILDVER=$stratosBUILDVER"
    	echo -e "\e[1m\e[31m please check \e[1m\e[31m$DAEMON_HOME/cosmovisor/upgrades/$stratosDVER/bin\e[1m\e[31m version file \e[0m"
    	read -s -n 1 -p "Press any key to EXIT . . ."
			exit 13
		fi
fi
