# Docker limits and the JVM

## You will learn to...

* Understand the behavior of a JVM
* Correctly configure the memory and cpu limits of it

## Recap: JVM limits configuration

`-Xmx` sets the upper memory limit assigned to the JVM. To start an application with a maximum of 1GB of assigned RAM you will execute:

```
java -Xmx1Gb -jar demo.jar
```

By default the value of `Xmx` is 25% of the total availaible memory.


## Docker and memory limits

Let's create a container with a limit of 10MB of RAM. We will check how much of it is availaible for us:

```
docker run -it --memory 10m bash
bash-4.4# free
bash-4.4# top
bash-4.4# cat /sys/fs/cgroup/memory/memory.stat

```

## Answer these questions:

* How much free memory are `free` and `top` tools reporting?
* Why?
* What is going to happen if you run a JVM without an explicit `Xmx` argument?

## Docker stats

The correct way to know the available memory in a container is `docker stats`. If you want to be able to use that command from inside a container you can mount the docker daemon socket inside the container:

``` 
docker run -it -v /var/run/docker.sock:/var/run/docker.sock --memory 10m docker /bin/sh
/ # docker stats --no-stream $HOSTNAME
```

## Answer to this question

* As a general rule, is it a good idea to grant access to the Docker daemon process from the containers?

## CPU limits

* -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
* -XX:CICompilerCount
* -XX:ParallelGCThreads


