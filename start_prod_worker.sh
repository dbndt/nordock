#!/bin/sh

echo "Starting InvenTree worker..."

sleep 5

# Wait for the database to be ready
cd $INVENTREE_HOME
python3 manage.py wait_for_db

sleep 10

# Now we can launch the background worker process
python3 manage.py qcluster