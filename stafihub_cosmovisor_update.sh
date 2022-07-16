#!/bin/bash

cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}
echo tnx for \e[1m\e[32mkj89\e[0m
echo -e "\e[1m\e[32m0. cosmovisor is detected.... \e[0m" && sleep 1
DIR="$HOME/.stafihub/cosmovisor"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  clear
  echo -e "--------- \e[1m\e[32mCurrent Folder Structure\e[0m -----------"
  tree ~/.stafihub/cosmovisor
  echo "----------------------------------------------"
  sleep 3
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "COSMOVISOR application has not been installed on this server before."
  echo "You cannot install STAFIHUN with this script."
  echo "Please run 'stafihub_cosmovisor_install.sh'."
  echo -e "\e[1m\e[32mNote:\e[0m Since stafihub is completely deleted, or you must install on a server that has not been installed before, with the stafihub_cosmovisor_install.sh file."
  exit 13
fi

#enter arg or stafihubd version
if [ ! $1 ]; then
	 echo -e "Enter the version you want to add to cosmovisor.(for example me:\e[1m\e[32mpublic-testnet-v4\e[0m)"
   read -p "please make sure you enter the correct version number. " stafihubDVER
else
   stafihubDVER=$1
fi

echo "Is $stafihubDVER the version you want to install? [Y/N]"
read -rsn1 answer
   if [ "$answer" != "${answer#[Yy]}" ] ;then
     echo Yes
     stafihubDVER=$1
   else
   echo your answer no, exiting script.
     sleep 3
   exit 13
   fi

cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}

source $HOME/.bash_profile

echo -e '\e[1m\e[35mm=================================================\e[0m'

echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
	if [ ! "$(echo $NODENAME | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mNode name not defined\e[0m---NODENAME\n"; fi
	
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
	if [ ! "$(echo $WALLET | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mNode name not defined\e[0m---WALLET\n"; fi
	
echo -e "Your chain name: \e[1m\e[32m$stafihub_CHAIN_ID\e[0m"
	if [ ! "$(echo $stafihub_CHAIN_ID | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---stafihub_CHAIN_ID\n"; fi
	
echo -e "Your port: \e[1m\e[32m$stafihub_PORT\e[0m"
	if [ ! "$(echo $stafihub_PORT | wc -m)" -gt "1"  ]; then echo -e "\e[1m\e[31mnot defined\e[0m---stafihub_PORT\n"; fi
	
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

   echo "\e[1m\e[35mPlease check the accuracy of the information \e[1m\e[36mCAREFULLY.\e[0m"
   echo "\e[1m\e[31mAre the above ALL values correct? [Y/N]\e[0m"
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

#remove old sei-chain directory
DIR="sei-chain"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo -e "\e[1m\e[32m2. remove old sei-chain directory... \e[0m" && sleep 1
  sudo rm -rf sei-chain
fi

#clone sei-chain
echo -e "\e[1m\e[32m3. Download, fetch and checkout ... \e[0m" && sleep 1
git clone --depth 1 https://github.com/stafihub/stafihub.git
cd stafihub/
git fetch --tags -f
git checkout $stafihubDVER

# Build the new version
echo -e "\e[1m\e[32m4. Building executing binary file ... \e[0m" && sleep 1
make install
go build -o build/stafihubd ./cmd/stafihubd
cd $HOME || { echo "$HOME Unable to enter directory"; sleep 1; exit 13;}
	
# executable files are copied to the required folders.
echo -e "\e[1m\e[32m5. Copying the stafihubd executable to the required folder ... \e[0m" && sleep 1
mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin
cp $HOME/go/bin/stafihubd $DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin

# check right stafihubd version number on upgrades directory.
if [ ! -f "$DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin/stafihubd" ]; then
    echo -e "$DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin/stafihubd \e[1m\e[31mFILE NOT EXIST\e[0m"
    echo -e "\e[1m\e[31m Upgrade fail \e[0m"
    echo -e "\e[1m\e[31m ERROR ERROR ERROR ERROR \e[0m"
    read -s -n 1 -p "Press any key to EXIT . . ."
    exit 13
else
		local stafihubDBUILDVER=$($DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin/stafihubd version)
		if [ "$stafihubDBUILDVER" == "$stafihubDVER" ]; then
			echo $DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin/stafihubd version $stafihubDVER
			echo -e "The stafihubd binary with version number \e[1m\e[31m$stafihubDVER\e[0m has been copied to the required folder."
			
			pkill --signal 2 cosmovisor
			
			if [ ! bkup_cosmovisor_stafihub ]; then mkdir ~/bkup_cosmovisor_stafihub ;fi 
			if [ ! stafihubd_start_with_cosmovisor.sh ]; then rm -rf stafihubd_start_with_cosmovisor.sh; fi 
			
      echo ulimit -n 1000000 >stafihubd_start_with_cosmovisor.sh
      echo UNSAFE_SKIP_BACKUP=true DAEMON_HOME=~/.stafihub DAEMON_NAME=stafihubd DAEMON_RESTART_AFTER_UPGRADE=true DAEMON_DATA_BACKUP_DIR=~/bkup_cosmovisor_stafihub cosmovisor run start init ~/.stafihub>>stafihubd_start_with_cosmovisor.sh
      chmod +x stafihubd_start_with_cosmovisor.sh
		else
    	echo -e "\e[1m\e[31m Error version not match $stafihubDVER \e[0m"
    	echo -e "\e[1m\e[31m please check \e[1m\e[31m$DAEMON_HOME/cosmovisor/upgrades/$stafihubDVER/bin\e[1m\e[31m version file \e[0m"
    	read -s -n 1 -p "Press any key to EXIT . . ."
			exit 13
		fi
fi
