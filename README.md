# Descoped Docker Crowd

## About

Crowd is an Identity Management Application for web apps that are used by other Atlassian application to simplify access control. Crowd consists of several independent components that are configurable by setting environment variables when running the image.

For all other aspects about configuring, using and administering Crowd please see [The Official Crowd Documentation](https://confluence.atlassian.com/display/CROWD/Crowd+Documentation).

## How to use?

The examples shown below assumes you will use a MySQL database.

> Please pay attention to the IP addresses used in the examples below. The IP `192.168.1.2` refers to your host OS. The IP `172.17.0.2` refers to the MySQL database and the IP `172.17.0.3` to the newly installed Crowd image. To figure out the IP in your guest OS you can either connect to a running instance by issuing `docker exec -it [container-name] /bin/bash` and do `ifconfig` or locate the IP from `docker inspect [container-name]`.


### Prerequisites

* MySQL 5.5 or 5.6 (please notice that Crowd is not compatible with MySQL 5.7)
* PostgreSQL 8.4+

> Important notice: The Postgres driver is shipped with the Crowd distribution, whereas the MySQL driver will be downloaded when running the image.

#### Database Setup

MySQL setup (assuming that MySQL isn't installed yet):

```
$ docker run -d -p 3306:3306 --name mysql -v /var/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=[db-password] mysql/mysql-server:5.6
$ mysql -h 172.17.0.2 -u root -p[db-password]
CREATE DATABASE IF NOT EXISTS crowd character set utf8 collate utf8_bin;
CREATE DATABASE IF NOT EXISTS crowdid character set utf8;
```

If you use a default Docker installation with no images installed, the assigned IP for MySQL will be: `172.17.0.2`.

Optionally you may configure security constraints by:

```
GRANT ALL PRIVILEGES ON crowd.* TO '[appuser]'@'172.17.0.3' IDENTIFIED BY '[apppassword]' with grant option;
GRANT ALL PRIVILEGES ON crowdid.* TO '[appuser]'@'172.17.0.3' IDENTIFIED BY '[apppassword]' with grant option;
```


> Please notice that the `[appuser]` and `[apppassword]` must be configured to what is appropriate for your system.


### Installation

Run docker using port 8095 on your host (if available):

```
docker run -p 8095:8095 descoped/crowd
```


Run with data outside the container using a volume:

```
$ docker run --name crowd -v /var/crowd-home:/var/atlassian-home -e CROWD_CONTEXT=ROOT -e CROWD_URL=http://localhost:8095 -e CROWDDB_URL=mysql://[db-username]:[db-password]@172.17.0.2/crowd -e CROWDIDDB_URL=mysql://[db-username]:[db-password]@172.17.0.2/crowdid -e SPLASH_CONTEXT= -p 8095:8095 descoped/crowd
```


#### Workaround for error with Remote address

After the initial installation you may experience an issue where you are not allowed to login to Crowd. This is because the Crowd guest IP (e.g. 172.17.0.3) is not registered with Crowd. In order to circumvent this issue you need to add your Docker Gateway IP to the Crowd database as follows: 

```
$ mysql -h 172.17.0.2 -u root -p[db-password] crowd;
SELECT id FROM cwd_application WHERE application_name = "crowd";               # expected return value: 2
SELECT id FROM cwd_application WHERE application_name = "crowd-openid-server"; # expected return value: 3
INSERT INTO cwd_application_address (APPLICATION_ID, REMOTE_ADDRESS) VALUES (2,'172.17.0.1');
INSERT INTO cwd_application_address (APPLICATION_ID, REMOTE_ADDRESS) VALUES (3,'172.17.0.1');
```

After this step the `crowd` instance needs to be restarted:

```
$ docker crowd stop
$ docker crowd start
```

You should now be able to login to Crowd.

#### Docker Volume

The mappable VOLUME is: `/var/atlassian-home`

#### Browser URL:

```
http://192.168.1.2:8095/
```


The host IP is assumed to be `192.168.1.2`.

### Configuration

#### Database connection

The connection to the database can be specified with an URL of the format:
```
[database type]://[username]:[password]@[host]:[port]/[database name]
```

Where ```database type``` is either ```mysql``` or ```postgresql``` and the full URL look like this:

**MySQL:**

```
mysql://<username>:<password>@172.17.0.2/jiradb
```

**PostgreSQL:**

```
postgresql://<username>:<password>@172.17.0.2/jiradb
```


### Environement variables

#### Default welcome splash pages

This component serves just as a welcome page and since it is by default loaded as the root context will be the first thing you see when going to http://localhost:8095. As such it has links to the other components but keep in mind that these links will not be updated should you change the context path of any of the components.

For anything but a default install it is recommended that you disable this component by setting its context path to the empty string. 

Variable       | Function
---------------|------------------------------
SPLASH_CONTEXT | Context path of the splash pages. Defaults to ```ROOT``` as this webapp serves as a welcome page and you will usually just want to set this to blank to not load this component.


#### Crowd

The main component included and really the only component that you truly need. This component needs a database but can use an embedded HSQLDB for testing purposes and so the database related variables are not mandatory. 

Variable      | Function
--------------|------------------------------
CROWD_URL     | URL used by the console to talk to itself. 
CROWD_CONTEXT | Context path of the crowd webapp. Set this to ```ROOT``` to make this component have no context path. Set to blank string to not load the Crowd component. Please note that the context path for each component must be unique. Defaults to ```crowd```
CROWDDB_URL   | Connection URL specifying where and how to connect to a database dedicated to crowd.
DATABASE_URL  | If only Crowd and not CrowdID is set to load you can use this variable as an alternative to the ```CROWDDB_URL``` variable.


#### CrowdID

The bundled OpenID server. Like the Crowd component this also needs a database and it is imperative that this be independent of the Crowd database. 

Variable          | Function
------------------|------------------------------
CROWD_URL         | URL of the crowd server that the webapp talks to. This need not be on the same machine that is running the CrowdID component.
CROWDID_CONTEXT   | Context path of the CrowdID webapp. Defaults to ```openidserver```
CROWDIDDB_URL     | Connection URL specifying where and how to connect to a database dedicated to CrowdID. This database must be separate from the one used by Crowd
DATABASE_URL      | If only CrowdID and not Crowd is set to load you can use this variable as an alternative to the ```CROWDIDDB_URL``` variable.
LOGIN_BASE_URL    | Combined with ```CROWDID_CONTEXT``` to set the ```CROWDID_LOGIN_URL``` value if that variable is unset.
CROWDID_LOGIN_URL | The URL that crowd will redirect the user to this URL if their authentication token expires or is invalid due to security restrictions.


#### OpenID client

An OpenID client that can be used to test the CrowdID integration.

Variable              | Function
----------------------|------------------------------
OPENID_CLIENT_CONTEXT | Context path of the client. Defaults to ```openidclient```.


#### Demo webapp

A demonstration webapp that shows how Crowd integration works.

Variable       | Function
---------------|------------------------------
CROWD_URL      | URL of the crowd server that the webapp talks to.
DEMO_CONTEXT   | Context path of the crowd webapp. Set to blank string to not load the Crowd component. Please note that the context path for each component must be unique. Defaults to ```demo```
LOGIN_BASE_URL | Combined with ```DEMO_CONTEXT``` to set the ```DEMO_LOGIN_URL``` value if that variable is unset.
DEMO_LOGIN_URL | The URL that crowd will redirect the user to this URL if their authentication token expires or is invalid due to security restrictions.


## Source code

If you want to contribute to this project or make use of the source code; you'll find it on [GitHub](https://github.com/descoped/docker-crowd).

### Building the image

```
docker build -t descoped/crowd .
```

### Further reading

* Reference to [base image](https://hub.docker.com/r/descoped/atlassian-base/).
