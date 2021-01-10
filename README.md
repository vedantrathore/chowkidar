# Chowkidar 
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

---

A tool to monitor your all the ssh activity in your datacenters. 

### Architecture

Chowkidar consists of two units:

- Agent: This is to be deployed on your servers. Runs as a docker daemon container. 

- Server: A central unit which aggergates data from all servers and displays in a grafana dashboard. 

