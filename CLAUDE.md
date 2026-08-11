# DataScience-Docker

Entorno reproducible de desarrollo para proyectos de Ciencia de Datos con
Python 3.13, Poetry, Docker y JupyterLab.

## Stack y comandos

- `Dockerfile.dev` construye la imagen de desarrollo.
- `docker-compose.yml` ejecuta el contenedor `datascience` y monta el repo en
  `/workspace`.
- `pyproject.toml` es la fuente de verdad para dependencias y configuración de
  pytest.
- `pytest -q` ejecuta la suite local; el flujo soportado debe ejecutarse dentro
  de Docker cuando sea posible.
- `docker compose build` construye la imagen.
- `make test` ejecuta los tests en Docker.
- `make notebook` inicia JupyterLab en el puerto `8888`.
- `make help` lista todos los comandos disponibles.

## Reglas de trabajo

- Mantener Docker como el camino reproducible para desarrollo y validación.
- Escribir o actualizar el test antes de implementar un cambio funcional.
- Ejecutar la suite completa después de cada cambio relevante.
- Mantener `pyproject.toml` y la documentación sincronizados con Python 3.13.
- No introducir capas, abstracciones o servicios que el entorno de un solo
  módulo no necesite; documentar cualquier excepción deliberada.
- No agregar credenciales reales. `.env` es local y está ignorado; los ejemplos
  versionados no deben contener secretos.
- No hacer push a `main` sin confirmación explícita. Los cambios de código
  deben llegar mediante una rama y un Pull Request.
- Usar las skills de `.claude/skills/` cuando la tarea corresponda:
  `spec-driven-dev`, `user-stories`, `testing`, `trivy-scan`, `sonar-check` o
  `commit-writer`.

## Antes de un Pull Request

- Confirmar que los tests pasan dentro de Docker.
- Revisar que no se incluyan `.env`, caches, notebooks generados ni secretos.
- Verificar que el README y los comandos documentados siguen funcionando.
- Revisar el diff completo y explicar cualquier limitación conocida.
- Usar un mensaje de commit consistente con el historial del proyecto.

## Alcance arquitectónico

Este repositorio es deliberadamente un entorno de desarrollo plano: contiene
un contenedor, notebooks y módulos de Ciencia de Datos. No introducir una
arquitectura hexagonal ni servicios separados hasta que exista una necesidad
real que exceda este alcance.
