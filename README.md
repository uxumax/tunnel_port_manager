# Tunnel Port Manager

## Overview

In certain scenarios, such as government-imposed internet restrictions or unstable network connections, solutions like ZeroTier, Nebula, and others may not work as reliably as desired. In these cases, traditional reverse SSH tunnels come to the rescue. However, this approach introduces a challenge when multiple ports need to be opened on a single public IP address, creating numerous potential attack vectors.

## Problem Statement

The primary issue arises from the need to open multiple ports on a public IP to facilitate reverse SSH tunnels, significantly increasing the surface area for potential attacks. Keeping all these ports open at all times is neither necessary nor secure.

## Solution

The Tunnel Port Manager addresses this issue by allowing ports to be dynamically opened on an as-needed basis. Before establishing a connection to a remote machine via a reverse SSH tunnel, a signal is sent to the machine with the public IP address, instructing it to open the required port. This process ensures that only the necessary ports are open at any given time, reducing potential attack vectors.

## Features

- Dynamically open ports on a public IP address based on requests from remote machines.
- Automatically close ports after a predefined timeout, enhancing security.
- Utilize `iptables` for port management and `cron` for scheduling port closure tasks.
- Easy to deploy and manage as a `systemd` service for reliability and convenience.

## Usage

1. Clone the repository to your server with a public IP address.
2. Ensure the script `tunnel_port_manager.sh` is executable: `chmod +x tunnel_port_manager.sh`.
3. Create a FIFO file for port requests: `mkfifo /path/to/ports_to_open.fifo`.
4. Configure the `tunnel_port_manager.service` file and copy it to `/etc/systemd/system/`.
5. Reload `systemd` configurations: `sudo systemctl daemon-reload`.
6. Start the service: `sudo systemctl start tunnel_port_manager`.
7. Enable the service to start on boot: `sudo systemctl enable tunnel_port_manager`.

## System Requirements

- A Linux server with a public IP address.
- `iptables` and `cron` installed.
- `systemd` for managing the service.

## Security Considerations

- Ensure proper permissions are set for the FIFO file to prevent unauthorized access.
- Regularly review `iptables` rules and `cron` jobs for any anomalies.
- Consider implementing additional firewall rules or using a dedicated firewall appliance for enhanced security.

## Contributing

Contributions to the Tunnel Port Manager are welcome! Please submit pull requests or open issues to suggest improvements or report bugs.

## License

[MIT License](LICENSE)

## Acknowledgments

Special thanks to all contributors and users for supporting the development of this project.
