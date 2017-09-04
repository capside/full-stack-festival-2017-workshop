# Límites en Docker y la jvm

## Aprenderás a...

* Entender el comportamiento de la jvm en un contenedor
* Configurar correctamente los límites de la misma

## Repaso: límites en jvm

Mediante `-Xmx` se establece el límite superior de memoria asignada a la jvm. Si necesitas ejecutar una aplicación asignándole 1GB de ram usarás:

```
java -Xmx1Gb -jar demo.jar
```

Por defecto el valor de Xmx suele ser un 25% de la memoria total disponible.

## Docker y la instrumentación de RAM

Vamos a crear un contenedor asignándole solo 10MB de memoria y veremos qué cantidad de RAM nos deja disponibles para nosotros:

```
docker run -it --memory 10m bash
bash-4.4# free
bash-4.4# top
bash-4.4# cat /sys/fs/cgroup/memory/memory.stat

```

## Responde:

* ¿Qué cantidad de memoria libre te indican estas herramientas? ¿Por qué?
* ¿Qué sucederá si arrancas una jvm sin explicitar `-Xmx`?
* ¿Crees que herramientas como *new relic* son fiables para monitorizar la ram libre?

## Docker stats

La forma correcta de averiguar la memoria libre es usar `docker stats`. Si quieres utilizarlo desde el interior de un contenedor es posible montar el socket de comunicación para usar docker in docker:

``` 
docker run -it -v /var/run/docker.sock:/var/run/docker.sock --memory 10m docker /bin/sh
/ # docker stats --no-stream $HOSTNAME
```

## Responde:

* ¿Qué consecuencias tiene utilizar docker in docker a nivel de seguridad?

## Experiencia

* -Xmx
* -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
* -XX:CICompilerCount
* -XX:ParallelGCThreads


## Repaso: límites en Docker

* --cpus 1 
* --memory 512m 
* --blkio-weight 500

