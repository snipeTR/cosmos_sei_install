#build command
cd sei-chain
git checkout master && git pull
git checkout 1.0.6beta-val-count-fix
make install

#if cosmovisor on
rm $HOME/.sei/cosmovisor/genesis/bin/seid
sudo cp $HOME/go/bin/seid $HOME/.sei/cosmovisor/genesis/bin/seid
DAEMON_HOME=$HOME/.sei DAEMON_NAME=seid DAEMON_RESTART_AFTER_UPGRADE=true $HOME/cosmos-sdk/cosmovisor/cosmovisor run start& > /dev/null 2>&1
sudo kill "$(pidof cosmovisor)"
rm /usr/local/bin/seid
sudo ln -s $HOME/.sei/cosmovisor/current/bin/seid /usr/local/bin/seid

#if normal install
sudo rm /usr/local/bin/seid
sudo cp $HOME/go/bin/seid /usr/local/bin/seid
