# NCPing - Network Control Script

## Installation

### Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/samuli100/Network-Control.git

    Navigate to the ncping directory:

    bash

cd ncping

Run the installation script:

bash

./install_ncping.sh

This script will copy the necessary files to system directories, create cron jobs, and set up the environment.

Verify the installation:

bash

    ncping -h

    This command should display the help message for the ncping script.

Usage
Basic Commands

    Ping Hosts:

    bash

ncping

Pings the hosts specified in the configuration file and logs unreachable hosts.

Add Host:

bash

ncping addhost IP_ADDRESS

Adds an IP address to the list of hosts.

Delete Host:

bash

ncping delhost IP_ADDRESS

Removes an IP address from the list of hosts.

List Hosts:

bash

    ncping lshosts

    Lists all IP addresses (hosts) currently configured.

Advanced Commands

    Create Group:

    bash

ncping creategroup GROUP_NAME

Creates a group with the specified name.

Delete Group:

bash

ncping delgroup GROUP_NAME

Deletes the group with the specified name.

Add Host to Group:

bash

ncping addgroup GROUP_NAME IP_ADDRESS

Adds a certain IP address to the named group.

Remove Host from Group:

bash

ncping rmgroup GROUP_NAME IP_ADDRESS

Removes a certain IP address from the named group.

Create Cron Job:

bash

ncping ccron GROUP_NAME CRON_SCHEDULE

Creates a cron job for a named group with the specified cron schedule.

Delete Cron Job:

bash

    ncping delcron GROUP_NAME

    Deletes the cron job for a named group.

Configuration

    Edit Configuration:

    bash

    ncping config

    Opens the configuration file for editing. Modify settings such as the number of packets, timeout, and interval.

Uninstallation

To uninstall ncping, run the uninstallation script:

bash

./uninstall_ncping.sh

This script removes the installed files, cron jobs, and associated configurations.
