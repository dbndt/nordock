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

RUN apk update
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

RUN python3 -m venv ${INVENTREE_HOME}/env
ENV PATH="${INVENTREE_HOME}/bin:$PATH"

COPY requirements.txt ${INVENTREE_HOME}/requirements.txt

RUN pip install --upgrade pip setuptools wheel
RUN pip install --user -r requirements.txt
RUN pip install --no-cache-dir --user invoke
RUN pip install --no-cache-dir --user psycopg2 mysqlclient pgcli
RUN pip install --no-cache-dir --user gunicorn


FROM base as production

#add group
RUN addgroup -S inventreegroup && adduser -S inventree -G inventreegroup
USER inventree
WORKDIR $INVENTREE_HOME

COPY --from=base --chown=inventree:inventreegroup ${INVENTREE_HOME}/env ${INVENTREE_HOME}/env
ENV PATH="${INVENTREE_HOME}/bin:$PATH"
# Ownership
COPY --chown=inventree:inventreegroup . ${INVENTREE_HOME}

LABEL maintainer="DebianDocker dbndtdb@gmail.com" \
      version="1.0.0"

# COPY --chown=inventree:inventreegroup gunicorn.conf.py ${INVENTREE_HOME}/gunicorn.conf.py

# COPY start_prod_server.sh ${INVENTREE_HOME}/start_prod_server.sh
# COPY start_prod_worker.sh ${INVENTREE_HOME}/start_prod_worker.sh

RUN chmod 755 ${INVENTREE_HOME}/start_prod_server.sh
RUN chmod 755 ${INVENTREE_HOME}/start_prod_worker.sh

# Let us begin
USER inventree
CMD ["bash", "./start_prod_server.sh"]