FROM python:3.10.11
RUN mkdir workspace
WORKDIR /workspace
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean
RUN pip install "poetry"
RUN poetry config virtualenvs.create false
COPY . .
ENV PYTHONPATH "${PYTHONPATH}:/workspace/src"
RUN poetry install
RUN rm -R *
