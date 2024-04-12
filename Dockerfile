FROM python:3.10.11
RUN mkdir workspace
WORKDIR /workspace
RUN pip install "poetry"
RUN poetry config virtualenvs.create false
COPY . .
ENV PYTHONPATH "${PYTHONPATH}:/workspace/src"
RUN poetry install
RUN rm -R *
