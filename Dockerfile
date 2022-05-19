FROM python:3.8-slim-buster

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY hello.py hello.py

ENV FLASK_APP=hello

EXPOSE 80

ENTRYPOINT [ "flask", "run", "-h", "0.0.0.0", "-p", "80" ]