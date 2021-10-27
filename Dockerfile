FROM python:3.7-alpine

LABEL maintainer="sasquatch"

COPY . /app

WORKDIR /app

RUN pip install -r requirements.txt



ENV APACHE_RUN_USER www-data

ENV APACHE_RUN_GROUP www-data

ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80


CMD python ./index.py
