Ubuntu Quick Start Guide
=========================

This guide will walk you through deploying a Generic Ubuntu application on AWS using OpDemand.

Prerequisites
--------------
* A [free OpDemand account](https://app.opdemand.com/signup) with
  * Valid AWS credentials
  * Linked GitHub account
* The OpDemand Command Line Interface
* An application that is **hosted on GitHub**

Clone your Application
----------------------
The simplest way to get started is by forking OpDemand's sample application located at:
<https://github.com/opdemand/example-vanilla-ubuntu>

After forking the project, clone it to your local workstation using the SSH-style URL:

    $ git clone git@github.com:mygithubuser/example-vanilla-ubuntu.git example-vanilla-ubuntu
    $ cd example-vanilla-ubuntu

If you want to use an existing application, no problem -- just make sure you've cloned it from GitHub.

Prepare your Application
------------------------
To make a Generic application work with OpDemand, you will need to conform to 3 basic requirements:

 * Use **bin/deploy** to manage dependencies
 * Use [**foreman**](http://ddollar.github.com/foreman/) to manage processes
 * Use **Environment Variables** to manage configuration

If you're deploying the example application, it already conforms to these requirements.  If you're in a rush, skip to [Create a new Service](#create-a-new-service).

### Use bin/deploy to manage dependencies

On every deploy action, OpDemand will run the `bin/deploy` script on all application workers to ensure dependencies are up to date. A few notes about this mechanism:

* The script needs to be marked as executeable in version control (`chmod +x bin/deploy`)
* The script can be written in any language but must include the proper `#!/bin/sh` style declaration at the top
* The latest version of the script will be pulled on the application workers prior to it being executed
* Because this script will run on every deploy action, the script must be idempotent

### Use Foreman to manage processes

OpDemand uses a Foreman Procfile to manage the processes that serve up your application.  The `Procfile` is how you define the command(s) used to run your application.  Here is an example `Procfile` for a generic application:

    web: ./server.sh $APPLICATION_PORT

This tells OpDemand to run one web process using the `server.sh` file in the repository root.  You can test this out locally by running setting the `APPLICATION_PORT` environment variable and calling `foreman start`.

    $ export APPLICATION_PORT=8080
	$ foreman start
    12:45:57 web.1     | started with pid 28834

### Use Environment Variables to manage configuration

OpDemand uses environment variables to manage your application's configuration.  For example, the application listener must use the value of the `APPLICATION_PORT` environment variable.  The same is true for external services like databases, caches and queues which use environment variables like `DATABASE_HOST` and `DATABASE_PORT`.

<a id="create-a-new-service"></a>
Create a new Service
---------------------
Use the `opdemand list` command to list the available infrastructure templates:

	$ opdemand list | grep vanilla
    app/vanilla/1node: Vanilla Application (1-node)
    app/vanilla/2node: Vanilla Application (2-node with ELB)
    app/vanilla/4node: Vanilla Application (4-node with ELB)
    app/vanilla/Nnode: Vanilla Application (Auto Scaling)

Use the `opdemand create` command to create a new service based on one of the templates listed.  To create an `app/vanilla/1node` service with `app` as its handle/nickname.

	$ opdemand create app --template=app/vanilla/1node

Configure the Service
----------------------
To quickly configure a service from the command-line use `opdemand config [handle] --repository=detect`.  This will attempt to detect and install repository configuration including:

* Detecting your GitHub repository URL, project and username
* Generating and installing a secure SSH Deploy Key

More detailed configuration can be done using:

	$ opdemand config app					   # the entire config wizard (all sections)
	$ opdemand config app --section=provider   # only the "provider" section

Detailed configuration changes are best done via the web console, which exposes additional helpers, drop-downs and overrides.

Start the Service
------------------
To start your service use the `opdemand start` command:

	$ opdemand start app

You will see real-time streaming log output as OpDemand orchestrates the service's infrastructure and triggers the necessary SSH deployments.  Once the service has finished starting you can access its services using an `opdemand show`.

    $ opdemand show app

	Application URL (URL used to access this application)
	http://ec2-23-20-231-188.compute-1.amazonaws.com

Open the URL and you should see "Powered by OpDemand" in your browser.  To check on the status of your services, use the `opdemand status` command:

	$ opdemand status
	app: Vanilla Application (1-node) (status: running)

Deploy the Service
----------------------
As you make changes to your application code, push those to GitHub as you would normally.  When you're ready to deploy those changes, use the `opdemand deploy` command:

	$ opdemand deploy app

This will trigger an OpDemand deploy action which will -- among other things -- update configuration settings, pull down the latest source code, install new dependencies and restart services where necessary.


Additional Resources
====================
* <http://www.opdemand.com>
