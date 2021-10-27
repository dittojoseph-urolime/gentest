FROM python:3.7-alpine

COPY . /app

WORKDIR /app

RUN addgroup -S sasquatch

RUN adduser -S sasquatch -G sasquatch

COPY --chown=sasquatch:sasquatch requirements.txt requirements.txt index.py


RUN pip install -r requirements.txt



ENV APACHE_RUN_USER www-data

ENV APACHE_RUN_GROUP www-data

ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

USER sasquatch

CMD python ./index.py
