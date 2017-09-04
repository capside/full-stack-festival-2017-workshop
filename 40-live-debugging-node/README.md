# Docker para programadores NodeJS

## Aprenderás a...

* Lanzar aplicaciones node dentro de un contenedor
* Depurar desde chrome aplicaciones contenerizadas
* Crear un workflow de trabajo eficiente 

## Requisitos

* Docker 
* Chrome
* Te será útil sustituir en este documento la expresión `<local-folder>` por tu carpeta de trabajo, por ejemplo `/c/workshop` en Windows o `$HOME/workshop` en Mac/Linux.

## Ejecutando node en contenedor

* Lanza `node:alpine` para comprobar lo sencillo que es utilizar Nodejs con Docker:

```
docker run --rm -it node:alpine
> console.log('Hola mundo!');
> .exit
```

## Creación del proyecto

* Utilizando tu veneno preferido crea una carpeta de trabajo (por ejemplo `/workshop`) y añade el fichero `riversong.js` con el siguiente contenido en ella:

```
var http = require('http'),
    os = require('os');

var ifaces = os.networkInterfaces();
var identity = '';
Object.keys(ifaces).forEach(function (ifname) {
  ifaces[ifname].forEach(function (iface) {
    if ('IPv4' !== iface.family || iface.internal !== false) return;
    identity = identity + '[' + (iface.address) + '] ';
  });
});

var server = http.createServer(function (request, response) {
  response.writeHead(200, {'Content-Type': 'application/json'});
  var content = {
      name : 'Dr River Song!',
      photo: 'https://upload.wikimedia.org/wikipedia/en/3/3f/River_Song_Doctor_Who.png',
      position: 'Archaeologist',
      message : 'I hate you.',
      identity: identity
  };

  response.end(JSON.stringify(content));
});

server.listen(80);

console.log('Riversong initialized on port 80.');
```

## Ejecuta el proyecto en un contenedor

* Lanza un contenedor con la aplicación y comprueba que puedes acceder a ella desde tu navegador. Recuerda que tienes que sustituir <local-folder> por la carpeta en la que has creado el fichero (¿`/workshop`?) y que mientras que la primera aparición de la palabra *node* hace referencia al nombre de la imagen en el Docker Hub la segunda se refiere al comando que quieres ejecutar en el contenedor

```
docker run --rm --detach --publish 80:80 -w=/app --volume <local-folder>:/app node:alpine node riversong.js
```

* Check the application with your browser opening `localhost:80`. Kill the container after that with `docker kill <container-id>`.

## Remote debugging

* Use the flag `--inspect` in order to activate remote debugging (default port is `9229`)

```
docker run --rm -it --publish 80:80 --publish 9229:9229 -w=/app --volume <local-folder>:/app node:alpine node --inspect=0.0.0.0:9229 riversong.js
```

* Open the address `about:inspect` on Chrome an press the `inspect` button:

![Remote debugger](media/10-chrome-inspect.png)

* Look for the `riversong.js` node on the left tree and use it to open the source code. Set a breakpoint in line 14.

![Creating a breakpoint](media/20-breakpoint.png)

* Invoke again the application. You will be able to step over or evaluate expressions in the Nodejs runtime running inside the container.

* You can now kill the container with `docker ps` and `docker kill <id>`.

## Automatic code reload

`nodemon` is a Nodejs wrapper that makes easy reloading the code. Just modify the source of your project an dtype `rs` in the `nodemon` console.

* Create this small script in a file called `debug.sh`:

```
#/bin/sh

npm install -g nodemon
nodemon --inspect=0.0.0.0:9229 riversong.js
```

* Launch it inside a new container:

```
docker run --rm -it --publish 9229:9229 --publish 80:80 -w/app --volume <local-folder>:/app node:alpine /bin/sh -c "/app/debug.sh" 
```

* Use your weapon of choose to modify the source code of the project (`riversong.js`). For example, change line number 16:

```
---
name : 'Dr River Song!',
+++
name : 'Dr River Song!!!!!!!!!!!!',
```

* Using the `nodemon` terminal type the reload command:

```
rs
```

* Check the new version, opening again the application with your browser: `http://localhost:80`

## Editing from Chrome

* Chrome has a very nice js editor. To activate it use RMB over the explorer (on the left part of the screeen) and select `Add folder to workspace`. After that look for the directory that contains your application and accept the permission granting requirement:

![Add to workspace](images/30-workspace.png)

![Select folder](images/40-allow.png)

![Accept disk access](images/50-allow.png)

* Now map the paths in the browser with the actual physical files. To do it press RMB over the `riversong.js` file and choose `Map to network resource`. Just accept the option provided by the browser.

![Map network resource](images/60-map.png)
 
![Accept mapping](images/70-accept-mapping.png)

## Dockerfile optimization

Downloading `nodemon` each time you launch your container is a slow process. Let's create an image already containing it.

* Create a new file named `Dockerfile-dev` in the working directory and paste this content on it:

```
FROM node:alpine
RUN npm install -g nodemon
COPY riversong.js .
EXPOSE 80
CMD ["nodemon", "--inspect=0.0.0.0:9229", "riversong.js"]
```

* Use the `build` command to create the new image:

```
docker build -t riversong:dev -f Dockerfile-dev . 
```

* Feel free to launch your dev environment using it:

```
docker run --rm -it --publish 9229:9229 --publish 80:80 -w/app --volume <local-folder>:/app riversong:dev
```

## Creating a production-ready version

* The production `Dockerfile` is even easier to write:

```
FROM node:alpine
COPY riversong.js .
EXPOSE 80 
CMD ["node", "riversong.js"]
```

* Build the new image and (optionally) push it to your public repo in the registry:

```
docker build -t <repo>/riversong:port80 .
docker push <repo>/riversong:port80
```




