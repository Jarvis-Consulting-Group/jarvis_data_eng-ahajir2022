#! /bin/sh

# capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start docker and check its status
sudo systemctl status docker || systemctl start docker

# check container status
docker container inspect jrvs-psql
container_status=$?

# Use switch case to handle create|stop|start options
case $cmd in 
  create)
  
  # Check if the container is already created
  if [ $container_status -eq 0 ]; then
    echo 'Container already exists'
    exit 1	
  fi

  # check # of CLI arguments
  if [ $# -ne 3 ]; then
    echo 'Create requires username and password'
    exit 1
  fi
  
  # Create container and start it
  docker volume create pgdata
  docker run --name jrvs-psql -e POSTGRES_PASSWORD="$db_password" \
  -e POSTGRES_USER="$db_username" -d -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 postgres
  exit $?
  ;;

  start|stop) 
  # check instance status and exit 1 if container has not been created
  if [ $container_status -ne 0 ]; then
    echo 'Container has not been created'
    exit 1
  fi

  # start or stop the container
  docker container $cmd jrvs-psql
  exit $?
  ;;	
  
  *)
  echo 'Illegal command'
  echo 'Commands: start|stop|create'
  exit 1
  ;;
esac
