#!/bin/bash

# Start Spring Boot Application
./gradlew bootRun &

# until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
#     echo "Hello from loop"
#     sleep 1
# done

while ! curl --output /dev/null --silent --head --fail http://localhost:8080; do
    echo "Hello from loop"
    sleep 1
done

echo "Hello from Spring Boot"
