# DataScience-Docker

Entorno reproducible de desarrollo para Ciencia de Datos con Python 3.13, Poetry, Docker y JupyterLab.

## Overview rapido

1. Instalar Docker (o Python 3.13 + Poetry + make si vas por la via local) -- ver [Instalacion de las herramientas](#instalacion-de-las-herramientas).
2. Clonar el repositorio.
3. `make build`
4. `make up-d`
5. `make notebook` -- abri [http://localhost:8888](http://localhost:8888).

Con eso ya tenes el entorno levantado y JupyterLab disponible para trabajar sobre `notebooks/`. Para mas detalle de cada paso, o para la via local sin Docker, ver las secciones siguientes.

## Requisitos previos

Elegi una de las dos formas de trabajar:

- **Con Docker (recomendado):** Docker y Docker Compose.
- **Local (sin Docker):** Python 3.13, [Poetry](https://python-poetry.org/docs/#installation) y `make`.

### Instalacion de las herramientas

**Docker**
- Linux: https://docs.docker.com/engine/install/
- Windows: https://docs.docker.com/desktop/setup/install/windows-install/

**Poetry**
- Linux: https://python-poetry.org/docs/#installing-with-the-official-installer
- Windows: https://python-poetry.org/docs/#installing-with-the-official-installer

**Make**
- Linux: viene preinstalado en la mayoria de las distros, o se instala via el gestor de paquetes (ej. `apt install make`, `dnf install make`).
- Windows: https://community.chocolatey.org/packages/make (via Chocolatey) o https://gnuwin32.sourceforge.net/packages/make.htm

## Configuracion del entorno

### Opcion A: con Docker

1. Clonar el repositorio y ubicarte en la raiz del proyecto.
2. (Opcional) Crear un archivo `.env` en la raiz si necesitas definir variables de entorno. No es obligatorio.
3. Construir la imagen:
   ```bash
   make build
   ```
4. Levantar los servicios:
   ```bash
   make up
   ```
   o en background:
   ```bash
   make up-d
   ```
5. Levantar JupyterLab:
   ```bash
   make notebook
   ```
   Esto expone JupyterLab en [http://localhost:8888](http://localhost:8888), sin token (ver nota de seguridad mas abajo).
6. Para bajar los servicios:
   ```bash
   make down
   ```

> **Nota de seguridad:** `make notebook` (y `make notebook-local`) levantan JupyterLab sin token ni password, para simplificar la configuracion en local. Es un trade-off aceptable para un entorno de desarrollo local, pero no deberia usarse asi en un servidor expuesto a una red compartida o publica.

### Opcion B: local con Poetry

1. Clonar el repositorio y ubicarte en la raiz del proyecto.
2. Instalar las dependencias:
   ```bash
   make install
   ```
   (equivale a `poetry install`)
3. Trabajar con los notebooks usando Jupyter dentro del entorno de Poetry:
   ```bash
   make notebook-local
   ```

> Para ver todos los comandos disponibles (incluyendo los de testing y linting), correr `make help`.

## Trabajar con los notebooks en VSCode

1. Instalar las extensiones de VSCode:
   - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
   - [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
2. Seleccionar el kernel, segun la opcion de entorno que hayas elegido:
   - **Local con Poetry:** con las dependencias ya instaladas (`make install`), abri cualquier notebook de `notebooks/`, hace clic en **Select Kernel** y elegi el entorno de Poetry del proyecto. Si no aparece en la lista, obtene la ruta del interprete con:
     ```bash
     poetry env info --path
     ```
     y agregala manualmente con **Select Kernel -> Select Another Kernel -> Enter interpreter path...**.
   - **Con Docker:** levanta JupyterLab con `make notebook`. En VSCode, abri la paleta de comandos (`Ctrl+Shift+P` / `Cmd+Shift+P`) y ejecuta **Jupyter: Specify Jupyter Server for Connections**, indicando `http://localhost:8888` (el server corre sin token). Luego selecciona ese servidor como kernel del notebook.
3. Abri el notebook (`.ipynb`) que quieras trabajar dentro de `notebooks/` y corre las celdas normalmente.

## Agregando nuevas dependencias

Para agregar bibliotecas al entorno:

1. Asegurate de que el contenedor este corriendo (`make up-d`).
2. Ejecuta poetry add dentro del contenedor:
   ```bash
   docker compose exec datascience poetry add seaborn
   ```
3. Reconstrui la imagen para que los cambios persistan:
   ```bash
   make build
   ```

## Estructura del repositorio

```
.
├── notebooks/           # Notebooks de Jupyter
├── src/                 # Codigo fuente del proyecto
├── tests/               # Tests automatizados
├── pyproject.toml       # Dependencias del proyecto (Poetry)
├── poetry.lock
├── Dockerfile.dev
├── docker-compose.yml
├── Makefile             # Comandos del flujo de trabajo (make help)
└── .dockerignore
```

## Variables de entorno

- A nivel de repositorio, el `.env` en la raiz es opcional y solo lo usa `docker-compose.yml`.
- Si necesitas definir variables, copia `.env_example` a `.env` y ajusta los valores.

## Enlaces de Interes

- **Poetry**: [Sitio oficial de Poetry](https://python-poetry.org/)
- **JupyterLab**: [Documentacion de JupyterLab](https://jupyterlab.readthedocs.io/)
