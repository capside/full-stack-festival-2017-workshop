# Dockerización de herramientas

## Aprenderás a...

* Crear imágenes a partir de un Dockerfile
* Empaquetar como una imagen una herramienta y sus dependencias
* Ejecutar de forma cómoda tu *toolchain* en un contenedor

## Requisitos

* Te será útil tener tu propia cuenta en un *registry*, por ejemplo en http://hub.docker.io.
* Terminarás antes si sustituyes en este fichero todas las apariciones de <tu-registro> por el nombre real de tu repositorio (por ejemplo, *ciberado* en mi caso).

## La herramienta

Hemos programado nuestra propia pequeña versión del commando *excuse* usando nodejs:

``` javascript
var fs = require('fs');
var excuse = fs.readFileSync('excuses.txt')
               .toString().split("\n");
var idx = process.argv.length >= 3 ? 
          process.argv[2] : 
		  Math.floor(Math.random() * excuse.length);
console.log(excuse[idx % excuse.length]);
```

Una invocación sin parámetros muestra una frase aleatoria. Si pasamos un parámetro numérico muestra la frase cuyo índice corresponde al número indicado. Aquí tienes algunos ejemplos de frases contenidas en el fichero `excuses.txt`:

```
I have to floss my cat.
I've dedicated my life to linguine.
I want to spend more time with my blender.
The President said he might drop in.
The man on television told me to say tuned.
I've been scheduled for a karma transplant.
```

## El Dockerfile

La parte más interesante del *Dockerfile* es que utiliza `ENTRYPOINT` para especificar el comando a ejecutar y `CMD` para mostrar por defecto siempre la primera frase del fichero.

```
FROM node:7.10.0-alpine

COPY excuse.js excuses.txt ./

ENTRYPOINT ["node", "excuse.js"]
CMD ["0"]
```

## Construyendo la imagen

Desde la carpeta que contiene el proyecto ejecuta:

```
docker build -t <tu-registro>/excuse .
docker tag <tu-registro>/excuse latest
```

Opcionalmente puedes subirla al registro:

```
docker push <tu-registro>/excuse
```

## Ejecutando una prueba

Fíjate que al haber utilizado en el *Dockerfile* `ENTRYPOINT` en lugar de directamente `CMD` el parámetro indicado tras el nombre de la imagen (`20`) se toma como **el primer parámetro del comando a ejecutar**, no como el nombre del comando en sí.

```
docker run --rm -it <tu-registro>/excuse 

docker run --rm -it <tu-registro>/excuse 20
```

Aún así recuerda que con `--entrypoint` es posible sobreescribir el proceso lanzado por el contenedor.

## Facilitando la ejecución

Puedes crear un *alias* para no tener que escribir todo el encantamiento anterior:

Windows
```
doskey qt=docker run --rm -it ciberado/excuse $*
```

Linux
```
alias http='docker run -it --rm ciberado/excuse'
```

Ahora tan solo necesitas ejecutar `qt` para lanzar el contendor.

## Dockerizando Httpie

[Httpie](http://httpie.org) es el programa que hará que te olvides del venerable `curl`. Vamos a ejecutarlo dockerizado, aunque comprobarás que con algunas limitaciones:

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

* ¿Por qué no es posible utilizar Httpie con direcciones locales en Windows y Mac?

## Dockerizando Azure CLI

Azure cli es la herramienta multiplataforma que permite automatizar la interacción con el cloud de Microsoft. Está basada en Python y a menudo es problemático instalarla correctamente (sobre todo en Windows). Vamos a solucionarlo con Docker.

* Ejecuta la herramienta para familiarizarte con ella

```
docker run -it azuresdk/azure-cli-python az --version
```

* Lanza el proceso por defecto (una shell) y obtén la lista de las vm que corren en tu cuenta de Azure

```
docker run -it azuresdk/azure-cli-python azure 
root@406bf15c8930:/# az login
root@406bf15c8930:/# az vm list-usage -l westeurope
```

* Invoca directamente la herramienta desde el prompt del host. ¿Puedes explicar por qué no funciona como esperamos?

```
docker run -it --rm azuresdk/azure-cli-python az login
docker run -it --rm azuresdk/azure-cli-python az vm list-usage -l westeurope
```

* Monta el volumen que almacena la configuración de la herramienta para que recuerde las credenciales proporcionadas

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

* Crea un alias para que la invocación sea más sencilla. Recuerda que si estás usando *git bash* (mingw) debes desactivar la transformación de rutas con `export MSYS_NO_PATHCONV=1`.

```
REM windows
doskey az=docker run -it --rm --volume %USERPROFILE%/.azure:/root/.azure azuresdk/azure-cli-python az $*
az vm list-usage westeurope
```

```
# BASH
alias az='docker run -it --rm --volume $HOME/.azure:/root/.azure azuresdk/azure-cli-python az'
az vm list-usage westeurope
```

## Lanza un contenedor en ACI

Azure Container Instances permite crear contenedores en hosts gestionados de una forma muy sencilla.

* Asegúrate de que has hecho login correctamente en tu cuenta de Azure y que has activado la subscripción sobre la que quieres trabajar

```
az login
az account list --output table
```

* Crea un *resource group* para gestionar los contenedores que lances:

```
az group create --name contdemo --location westeurope
```

* Lanza el contenedor:

```
az container create -g contdemo --name riversong --image ciberado/riversong:port80 --ip-address public
```

* Revisa los logs de creación para asegurarte de que todo ha ido bien

```
az container logs --resource-group contdemo --name riversong
```

* Recupera la IP asignada y visítala:

```
az container list --output table
```

* Elimina los recursos creados:

```
az group delete --name contdemo
```










## Conclusiones

¡Enhorabuena! Ya puedes imaginarte cómo de fácil es dockerizar distintas herramientas, desde *grunt* a distintas versiones del runtime de *nodejs*. Y sí, también puedes dockerizar docker. Pero esa historia la contaremos otro día.








