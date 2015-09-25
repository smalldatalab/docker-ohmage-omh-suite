# Ohmage OMH Suite

This repository contains instructions and config files for deploying the Ohmage OMH suite of servers and tools.  For more information about Ohmage OMH, view the [main website here](http://ohmage-omh.smalldata.io/)

To run your own instance of the Ohmage suite on a physical or virtual machine, we provide a simplified deployment configuration that uses [Docker containers](https://www.docker.com/whatisdocker).  We chose Docker because the Ohmage suite includes several interdependent servers, and Docker provides an easy way to deploy and interface those components without requiring knowledge of the underlying technologies used to build them.

Below is a list of all the components that you can install in the suite, along with links to the source code or website.

- [MongoDB](https://www.mongodb.org/)
- [PostgreSQL](http://www.postgresql.org/)
- [Ohmage Authorization Server](https://github.com/smalldatalab/omh-dsu) 
- [Ohmage Resource Server](https://github.com/smalldatalab/omh-dsu)
- [Ohmage Shim Server](https://github.com/smalldatalab/omh-shims)
- [Ohmage Admin Dashboard](https://github.com/smalldatalab/omh-admin-dashboard)
- [Ohmage Data Processing Server](https://github.com/smalldatalab/mobility-dpu)

At a high level, the setup process will be:

1. Create "client" accounts with 3rd party services that you'll use (e.g. Google, Fitbit, Moves)
1. Edit the `docker-compose` file for your environment 
1. Setup your machine and install Docker.
1. Transfer the `docker-compose` file to the machine and run it
1. Initialize the databases, and restart


## Step 1: Create client accounts with 3rd party services

```
NOTE: It is possible to setup and run the Ohmage suite without creating any of the 3rd party accounts listed below, and you can always come back later and add integration with these services. If you want to run Ohmage without these 3rd party services, skip to Step 2.
```

### 3rd Party - Google Client ID

Currently, the Ohmage suite allows users to login using their Google account.  To enable this, you will register your instance of the suite with Google, so they can provide the authorization between the user and your system.  When you have done this, Google will assign your system a 'clientId' and 'clientSecret' which you will use for credentials.

To start you will need to have a project on the Google APIs Console (you can create a new one or add to an existing one).  You can find more information about that [here](https://developers.google.com/console/help/)  To add a Client ID within the project, navigate to the project console, and on the left-hand menu select APIs & auth > Credentials.  Select "Create a new Client ID".  Enter the information and create the ID.  NOTE: You must have a domain name for your server, because Google APIs does not accept raw IP addresses as redirects.

Record your `clientId` and `clientSecret` for later.   


### 3rd Party - Fitbit API

If you wish to use Fitbit data, you will need to create a developer account with them and register your instance of the suite to get a 'clientId' and 'clientSecret'.  If you do not wish to use Fitbit data, you can skip this, and additionally exclude those parameters when starting the shim Docker container, below.  (i.e. remove '-e openmhealth.shim.fitbit.clientId=...' and '-e openmhealth.shim.fitbit.clientSecret=...' when starting the container).

To get started, go [here](https://dev.fitbit.com) and create a developer account.  Once you logged into the developer account, select "Register an App", which takes you [here](https://dev.fitbit.com/apps/new).  Enter the information for your instance of the suite.  Use the following settings:

```
Application Type = Browser
Callback URL = {YOUR BASE DOMAIN URL}/shim/fitbit
Default Access Type = Read-Only
```

Once created, record the `Client (Consumer) Key` and `Client (Consumer) Secret` for later.  NOTE: the 'clientId' that we'll use below is actually what Fitbit shows as the 'Client Key', not what they label as the 'OAuth 2.0 Client ID'.

## Step 2: Edit the 'docker-compose' file
The main template for the `docker-compose` file is in this repository in the /omh directory, [here]()

## Step 3: Setup the machine

Our testing was done on an AWS instance, with their Ubuntu 14.04.2 distro. However, the suite should run fine on any OS that is supported by Docker and nginx.


## Install Docker

Once your machine is setup, you can find instructions to install Docker for your OS [here](https://docs.docker.com/installation/).

If you are using Ubuntu, the instructions are [here](https://docs.docker.com/installation/ubuntulinux/).

## Pull all the Docker images

All the images you will need are hosted on the Docker Hub.  To pull those images to your local machine, run each of the following:

```
sudo docker pull mongo:latest
sudo docker pull postgres:latest
sudo docker pull smalldatalab/ohmage-auth-server:latest
sudo docker pull smalldatalab/ohmage-resource-server:latest
sudo docker pull smalldatalab/ohmage-admin-server:latest
sudo docker pull smalldatalab/ohmage-shim-server:latest
sudo docker pull smalldatalab/ohmage-dpu-server:latest
```

## Start and configure the databases

To start both databases, run the following:

```
sudo docker run --name ohmage-mongo -d mongo:latest
sudo docker run --name ohmage-postgres -d postgres:latest
```

The Mongo database is ready to go, but the Postgres database needs to be initialized by adding a few tables.  To add those tables, complete the following steps:

1. Run `docker exec -it ohmage-postgres bash` to start a shell on the `ohmage-postgres` container
1. Run `psql -U postgres` in the resulting shell to start `psql`
1. Copy and paste the contents of the [database setup script](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/initialize-auth.sql) to create the schema.
1. Update the contents of the [client initialization script](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/initialize-oauth-clients.sql) to a) select the client apps you will use with your installation, and b) setting the `client_secret` values, which you can get from your contact in the Small Data Lab.
1. Copy and paste the contents of the updated script, to create the records in the database. 
1. `\q` to exit `psql`
1. `exit` to exit the shell





## Configure and start other server components

The next sections will give you commands to start each of the Docker containers.  When starting the containers you will pass in configuration variables used by the server as a `-e` parameter.  Some variables will be specific to your environment, and in those cases we will denote places where you should fill in variable values with `{}`.  For example, we'll reference your domain name as "{BASE URL}".

Start the authorization server with:

```
sudo docker run --name ohmage-auth --link ohmage-postgres:omh-postgres --link ohmage-mongo:omh-mongo -d -p 8082:8082 -e application.url={BASE URL}/dsu/ -e google.clientId={GOOGLE CLIENT ID} -e google.clientSecret={GOOGLE CLIENT SECRET} -e server.port=8082 -v /var/log/ohmage-auth:/var/log/ohmage-auth 'smalldatalab/ohmage-auth-server:latest'
```
NOTE: Be sure to include 'http://' in the `application.url` variable.

Start the resource server with:

```
sudo docker run --name ohmage-resource --link ohmage-postgres:omh-postgres --link ohmage-mongo:omh-mongo -d -p 8083:8083 -e server.port=8083 -e spring.dataSource.username=postgres -e spring.dataSource.password=postgres -v /var/log/ohmage-resource:/var/log/ohmage-resource 'smalldatalab/ohmage-resource-server:latest'
```

Start the Admin server with:

```
docker run --name ohmage-admin -d -p 3000:3000 -e APP_DB_DATABASE=admindashboard  -e APP_DB_PASSWORD=postgres -e APP_DB_USERNAME=postgres -e MANDRILL_USERNAME='{MAIL USERNAME}' -e MANDRILL_PASSWORD='{MAIL PASSWORD}' --link ohmage-postgres:omh-postgres --link ohmage-mongo:omh-mongo 'smalldatalab/ohmage-admin-server:latest'
```

Start the shim server with:

```
sudo docker run --name ohmage-shim --link ohmage-mongo:omh-mongo -d -p 8084:8084 -e openmhealth.shim.server.callbackUrlBase={BASE URL}/shims -e openmhealth.shim.fitbit.clientId={FITBIT API KEY} -e openmhealth.shim.fitbit.clientSecret={FITBIT API SECRET} -e server.port=8084  'openmhealth/ohmage-shim-server:latest'
```

Start the DPU server with:

```
sudo docker run --name ohmage-dpu --link ohmage-mongo:omh-mongo --link ohmage-shim:omh-shim -d -p 8085:8085 'openmhealth/ohmage-dpu-server:latest'
```




## Configure and start nginx server

If it isn't already, install nginx on the host machine.  On Ubuntu you can do this with:

```
sudo apt-get install nginx
```

You can verify it is running by navigating to the base URL, and seeing the Nginx default page.

We've provided a sample nginx config file, [here](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/ohmage.nginx), but you will need to update some of the values on a local copy.  Name the file ohmage.nginx, make the updates to the `server_name` variable, and then copy that file to the server.  On linux, you can do that by navigating to the directory that has the file on your local, and running the following
```
scp ohmage.nginx ubuntu@{BASE URL}:~
```

Then on the server machine, as that user copy them to the appropriate location with something like this:
```
sudo chown root:root ohmage.nginx
sudo chmod 755 ohmage.nginx
sudo service nginx stop
sudo mv ~/ohmage.nginx /etc/nginx/sites-available/ohmage
sudo ln -s /etc/nginx/sites-available/ohmage /etc/nginx/sites-enabled/ohmage
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx start
```

At this point, you should be ready to go.  For instructions on how to setup some test users to verify things are working properly, you can walk through the tutorial [here](https://github.com/smalldatalab/docker-ohmage-omh-suite/wiki/Sample-User-Walkthru)