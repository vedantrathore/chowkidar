# Chowkidar 
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/Naereen/StrapDown.js/blob/master/LICENSE)
[![Open Source Love svg1](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

---

A tool to monitor all the ssh activity in your datacenters. 

## Architecture

Chowkidar consists of two components:

- **Agent**: This is deployed on your servers you want to monitor. Runs as a docker daemon container. It's made in python and uses celery and redis to ensure minimal data loss asynchronously. 

- **Server**: A central processing unit which aggergates data from all servers and displays in a grafana dashboard. It's a node based webhook which parses the data and inserts it into a time-serires database (Influx DB) which is used by grafana to render the dashboards


## Deployment

### Server:

* Clone this repository
* Configure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env variables with Administrator privileges
* Create AWS SSM secrets for (refer to `.env.sample`): 
  - INFLUXDB_USERNAME 
  - INFLUXDB_PASSWORD
  - GRAFANA_USERNAME
  - GRAFANA_PASSWORD

  use the following command to create the secrets:
  ```
  $ aws ssm put-parameter \
  --name "/chowkidar/influx/influxdb_username" \
  --value "chowkidar" \
  --type "SecureString" \

  $ aws ssm put-parameter \
  --name "/chowkidar/influx/influxdb_password" \
  --value "chowkidar" \
  --type "SecureString" \

  $ aws ssm put-parameter \
    --name "/chowkidar/influx/grafana_username" \
    --value "chowkidar" \
    --type "SecureString" \

  $ aws ssm put-parameter \
    --name "/chowkidar/influx/grafana_password" \
    --value "chowkidar" \
    --type "SecureString" \

  $ aws ssm put-parameter \
    --name "/chowkidar/influx/ipstack_access_key" \
    --value "YOUR_IPSTACK_ACCESS_KEY" \
    --type "SecureString" \
  ```
* Setup and configure terraform v12.28
* From the `./deployment/server` directory run:
  * `$ terraform init`
  * Refer to `./deployment/server/testing.tfvars` for variable configuration
  * `$ terraform plan`
  * Validate the plan and make sure everything is cool
  * `$ terraform apply`
   
* This will output a DNS of the public load balancer, configure it with your domain registrar. 

