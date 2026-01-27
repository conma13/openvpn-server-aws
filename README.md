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

## How to create


## How to use
1. Make changes in bootstrap.sh, install scripts, config files, add new files as needed
2. 1. (recommended) Update stack -> Change LaunchTemplate -> Bump version. ASG delete old instance and create the new one 
2. 2. Add fake parameter (UserDataVersion: 3). ASG delete old instance and create the new one
2. 3. Manually delete instance. ASG create new instance


## Scripts structure
Repository's root:
bootstrap.sh
install/
   01-system.sh
   02-packages.sh
   03-app.sh
config/
   app.conf
   env.sh
services/
   myapp.service


-----
## Manual

## 1. Prepare networking (VPC, subnets)

If you don’t have custom networking yet, use existing default resources:

**Find subnets**:
   - Go to **VPC → Subnets**  
   - Pick subnet in your default VPC.

---

## 2. Upload CloudFormation template to AWS

There are two options:

- **Console**:
  1. Go to **CloudFormation → Stacks → Create stack → With new resources (standard)**  
  2. Choose **Upload a template file**  
  3. Select your YAML file  
  4. Click **Next**.

- **CLI**:
  ```bash
  aws cloudformation create-stack \
    --stack-name my-dev-stack \
    --template-body file://template.yaml \
    --parameters \
      ParameterKey=InstanceType,ParameterValue=t3.micro \
      ParameterKey=AmiId,ParameterValue=ami-xxxxxxxx \
      ParameterKey=ScriptBucket,ParameterValue=my-scripts-bucket \
      ParameterKey=ScriptPath,ParameterValue=bootstrap.sh \
    --capabilities CAPABILITY_NAMED_IAM
  ```

---

## 3. Create the stack

1. In the **CloudFormation console**, after uploading the template:
   - Set parameters:
     - **InstanceType** (e.g. `t3.micro`)
     - **AmiId**
     - **ScriptsURL**
     - **BootStrapScript**
     - **Subnet** from the step 1
   - Click **Next** until **Review**  
   - Acknowledge IAM capabilities if needed  
   - Click **Create stack**.

2. Wait until the stack reaches **CREATE_COMPLETE**.

3. Go to **EC2 → Instances** and confirm:
   - One instance is running  
   - It uses your Launch Template.

---

## 4. Verify that bootstrap and scripts run correctly

1. Use **SSM Session Manager** (recommended):
   - Go to **EC2 → Instances → Select instance → Connect → Session Manager**  
   - Open a shell.

2. Check logs:
   ```bash
   cat /var/log/cloud-init-output.log
   cat /var/log/user-data.log
   ```
3. Verify that services/processes are running as expected.

---

## 5. Iterate on scripts (dev loop)

1. **Edit scripts in GitHub**:
   - Commit and push changes.
   - New instances will automatically pull the latest version on boot.

2. To force recreation of the instance:
   - **Option A (clean)**: update the stack with a changed parameter (e.g. `UserDataVersion=2`) so Launch Template changes → ASG replaces the instance.
   - **Option B (quick)**: terminate the instance manually; ASG will create a new one.

3. Reconnect, check logs, verify behavior.

---

## 6. When you change the CloudFormation template itself

Whenever you modify the template (e.g. new resources, changed Launch Template fields):

1. Run **Update stack** (console or CLI):
   ```bash
   aws cloudformation update-stack \
     --stack-name my-dev-stack \
     --template-body file://template.yaml \
     --parameters ... \
     --capabilities CAPABILITY_NAMED_IAM
   ```
2. Wait for **UPDATE_COMPLETE**  
3. Confirm that the ASG created a new instance if Launch Template changed.

