FROM python:3.7-alpine

LABEL maintainer="sasquatch"

COPY . /app

WORKDIR /app

RUN pip install -r requirements.txt

RUN addgroup -S sasquatch

RUN adduser -S sasquatch -G sasquatch

RUN chown sasquatch:sasquatch -R /app/

ENV APACHE_RUN_USER www-data

ENV APACHE_RUN_GROUP www-data

ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

USER sasquatch

CMD python ./index.py
