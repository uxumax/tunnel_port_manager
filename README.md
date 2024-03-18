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

## Start Daemon on Server with Public IP

1. Clone the repository to your server with a public IP address.
2. Ensure the script `tunnel_port_manager.sh` is executable: `chmod +x tunnel_port_manager.sh`.
3. Create a FIFO file for port requests: `mkfifo /path/to/ports_to_open.fifo`.
4. Configure the `tunnel_port_manager.service` file and copy it to `/etc/systemd/system/`.
5. Reload `systemd` configurations: `sudo systemctl daemon-reload`.
6. Start the service: `sudo systemctl start tunnel_port_manager`.
7. Enable the service to start on boot: `sudo systemctl enable tunnel_port_manager`.

## SSH Connection Setup with Dynamic Port Opening

To facilitate a secure and dynamic SSH connection that requires opening a port on the fly on your server with a public IP, you can integrate the Tunnel Port Manager with your SSH setup. This approach allows you to open ports dynamically before initiating an SSH connection to your target server behind the public IP server.

Follow these steps to configure your SSH client to open a port dynamically before connecting:

1. **Local Script Creation**: Create a local script, `open_port_and_ssh.sh`, that sends a command to open a port on the public IP server before establishing an SSH connection to your target server.

    Here's an example of what the script could look like:

    ```bash
    #!/bin/bash

    # The port you want to open on the public IP server
    PORT=your_port_here

    # Command to open the port
    echo $PORT > /path/to/ports_to_open.fifo

    # Wait a bit to ensure the port is open
    sleep 2

    # Proceed with your SSH connection command here
    # You have time for connecting until port will be closed
    # After port close you session won't be interrupt
    
    # Example: ssh user@target-server
    ```

    Replace `your_port_here` with the actual port number you wish to open and `/path/to/ports_to_open.fifo` with the actual path to your FIFO file used by the Tunnel Port Manager. Adjust the `ssh` command at the end of the script to match your connection details.

2. **Making the Script Executable**: Change the script's permissions to make it executable.

    ```bash
    chmod +x open_port_and_ssh.sh
    ```

3. **SSH Configuration**: You can now use this script manually whenever you need to establish an SSH connection that requires opening a port dynamically. If you are frequently connecting to the same server, consider adding an alias in your shell configuration file (e.g., `.bashrc` or `.zshrc`) to simplify the process.

    ```bash
    alias ssh_with_port_open='/path/to/open_port_and_ssh.sh'
    ```

This setup allows you to dynamically open ports on your public IP server immediately before initiating an SSH connection, enhancing security by ensuring that ports are not left open unnecessarily.

## Integrating Port Opening into SSH Configuration

For a seamless experience that automates the port opening process when initiating an SSH connection, you can incorporate the Tunnel Port Manager directly into your SSH configuration. This method utilizes ProxyCommand to execute a command that opens the necessary port right before the SSH connection is established.

To configure this, you'll need to add a specific host entry in your ~/.ssh/config file. Here's how you can set it up:

1. **SSH Config Modification**: Edit your ~/.ssh/config file and add new host entries for your target server and any virtual machines (VMs) that require dynamic port opening through a reverse tunnel. Replace the placeholders with your actual server details and port numbers.

    ```ssh
    Host vps_with_public_ip
    Hostname 77.77.77.77
    User user
    
    Host vm_over_nat
    Hostname 77.77.77.77
    User user
    # Port of the tunnel from VM over NAT
    Port 2201
    # Open port command using ProxyCommand
    ProxyCommand ssh vps_with_public_ip "echo %p > /path/to/ports_to_open.fifo;exec nc %h %p"
    ```

    In this configuration:
    - `Hostname` should be replaced with the IP address of your server that has a public IP address.
    - `User` is the username for SSH login on the target server or VM.
    - `Port 2201` specifies the port on which the reverse tunnel is listening. This needs to be replaced with the actual port number used by your setup.
    - The `ProxyCommand` is used to open the necessary port on the server before initiating the SSH connection. The command:
      - `ssh bitvps` initiates an SSH connection to the intermediary server (in this example, `bitvps`). Replace `bitvps` with your server's hostname or alias.
      - `"echo %p > ~/.ports_to_open.fifo;exec nc %h %p"`: This command does two things:
        1. `echo %p > ~/.ports_to_open.fifo` writes the port number (`%p`, dynamically replaced by SSH with the port specified in the SSH command) to a FIFO file. This action triggers the Tunnel Port Manager on the server to open the specified port.
        2. `exec nc %h %p` uses `netcat` (`nc`) to establish the actual SSH connection to the host (`%h`) and port (`%p`) after the port has been opened. `%h` and `%p` are placeholders that `ssh` replaces with the host and port specified in the SSH command. This ensures the port is open just before the connection, facilitating the seamless use of reverse tunnels.

2. **Usage**: Now, when you SSH to your target server using the alias defined in the SSH config, the specified port will be automatically opened just before the connection is established. This setup minimizes manual steps and streamlines the connection process.

    Simply use the SSH command as usual:

    ```bash
    ssh vm_over_nat
    ```

This approach ensures that your dynamic port opening process is neatly integrated into your SSH workflow, offering a more automated and hassle-free experience.

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
