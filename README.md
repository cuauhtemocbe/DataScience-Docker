## Acerca de este Repositorio

Este repositorio proporciona una configuración optimizada y lista para usar de un entorno de desarrollo para Python 3.10.11 enfocado en Ciencia de Datos. Utilizando Docker, facilita la creación de un ambiente aislado y reproducible, eliminando las complicaciones de la configuración manual.

### Características Principales:

- **Entorno Dockerizado**: Utiliza Docker para encapsular todas las dependencias y configuraciones necesarias, garantizando la portabilidad y consistencia del entorno de desarrollo.
  
- **Integración con Jupyter**: Incluye Jupyter Lab para el análisis interactivo de datos y la creación de documentos reproducibles. 

- **Gestión de Dependencias con Poetry**: Simplifica la gestión de bibliotecas y dependencias de Python con Poetry, facilitando la instalación, actualización y distribución de paquetes.

Este repositorio es ideal para aquellos que desean iniciar rápidamente proyectos de Ciencia de Datos sin preocuparse por la configuración del entorno. ¡Empieza a explorar y desarrollar tus ideas sin obstáculos!


## Requisitos Previos

Antes de comenzar, asegúrate de tener instalados los siguientes programas:

1. **Docker**: [Guía de instalación de Docker](https://docs.docker.com/engine/install/)
2. **Git**: [Guía de instalación de Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
3. **Visual Studio Code (VSC)**: [Descargar Visual Studio Code](https://code.visualstudio.com/download)

La instalación de Visual Studio Code es opcional, pero se recomienda especialmente si tienes experiencia programando. Si eres principiante, puedes optar por no instalarlo.

## Instrucciones de Instalación

### Clonar el Repositorio

1. Elige una ubicación en tu computadora para clonar el repositorio. Abre tu terminal y ejecuta el siguiente comando:

    ```bash
    git clone https://github.com/cuauhtemocbe/Dev-Containers-Template.git
    ```

    Este comando creará una carpeta llamada **Dev-Containers-Template** en tu máquina.

### Configuración con Visual Studio Code (Opción Avanzada)

Si prefieres usar Visual Studio Code para desarrollar o ejecutar los notebooks, sigue estos pasos:

1. Abre Visual Studio Code y selecciona `File > Open Folder`. Luego elige la carpeta **Dev-Containers-Template** para abrir el repositorio.
2. Instala la extensión **Dev Containers** desde el Marketplace de VSC.
3. Abre la Paleta de Comandos (Command Palette) con `Shift + Ctrl + P` y escribe `Dev Containers: Rebuild and Reopen in Container`. Ejecútalo para construir y levantar el contenedor Docker.
4. En el explorador de archivos (`Ctrl + Shift + E`), navega hasta la carpeta `notebooks` y abre el archivo `0. Validar-ambiente.ipynb`.
5. Ejecuta el notebook; al inicio te solicitará seleccionar un kernel, elige Python 3.10.11.

### Configuración con Jupyter Lab (Opción Sencilla)

Si prefieres utilizar Jupyter Lab con Docker, sigue estos pasos:

1. Desde la terminal, dentro de la carpeta **Dev-Containers-Template**, ejecuta el siguiente comando para construir y levantar el contenedor:

    ```bash
    docker compose up -d
    ```

2. Luego, ejecuta el siguiente comando para ingresar al contenedor y utilizar la terminal:

    ```bash
    docker exec -it Dev-Containers-Template bash
    ```

3. Dentro del contenedor, inicia el servicio de Jupyter Lab con el siguiente comando:

    ```bash
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
    ```

4. Finalmente, abre el siguiente enlace en tu navegador: [http://localhost:8888/lab/tree/notebooks](http://localhost:8888/lab/tree/notebooks)

## Agregando nuevas bibliotecas

Si deseas ampliar las capacidades de tu entorno de desarrollo añadiendo nuevas bibliotecas, sigue estos sencillos pasos:

1. Accede al contenedor ejecutando el siguiente comando en tu terminal:

    ```bash
    docker exec -it Dev-Containers-Template bash
    ```

2. Una vez dentro del contenedor, puedes utilizar Poetry para agregar nuevas bibliotecas. Por ejemplo, si deseas agregar la popular biblioteca de visualización de datos, seaborn, simplemente ejecuta:

    ```bash
    poetry add seaborn
    ```

Con estos pasos, podrás expandir rápidamente las funcionalidades de tu entorno de desarrollo para satisfacer tus necesidades específicas.

## Enlaces de Interés

- **Poetry**: [Sitio oficial de Poetry](https://python-poetry.org/)
