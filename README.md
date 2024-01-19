Certainly! Here's a basic README file that provides information on the installation process, uninstallation, and how to access the man pages:

```markdown
# ncping - Network Ping Utility

## Overview

`ncping` is a Bash script designed for periodic pinging of specified hosts. It also provides functionality to manage host groups, cron jobs, and configuration.

## Installation

### Prerequisites

- Bash (Bourne Again SHell)
- nano (a text editor) - used for configuring and viewing log files

### Steps

1. Clone the repository or download the script files.

```bash
git clone https://github.com/your_username/ncping.git
```

2. Navigate to the script directory.

```bash
cd ncping
```

3. Run the installation script.

```bash
sudo bash install.sh
```

This script installs `ncping` and its dependencies, sets up cron jobs, and creates necessary directories and files.

4. Verify the installation.

```bash
ncping -h
```

This should display the help message, indicating a successful installation.

## Uninstallation

1. Navigate to the script directory.

```bash
cd ncping
```

2. Run the uninstallation script.

```bash
sudo bash uninstall.sh
```

This script removes `ncping`, its cron jobs, and associated files.

## Usage

### Configuration

To configure the parameters, edit the configuration file:

```bash
ncping config
```

### View Log

To view the log file:

```bash
ncping log
```

### Manage Hosts

- Add a host:

```bash
ncping addhost <IP-ADDRESS>
```

- Delete a host:

```bash
ncping delhost <IP-ADDRESS>
```

- View saved hosts:

```bash
ncping -l
```

### Cron Jobs

- Create or update a cron job:

```bash
ncping ccron "*/5"
```

- Delete a cron job:

```bash
ncping delcron
```

### Man Pages

To view the man page:

```bash
man ncping
```

For the German man page:

```bash
man ncping_ger
```

## Author

Written by Samuel Lindenfelser.

## License

This script is open-source software licensed under the [MIT license](LICENSE).
```

Replace "your_username" in the clone command with your actual GitHub username or the appropriate URL for your repository. Additionally, replace "Your Name" in the author section with your name.
