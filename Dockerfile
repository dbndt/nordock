FROM alpine:3.13 as base

ENV PYTHONUNBUFFERED 1

# InvenTree key settings

# The INVENTREE_HOME directory is where the InvenTree source repository will be located
ENV INVENTREE_HOME="/home/inventree"

# GitHub settings
# ENV INVENTREE_REPO="${repository}"
# ENV INVENTREE_BRANCH="${branch}"

ENV INVENTREE_LOG_LEVEL="INFO"
ENV INVENTREE_DOCKER="true"

# InvenTree paths
ENV INVENTREE_MNG_DIR="${INVENTREE_HOME}/InvenTree"
ENV INVENTREE_DATA_DIR="${INVENTREE_HOME}/data"
ENV INVENTREE_STATIC_ROOT="${INVENTREE_DATA_DIR}/static"
ENV INVENTREE_MEDIA_ROOT="${INVENTREE_DATA_DIR}/media"

ENV INVENTREE_CONFIG_FILE="${INVENTREE_DATA_DIR}/config.yaml"
ENV INVENTREE_SECRET_KEY_FILE="${INVENTREE_DATA_DIR}/secret_key.txt"

# Default web server port is 8000
ENV INVENTREE_WEB_PORT="8000"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${DATE} \
      org.label-schema.vendor="debian" \
      org.label-schema.name="nordock" 

# Create user account
# RUN addgroup --gid 1024 inventreegroup
# RUN adduser --disabled-password --gecos "" --force-badname --ingroup 1024 inventree
# USER inventree
RUN addgroup -S inventreegroup && adduser -S inventree -G inventreegroup

WORKDIR ${INVENTREE_HOME}

# Install required system packages
RUN apk add --no-cache git make bash \
    gcc libgcc g++ libstdc++ \
    libjpeg-turbo libjpeg-turbo-dev jpeg jpeg-dev \
    libffi libffi-dev \
    zlib zlib-dev

# Cairo deps for WeasyPrint (these will be deprecated once WeasyPrint drops cairo requirement)
RUN apk add --no-cache cairo cairo-dev pango pango-dev
RUN apk add --no-cache fontconfig ttf-droid ttf-liberation ttf-dejavu ttf-opensans ttf-ubuntu-font-family font-croscore font-noto

# Python
RUN apk add --no-cache python3 python3-dev py3-pip

# SQLite support
RUN apk add --no-cache sqlite

# PostgreSQL support
RUN apk add --no-cache postgresql postgresql-contrib postgresql-dev libpq

# MySQL support
RUN apk add --no-cache mariadb-connector-c mariadb-dev mariadb-client

# Install required python packages
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -U invoke
RUN pip install --no-cache-dir -U psycopg2 mysqlclient pgcli mariadb
RUN pip install --no-cache-dir -U gunicorn

FROM base as production
# Clone source code
RUN echo "Copying dd filez from .. "
COPY . .

# Install InvenTree packages
RUN pip install --no-cache-dir -U -r ${INVENTREE_HOME}/requirements.txt

# Copy gunicorn config file
COPY gunicorn.conf.py ${INVENTREE_HOME}/gunicorn.conf.py

# Copy startup scripts
COPY start_prod_server.sh ${INVENTREE_HOME}/start_prod_server.sh
COPY start_prod_worker.sh ${INVENTREE_HOME}/start_prod_worker.sh

RUN chmod 755 ${INVENTREE_HOME}/start_prod_server.sh
RUN chmod 755 ${INVENTREE_HOME}/start_prod_worker.sh

WORKDIR ${INVENTREE_HOME}

# Let us begin
CMD ["bash", "./start_prod_server.sh"]

