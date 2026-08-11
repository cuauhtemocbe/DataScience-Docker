.DEFAULT_GOAL := help
.PHONY: help build up up-d down logs test test-v lint format-check typecheck lock-check notebook install-hooks install notebook-local test-local lint-local

# --- Docker (flujo principal) ---

build: ## Construir la imagen de desarrollo
	docker compose build

up: ## Levantar el servicio en foreground (con logs)
	docker compose up

up-d: ## Levantar el servicio en background
	docker compose up -d --wait

down: ## Bajar el servicio
	docker compose down

logs: ## Seguir los logs del servicio datascience
	docker compose logs -f datascience

test: up-d ## Correr la suite de tests dentro de Docker
	docker compose exec datascience pytest tests/ -v

test-v: up-d ## Correr los tests en modo verbose dentro de Docker
	docker compose exec datascience pytest tests/ -v

lint: up-d ## Correr ruff check dentro de Docker
	docker compose exec datascience ruff check src/ tests/

format-check: up-d ## Verificar formato con ruff dentro de Docker (sin modificar archivos)
	docker compose exec datascience ruff format --check src/ tests/

typecheck: up-d ## Correr mypy dentro de Docker
	docker compose exec datascience mypy src/ tests/

lock-check: up-d ## Verificar que poetry.lock esté sincronizado con pyproject.toml
	docker compose exec datascience poetry check --lock

notebook: up-d ## Levantar JupyterLab dentro de Docker (http://localhost:8888)
	docker compose exec datascience jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/workspace/notebooks --ServerApp.token='' --ServerApp.password='' --ServerApp.disable_check_xsrf=True

install-hooks: ## Habilitar el git hook de pre-commit (lint + format, corre en Docker)
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit

# --- Local (opcional: fallback sin Docker, requiere Python 3.13 y Poetry) ---

install: ## [local] Instalar dependencias con poetry
	poetry install

notebook-local: ## [local] Levantar JupyterLab con poetry
	poetry run jupyter lab --notebook-dir=notebooks --ServerApp.token='' --ServerApp.password='' --ServerApp.disable_check_xsrf=True

test-local: ## [local] Correr tests con poetry
	poetry run pytest tests/ -v

lint-local: ## [local] Correr ruff check con poetry
	poetry run ruff check src/ tests/

help: ## Mostrar esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
