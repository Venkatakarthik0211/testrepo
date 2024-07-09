#!/bin/bash

# Run MySQL container with specified root password
docker run --name my_sql_container -e MYSQL_ROOT_PASSWORD=root1234 -d -p 3306:3306 mysql/mysql-server

# Wait for MySQL to initialize (adjust this according to your MySQL server startup time)
echo "Waiting for MySQL to start..."
sleep 30

# Extract root password from Docker logs
MYSQL_ROOT_PASSWORD=$(docker logs my_sql_container 2>&1 | grep GENERATED | awk '{print $NF}')

echo "Root password extracted: $MYSQL_ROOT_PASSWORD"

# Connect to MySQL server inside the container
docker exec -it my_sql_container mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'root1234';
    CREATE USER 'master'@'%' IDENTIFIED BY 'master1234';
    GRANT ALL PRIVILEGES ON *.* TO 'master'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
"

echo "MySQL provisioned successfully!"

# Clean up
docker rm -f my_sql_container
