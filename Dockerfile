###########
# BUILDER #
###########

# pull official base image
FROM alpine:3.13 as base

# set work directory
# WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ENV INVENTREE_HOME="/home/inventree"

ENV INVENTREE_LOG_LEVEL="INFO"
ENV INVENTREE_DOCKER="true"

ENV INVENTREE_MNG_DIR="${INVENTREE_HOME}/InvenTree"
ENV INVENTREE_DATA_DIR="${INVENTREE_HOME}/data"
ENV INVENTREE_STATIC_ROOT="${INVENTREE_DATA_DIR}/static"
ENV INVENTREE_MEDIA_ROOT="${INVENTREE_DATA_DIR}/media"

ENV INVENTREE_CONFIG_FILE="${INVENTREE_DATA_DIR}/config.yaml"
ENV INVENTREE_SECRET_KEY_FILE="${INVENTREE_DATA_DIR}/secret_key.txt"

# Default web server port is 8000
ENV INVENTREE_WEB_PORT="8000"

# Delete build dependencies
RUN apk add --no-cache git make musl-dev bash \
    gcc libgcc g++ libstdc++ \
    libjpeg-turbo libjpeg-turbo-dev jpeg jpeg-dev \
    libffi libffi-dev \
    zlib zlib-dev

RUN apk add --no-cache cairo cairo-dev pango pango-dev
RUN apk add --no-cache fontconfig ttf-droid ttf-liberation ttf-dejavu ttf-opensans ttf-ubuntu-font-family font-croscore font-noto
RUN apk add --no-cache python3 python3-dev py3-pip
RUN apk add --no-cache postgresql postgresql-contrib postgresql-dev libpq
# lint
RUN apk add --no-cache sqlite

RUN apk add --no-cache mariadb-connector-c mariadb-dev mariadb-client


RUN pip install --upgrade pip setuptools wheel

RUN addgroup -S inventreegroup && adduser -S inventree -G inventreegroup
RUN apk update


RUN pip install --no-cache-dir invoke
RUN pip install --no-cache-dir psycopg2 mysqlclient pgcli
RUN pip install --no-cache-dir gunicorn


FROM base as production

WORKDIR ${INVENTREE_HOME}


COPY --chown=inventree:inventreegroup requirements.txt ${INVENTREE_HOME}/requirements.txt
RUN pip install --user -r requirements.txt

ENV PATH="/home/inventree/.local/bin:${PATH}"

COPY --chown=inventree:inventreegroup . .

COPY requirements.txt ${INVENTREE_HOME}/requirements.txt
RUN pip install --no-cache-dir -U -r ${INVENTREE_HOME}/requirements.txt

COPY --chown=inventree:inventreegroup gunicorn.conf.py ${INVENTREE_HOME}/gunicorn.conf.py


COPY start_prod_server.sh ${INVENTREE_HOME}/start_prod_server.sh
COPY start_prod_worker.sh ${INVENTREE_HOME}/start_prod_worker.sh

RUN chmod 755 ${INVENTREE_HOME}/start_prod_server.sh
RUN chmod 755 ${INVENTREE_HOME}/start_prod_worker.sh

WORKDIR ${INVENTREE_HOME}
USER inventree
# Let us begin
CMD ["bash", "./start_prod_server.sh"]