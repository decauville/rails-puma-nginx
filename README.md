# rails-puma-nginx
Dockerfile for rails dockerization.

![alt text][logo]

[logo]: https://cdn-images-2.medium.com/max/1000/1*afscT1tmdd0JmtEy2UUsSw.png "Container Interaction Diagram"

##BUILD YOUR OWN IMAGE AND RUN YOUR CONTAINERS

I created a Docker image builder repo which helps you to build your application’s own docker image. Just follow the steps below:

###REQUIREMENTS

•	Install Docker to your server (https://docs.docker.com/engine/installation/). I will be referring the server as docker host for the rest of the tutorial.

•	I used Ubuntu 14.04 as my docker host’s OS. Although it is possible the follow the steps to containerize your application, there might be slight differences in bash commands given below.

###CREATE DATABASE CONTAINER
•	Run your database container. The command below will run official postgres image as your database. 

```docker run --name DATABASE_CONTAINER_NAME -e POSTGRES_PASSWORD=DATABASE_PASSWORD -d postgres```

You can feel free to use other databases as your container. However, do not forget them to link them to your application container.

###CREATE APPLICATION CONTAINER
•	Create a folder for your build materials.

•	Clone Decauville repo into your brand new folder.

```git clone https://github.com/decauville/rails-puma-nginx.git .```

•	To build your image, fill the words in bold according to your needs and execute the command below. This may take 20 minutes, go take some coffee.

```docker build --build-arg DATABASE_USER=DATABASE_USERNAME --build-arg DATABASE_PASSWORD=DATABASE_PASSWORD --build-arg DATABASE_HOST=DATABASE_CONTAINER_NAME --build-arg APP_URL=YOUR_APP_GIT_URL -t decauville:latest .```

•	Upon building the image, run your application by executing command below.

```docker run -d --name APPLICATION_CONTAINER_NAME -p 80:80 --link DATABASE_CONTAINER_NAME decauville:latest```

If you want to share a folder from your docker host with your application execute this:

```docker run -d --name APPLICATION_CONTAINER_NAME -v DOCKER_HOST_DIRECTORY_PATH:APPLICATION_CONTAINER_DIRECTORY_PATH -p 80:80 --link curtain-db decauville:latest```

And that’s it. If you are lucky enough and your app does not have any uncommon package dependencies, your app is ready to rock.

If you still feel that you don’t understand the process entirely, you can check out build and run script for my application.

##TROUBLESHOOTING
During image building, it is possible to encounter some problems. Docker will inform you about at which step in Dockerfile failure occurs. Do not hesitate to modify Dockerfile. Just comment out the lines below the last successful step and build your image. To open up a bash terminal in your pre-built container, execute the command below.

```docker run -it decauville:latest /bin/bash```

In your container, try to execute the failing Dockerfile command manually. Don’t be reluctant to ask me questions and do not forget: Google is your best friend.

If you can find the reason why your image fails to build, and you can solve it just by editing the existing Dockerfile, please fork the Decauville project on the github.

##CUSTOMIZATION
The Decauville project contains configuration files for puma and NGINX. You can configure them for your requirements before building your application image.

Moreover, at your container startup, docker-entrypoint.sh is called to run your web servers. You can add additional steps to the script to execute the commands which is required by your application.
