# cosmos_sei_install
This application installs cosmovisor and seid validator nodes on a zero server.
There are various arrangements for reinstallation.

For detailed information about cosmovisor visit: https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor

What the script does are:
- to set the required environment variables and set the .bash_profile file.

- to set the required environment variables and set the .bash_profile file.
- Downloading the script named "sei_cosmovisor_update.sh" which makes it easy to install the new version "seid binary" update.
- package updates and updates to operating system packages.
- provides installation of various utilities/tools.
  - mc
  - bashtop
  - htop
  - git
  - jq
  - golang 1.18.2
- The sei daemon implementation of the sei-chain project. seid executable v1.0.6beta version. (seid_cosmovisor_update.sh for new version)
- It downloads genesis.json and addrbook.json files required for "sei-incentivized-testnet". (New chains need to be installed. You can change it from # download genesis and addrbook in this script.)
- sets the minimum gas limit to 10usei.
- Activates the prometeus validator monitoring system.
- It creates the seid service but does not activate it. No service is needed when running under cosmovisor.
- From the main distribution in cosmos-sdk, it downloads and builds the application called cosmovisor and installs it.
- Integrates the seid application into the cosmovisor application.
- various useful commands are created.
 - **helpsei** Various useful commands for seid.
 - **seiport** List of ports used by seid. (during installation)
 - **helpseiupdate** for updating helpsei code.
- It creates 2 scripts required to start as cosmovisor or service.
  - **seid_start_with_cosmovisor.sh** servis olarak çalışıyorsa servisi kapatır ve cosmovisor sürümünün çalışmasını sağlar.
  - **seid_start_with_service.sh** cosmovisor olarak çalışan uygulamayı kapatır ve servis olarak çalışmasını sağlar.
- It provides an option to create a wallet at the end of the installation.
- Various checks for incorrect user login, written and colored help texts and warnings about points to be considered.
