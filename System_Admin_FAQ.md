# System Admin FAQ
### Can I configure the Docker containers to start on reboot?
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

---
<br>

### Can I use SSL for HTTPS?
Yes, we provide a basic nginx setup for using HTTPS and redirecting all HTTP requests to HTTPS. If this meets your needs, you will only need to slightly modify your `docker-compose.yml` file, and put the .crt and .key certificate files in that same directory on the host machine. If you need a custom nginx configuration, you can simply build your own Docker image for nginx, and use that instead of the `smalldatalab/ohmage-nginx` one. A reference for that nginx.conf and Dockerfile can be found [here](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/ohmage-nginx).

To use the default SSL configuration we provide, you need to:

1. Copy your .crt and .key files to the host machine in the same directory as `docker-compose.yml` file, AND rename them to `ohmage-omh-instance.crt` and `ohmage-omh-instance.key`, respectively.  This naming is important, because the nginx container will look for those specific file names.
1. Update your `docker-compose.yml` file to use the pre-built ssl version of the nginx Docker image, and add port 443. For example,

```
...
ohmage-nginx
	restart: unless-stopped
    image: smalldatalab/ohmage-nginx-ssl:latest     # <-- Change the image it builds from
    links:
        - ohmage-auth:ohmage-auth
        - ohmage-resource:ohmage-resource
        - ohmage-admin:ohmage-admin
        - ohmage-shim:ohmage-shim
        - ohmage-dpu:ohmage-dpu
    ports:
        - "80:80"
        - "443:443"      # <-- Add port 443
    volumes:
        - /var/log/ohmage/nginx:/var/log/nginx
    volumes_from:
        - ohmage-statics
```

That should be it, and you can start up again with `docker-compose up -d`.
  
---
<br>