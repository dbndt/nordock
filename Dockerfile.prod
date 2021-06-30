###########
# BUILDER #
###########

# pull official base image
FROM python:3.8.3-alpine as builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update 

# Delete build dependencies
RUN apk update && \
    apk add --virtual .build-deps gcc build-base libgcc g++ libstdc++ python3 python3-dev musl-dev && \
    apk add postgresql-dev && \
    apk add netcat-openbsd git make bash \
    libjpeg-turbo libjpeg-turbo-dev jpeg jpeg-dev \
    libffi libffi-dev \
    zlib zlib-dev

RUN apk add --no-cache cairo cairo-dev pango pango-dev
RUN apk add --no-cache fontconfig ttf-droid ttf-liberation ttf-dejavu ttf-opensans ttf-ubuntu-font-family font-croscore font-noto

RUN apk update \
    && apk add --no-cache postgresql postgresql-contrib postgresql-dev

# lint



RUN pip install --upgrade -U pip setuptools wheel
RUN pip install --no-cache-dir -U invoke
RUN pip install --no-cache-dir -U psycopg2 pgcli
RUN pip install --no-cache-dir -U gunicorn



# install dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt



#########
# FINAL #
#########

# pull official base image
FROM builder as production

# create directory for the app user
RUN mkdir -p /home/inventree

# create the app user
RUN addgroup -S inventreegroup && adduser -S inventree -G inventreegroup

ENV INVENTREE_HOME="/home/inventree"

ENV INVENTREE_LOG_LEVEL="INFO"
ENV INVENTREE_DOCKER="true"


# InvenTree paths
ENV INVENTREE_SRC_DIR="${INVENTREE_HOME}/src"
ENV INVENTREE_MNG_DIR="${INVENTREE_HOME}/InvenTree"
ENV INVENTREE_DATA_DIR="${INVENTREE_HOME}/data"
ENV INVENTREE_STATIC_ROOT="${INVENTREE_DATA_DIR}/static"
ENV INVENTREE_MEDIA_ROOT="${INVENTREE_DATA_DIR}/media"

ENV INVENTREE_CONFIG_FILE="${INVENTREE_DATA_DIR}/config.yaml"
ENV INVENTREE_SECRET_KEY_FILE="${INVENTREE_DATA_DIR}/secret_key.txt"
# create the appropriate directories
# ENV HOME=/home/app
# ENV APP_HOME=/home/app/web
# RUN mkdir $APP_HOME
# RUN mkdir $APP_HOME/staticfiles
# RUN mkdir $APP_HOME/mediafiles
WORKDIR ${INVENTREE_HOME}
RUN mkdir ${INVENTREE_SRC_DIR}
RUN mkdir ${INVENTREE_MNG_DIR}
RUN mkdir ${INVENTREE_DATA_DIR}
RUN mkdir ${INVENTREE_STATIC_ROOT}
RUN mkdir ${INVENTREE_MEDIA_ROOT}

# install dependencies
RUN apk update && apk add libpq
RUN apk add --no-cache cairo cairo-dev pango pango-dev
# RUN apk add --no-cache fontconfig ttf-droid ttf-liberation ttf-dejavu ttf-opensans ttf-ubuntu-font-family font-croscore font-noto

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache /wheels/*

RUN apk del .build-deps
# copy entrypoint-prod.sh
COPY ./entrypoint.prod.sh $INVENTREE_MNG_DIR

WORKDIR ${INVENTREE_MNG_DIR}
# copy project
COPY . .

# # chown all the files to the app user
# RUN chown -R inventree:inventree $INVENTREE_HOME

# # change to the app user
# USER inventree

# run entrypoint.prod.sh
CMD ["bash", "./entrypoint.prod.sh"]
