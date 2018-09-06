#!/bin/sh

mysql_install_db --user=root

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"secret"}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}
MYSQL_USER=${MYSQL_USER:-""}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"secret"}

if [ ! -d "/run/mysqld" ]; then
  mkdir -p /run/mysqld
fi

setup_sql=`mktemp`

if [ ! -f "$setup_sql" ]; then
  return 1
fi

cat << EOF > $setup_sql
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
EOF

if [ "$MYSQL_DATABASE" != "" ]; then
  echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $setup_sql
  if [ "$MYSQL_USER" != "" ]; then
    echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $setup_sql
    echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $setup_sql
  fi
fi

echo "FLUSH PRIVILEGES;" >> $setup_sql

/usr/bin/mysqld --user=root --bootstrap --verbose=0 < $setup_sql && rm -f $setup_sql

exec /usr/bin/mysqld --user=root --console