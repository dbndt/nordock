#!/bin/sh

if test -f "$INVENTREE_CONFIG_FILE"; then
    echo "$INVENTREE_CONFIG_FILE exists - skipping"
else
    echo "Copying config file to $INVENTREE_CONFIG_FILE"
    cp $INVENTREE_SRC_DIR/InvenTree/config_template.yaml $INVENTREE_CONFIG_FILE
fi

echo "Starting InvenTree server..."

# Wait for the database to be ready
cd $INVENTREE_MNG_DIR
python manage.py wait_for_db

sleep 10

echo "Running InvenTree database migrations and collecting static files..."

# We assume at this stage that the database is up and running
# Ensure that the database schema are up to date
python manage.py check || exit 1
python manage.py migrate --noinput || exit 1
python manage.py migrate --run-syncdb || exit 1
python manage.py prerender || exit 1
python manage.py collectstatic --noinput || exit 1
python manage.py clearsessions || exit 1

# Now we can launch the server
gunicorn -c gunicorn.conf.py InvenTree.wsgi -b 0.0.0.0:$INVENTREE_WEB_PORT

