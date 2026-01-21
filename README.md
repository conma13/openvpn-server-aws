# openvpn-server-aws
Run OpenVPN server + stunnel on AWS

## TODO List
- [x] Move here notes from OneNote
- [ ] Move the project for CloudFormation
- [ ] Use GitHub as persistent storage
- [ ] Split the project into modules
- [ ] Tasks
   - [ ] Virtual machine based on a standard Debian image
   - [ ] Access to the VM only via SSH 
      - [ ] Non standard port (parameter or random?)
      - [ ] ED25519 key authentication (how to generate and where to store keys?)
      - [ ] No username-password access
   - [ ] VM settings
      - [ ] No root login; use sudo for administrative tasks
      - [ ] Firewall configured to block all ports except those in use (ufw?)
      - [ ] Install Docker to run OpenVPN/stunnel in a container
   - [ ] OpenVPN settings
      - [ ] Use TLS certificates with passwords
      - [ ] Route all traffic through stunnel