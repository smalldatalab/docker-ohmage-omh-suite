# System Admin FAQ
### How do I configure the Docker containers to automatically start on system reboot?
Docker provides a feature called `restart policies` for individual containers, so that containers can be automatically started when the docker daemon start (daemon starts by default on system boot). More information on this setting can be found [here](https://docs.docker.com/engine/reference/run/#restart-policies-restart).  To set ohmage containers to restart, you can add the flag `restart: always` to each component in the docker-compose.yml file.  For example;

```
ohmage-statics:
    restart: always
    image: smalldatalab/ohmage-statics:latest
    volumes: 
        - /var/www/ohmage-statics
ohmage-auth:
    restart: always
    image: smalldatalab/ohmage-auth-server:latest

    ...
```

### How to I add an SSL certificate for HTTPS?
Coming soon


