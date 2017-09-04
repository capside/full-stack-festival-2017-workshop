# Dockerizing tools

## You will learn how to...

* Create images from a Dockerfile
* Pack a tool as an image with its dependencies
* Easily execute your dockerized toolchain

## Requisites

* It will be useful to have your own account in a registry, for example at http://hub.docker.io
* You will end earlier if you change all the XX for the real name of the repository in this file (for example, in my case it will be ciberado).

## The tool

We have developed our own version of the *excuse* command using nodejs:

``` javascript
var fs = require('fs');
var excuse = fs.readFileSync('excuse.txt')
               .toString().split("\n");
var idx = process.argv.length >= 3 ? 
          process.argv[2] : 
		  Math.floor(Math.random() * excuse.length);
console.log(excuse[idx % excuse.length]);
```

Invoking the tool without any parameter will show a random qoute. If you use a numeric parameter it will show you the quote corresponding to that number in the index. Here you have some examples of sentences present in the `excuses.txt` file.

```
I have to floss my cat.
I've dedicated my life to linguine.
I want to spend more time with my blender.
The President said he might drop in.
The man on television told me to say tuned.
I've been scheduled for a karma transplant.
```

## The Dockerfile

The most interesting part of the `Dockerfile` is that it uses `ENTRYPOINT` to specify the command to be executed and `CMD` to provide default options (the first sentence of the file).

```
FROM node:7.10.0-alpine

COPY excuse.js excuses.txt ./

ENTRYPOINT ["node", "excuse.js"]
CMD ["0"]
```

## Building the image

From the directory that contains the project, execute:

```
docker build -t <your-registry>/excuse .
docker tag <your-registry>/excuse latest
```

As an option, you can upload it to the registry:

```
docker push <your-registry>/excuse
```

## Testing

Remember that by using `ENTRYPOINT` instead of just `CMD` the first parameter after the name of the image in the `run` command will be the first parameter passed to the entrypoint, not the name of the command to be executed inside the container.

```
docker run --rm -it <your-registry>/excuse 

docker run --rm -it <your-registry>/excuse 20
```

Even though, remember that with '--entrypoint' it is possible to rewrite the process launched by the container.

## Making execution easier

You can take advantage of the `alias` command in Unix or the `doskey` command in Windows to ease the invocation of the tool:

Windows
```
doskey qt=docker run --rm -it <your-registry>/excuse $*
```

Linux
```
alias http='docker run -it --rm <your-registry>/excuse'
```

Now you just need to invoke `qt` to launch your container.

## Dockerizing Httpie

[Httpie](http://httpie.org) is the application that will make you forget 'curl'. We are going to dockerize it and we will discuse the limitations of this approach on Windows & Mac.

Windows
```
doskey http=docker run -it --rm --net=host clue/httpie $*
http https://api.chucknorris.io/jokes/random
```

Linux
```
alias http='docker run -it --rm --net=host clue/httpie'
http https://api.chucknorris.io/jokes/random
```

* Why you cannot use `localhost` or `127.0.0.1` as the destination address?

## Dockerizing Azure CLI

Azure cli is the multiplatform command line tool that allows you to interact with Microsoft's cloud. It is based on Python and often is not really easy to install if you are running Windows. Lets solve that problem with Docker.

* Execute the tool just to get familiar with it

```
docker run -it azuresdk/azure-cli-python az --version
```

* Launch de default process (a shell) and get a list of the vm running in your account

```
docker run -it azuresdk/azure-cli-python azure 
root@406bf15c8930:/# az login
root@406bf15c8930:/# az vm list-usage -l westeurope
```

* Now, invoke directly the tool from the host prompt. Can you explain why it does not work as expected?

```
docker run -it --rm azuresdk/azure-cli-python az login
docker run -it --rm azuresdk/azure-cli-python az vm list-usage -l westeurope
```

* Set up the volume that keeps the tool's configuration so the container can access to the recorded credentials

```
REM windows
docker run -it --rm --volume %USERPROFILE%/.azure:/root/.azure azuresdk/azure-cli-python az login
docker run -it --rm --volume %USERPROFILE%/.azure:/root/.azure azuresdk/azure-cli-python az vm list-usage -l westeurope
```

```
# BASH
docker run -it --rm --volume $HOME/.azure:/root/.azure azuresdk/azure-cli-python az login
docker run -it --rm --volume $HOME/.azure:/root/.azure azuresdk/azure-cli-python az vm list-usage -l westeurope
```

* Now create an alias in order to make the tools' invocation easier. Remember: if you are using *git bash* you must disable the path transformation first with `export MSYS_NO_PATHCONV=1`.

```
rem WINDOWS
doskey az=docker run -it --rm --volume %USERPROFILE%/.azure:/root/.azure azuresdk/azure-cli-python az $*
az vm list-usage westeurope
```

Linux
```
# BASH
alias az='docker run -it --rm --volume $HOME/.azure:/root/.azure azuresdk/azure-cli-python az'
az vm list-usage westeurope
```

## Launch a container using ACI

With Azure Container Instances is very easy to deploy containers on managed hosts.

* Ensure you are logged in your Azure account and your suscription is correctly selected:

```
az login
az account list --output table
```

* Create a resource group:

```
az group create --name contdemo --location westeurope
```

* Launch de container:

```
az container create -g contdemo --name riversong --image ciberado/riversong:port80 --ip-address public
```

* Check the logs

```
az container logs --resource-group contdemo --name riversong
```

* Get the public IP and visit it with your browser:

```
az container list --output table
```

* Remove all the used resources:

```
az group delete --name contdemo
```


## Conclusions

Well done! Now you are aware of how easily you can dockerize your tools, from *grunt* to different runtime versions of *nodejs*. And yes, you can also dockerize Docker but that is a story for another day.

