# Descoped Docker Crowd

## What is this image?

The docker image is based on the standalone install of Crowd and as such consists of several independent components that each have several configurable options and that can also be entirely disabled. The configuration options themselves are set by setting environment variables when running the image

What follows is a short description of each component and the configuration options that affect that component. For all other aspects about configuring, using and administering Crowd please see [The Official Crowd Documentation](https://confluence.atlassian.com/display/CROWD/Crowd+Documentation)

## How to use this image?

The examples shown below assumes you will use a MySQL database.

### Pre-requisites

* MySQL 5.6 (it is not compatible with MySQL 5.7)
* Postgres driver is shipped with the Crowd distribution, so please confer the documentation for compatibility

### Execution

Run docker using port 8095 on your host (if available):

```
docker run -p 8095:8095 descoped/crowd
```

Run with repo outside the container using an external volume:

```
$ UID=root
$ PWD=<pwd>
$ docker run --name crowd -v /var/crowd-home:/var/atlassian-home -e CROWD_CONTEXT=ROOT -e CROWD_URL=http://localhost:8095 -e CROWDDB_URL=mysql://$UID:$PWD@localhost/crowd -e CROWDIDDB_URL=mysql://$UID:$PWD@localhost/crowdid -e SPLASH_CONTEXT= -p 8095:8095 descoped/crowd
```

### Docker Volume

The mappable VOLUME is: `/var/atlassian-home`

### Browser URL:

```
http://localhost:8095/
```

### Configuration

#### Database Setup

MySQL:

```
CREATE DATABASE IF NOT EXISTS crowd character set utf8 collate utf8_bin;
CREATE DATABASE IF NOT EXISTS crowdid character set utf8;
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

If you want to contribute to this project or make use of the source code; you'll find it on GitHub:

[https://github.com/descoped/docker-crowd](https://github.com/descoped/docker-crowd)

### Building the image

```
docker build -t descoped/crowd .
```
