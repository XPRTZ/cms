#!/bin/sh

# URL encode both passwords for connection strings
ADMIN_URL_PASSWORD=$(printf %s "$ADMINPASSWORD" | od -An -tx1 | tr ' ' % | tr -d '\n')
STRAPI_URL_PASSWORD=$(printf %s "$STRAPIPASSWORD" | od -An -tx1 | tr ' ' % | tr -d '\n')

# For SQL, we need to escape single quotes by doubling them
SQL_ESCAPED_PASSWORD=$(printf %s "$STRAPIPASSWORD" | awk "{gsub(/'/,\"''\"); print}")

# Create the database
mysql -u root -p"$ADMINPASSWORD" -e "CREATE DATABASE IF NOT EXISTS $STRAPIDATABASENAME;"

# Create the user and grant privileges
mysql -u root -p"$ADMINPASSWORD" -e "CREATE USER IF NOT EXISTS '$STRAPIUSER'@'$SERVER' IDENTIFIED BY '$SQL_ESCAPED_PASSWORD';"
mysql -u root -p"$ADMINPASSWORD" -e "GRANT ALL PRIVILEGES ON $STRAPIDATABASENAME.* TO '$STRAPIUSER'@'$SERVER';"

# Flush privileges to ensure they are applied
mysql -u root -p"$ADMINPASSWORD" -e "FLUSH PRIVILEGES;"
