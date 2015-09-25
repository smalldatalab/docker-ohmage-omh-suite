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

`NOTE:` It is possible to setup and run the Ohmage suite without creating any of the 3rd party accounts listed below, and you can always come back later and add integration with these services. If you want to run Ohmage without these 3rd party services, skip to Step 2.

#### 3rd Party - Google Client ID

Currently, the Ohmage suite allows users to login using their Google account.  To enable this, you will register your instance of the suite with Google, so they can provide the authorization between the user and your system.  When you have done this, Google will assign your system a 'clientId' and 'clientSecret' which you will use for credentials.

To start you will need to have a project on the Google APIs Console (you can create a new one or add to an existing one).  You can find more information about that [here](https://developers.google.com/console/help/)  To add a Client ID within the project, navigate to the project console, and on the left-hand menu select APIs & auth > Credentials.  Select "Create a new Client ID".  Enter the information and create the ID.  NOTE: You must have a domain name for your server, because Google APIs does not accept raw IP addresses as redirects.

Record your `clientId` and `clientSecret` for later.   


#### 3rd Party - Fitbit API

If you wish to use Fitbit data, you will need to create a developer account with them and register your instance of the suite to get a 'clientId' and 'clientSecret'.  If you do not wish to use Fitbit data, you can skip this, and additionally exclude those parameters when starting the shim Docker container, below.  (i.e. remove '-e openmhealth.shim.fitbit.clientId=...' and '-e openmhealth.shim.fitbit.clientSecret=...' when starting the container).

To get started, go [here](https://dev.fitbit.com) and create a developer account.  Once you logged into the developer account, select "Register an App", which takes you [here](https://dev.fitbit.com/apps/new).  Enter the information for your instance of the suite.  Use the following settings:

```
Application Type = Browser
Callback URL = {YOUR BASE DOMAIN URL}/shim/fitbit
Default Access Type = Read-Only
```

Once created, record the `Client (Consumer) Key` and `Client (Consumer) Secret` for later.  NOTE: the 'clientId' that we'll use below is actually what Fitbit shows as the 'Client Key', not what they label as the 'OAuth 2.0 Client ID'.

## Step 2: Edit the 'docker-compose' file
Docker Compose is a tool for configuring multiple Docker containers with a single script.  When creating and starting all the containers, you will specify a single 'docker-compose.yml' file to automate the setup.

The main template for the `docker-compose` file is in this repository in the /omh directory, [here](http://github.com/smalldatalab/omh-dsu/omh/docker-compose.yml).  Copy this file to your local machine, either by cloning the repository or just copy/paste the content into a local file of the same name.

If you are setting up the a local version of Ohmage, you can use the file as is.  If you are running on a remote server, you will want to update the variable values that in the file, indicated with "{}" brackets.

## Step 3: Setup the machine and install Docker

Our testing was done on an AWS instance, with their Ubuntu 14.04.2 distro. However, the suite should run fine on any OS that is supported by Docker.  The rest of the instructions assume you are able to access a terminal on your host machine (ssh).

Once your machine is setup, you can find instructions to install Docker for your OS [here](https://docs.docker.com/installation/).

If you are using Ubuntu, the instructions are [here](https://docs.docker.com/installation/ubuntulinux/).

## Step 4: Transfer you docker-compose file and run it
Somehow, you need to get your modified `docker-compose.yml` file to the server, in the home directory.

If you are using Linux, you can transfer the file with:
```
scp docker-compose.yml ubuntu@{BASE URL}:~/omh
```

Once the file is transferred, you can run it through the terminal on the machine with:
```
cd ~/omh
sudo docker-compose up -d
```


## Step 5: Initialize the databases and restart

The Mongo database is ready to go, but the Postgres database needs to be initialized by adding a few tables.  To add those tables, complete the following steps:

1. Run `docker exec -it omh_ohmage-postgres_1 bash` to start a shell on the `ohmage-postgres` container
1. Run `psql -U postgres` in the resulting shell to start `psql`
1. Copy and paste the contents of the [database setup script](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/initialize-auth.sql) to create the schema.
1. Update the contents of the [client initialization script](https://github.com/smalldatalab/docker-ohmage-omh-suite/blob/master/initialize-oauth-clients.sql) to a) select the client apps you will use with your installation, and b) setting the `client_secret` values, which you can get from your contact in the Small Data Lab.
1. Copy and paste the contents of the updated script, to create the records in the database. 
1. `\q` to exit `psql`
1. `exit` to exit the shell

Once the databases are ready, you can simply restart all the containers and they will be ready to go.  Restart with:
```
sudo docker-compose stop
sudo docker-compose up -d
```

At this point, you should be ready to go.  For instructions on how to setup some test users to verify things are working properly, you can walk through the tutorial [here](https://github.com/smalldatalab/docker-ohmage-omh-suite/wiki/Sample-User-Walkthru)