# Linux cluster monitoring agent (Linux and SQL)

The project aims to collect hardware usage data from multiple Linux hosts, store the data into a PostgreSQL database, and provide a way to query the data. This project can be used by system administrators to monitor and analyze the hardware usage of different hosts in a network.

## Technologies Used
The project uses the following technologies:
- Bash scripting for collecting hardware usage data and inserting it into the database.
- Docker for running a PostgreSQL database instance.
- SQL for creating tables and querying the data.
- Git for version control.

## Quick Start
To quickly get started with the project, follow the steps below:

1. Start a psql instance using psql_docker.sh:
    ```
    ./scripts/psql_docker.sh start|stop|create [db_username][db_password]
    ```

2. Create tables using ddl.sql:
    ```
    ./sql/ddl.sql
    ```

3. Insert hardware specs data into the database using host_info.sh:
    ```
    ./scripts/host_info.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
    ```

4. Insert hardware usage data into the database using host_usage.sh:
    ```
    ./scripts/host_usage.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
    ```

5. Set up crontab:
    ```
    * * * * * bash [path_to_scripts]/host_usage.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password] > /tmp/host_usage.log
    ```

## Implementation

### Architecture

![Net diagramIMG](https://user-images.githubusercontent.com/100779532/225756237-6fbe25ca-d332-480a-9fa5-5800bc8e496f.png)

The architecture of the project consists of three Linux hosts, a PostgreSQL database instance, and agents. Each Linux host runs an agent that collects hardware usage data and sends it to the database instance.

### Scripts

The following scripts are used in the project:

- psql_docker.sh: starts, stops, or creates a PostgreSQL Docker container:
  ``` 
  ./scripts/psql_docker.sh start|stop|create [db_username] [db_password]
  ```

- host_info.sh: collects hardware specs data and inserts it into the database:
  ```
  ./scripts/host_info.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
  ```

- host_usage.sh: collects hardware usage data and inserts it into the database:
  ``` 
  ./scripts/host_usage.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
  ```

- crontab: sets up a cron job to run host_usage.sh every minute.

- queries.sql: contains SQL queries to retrieve hardware usage data.

### Database Modeling
This table is called host_usage and it represents the usage data for a host at a specific timestamp. The host_id column is a foreign key referencing the id column of the host_info table. The other columns represent the following metrics:

| Column        | Data Type | Constraints                  |
| ------------- | ---------| ---------------------------- |
| timestamp     | TIMESTAMP| NOT NULL                     |
| host_id       | SERIAL   | NOT NULL, foreign key        |
| memory_free   | INT4     | NOT NULL                     |
| cpu_idle      | INT2     | NOT NULL                     |
| cpu_kernel    | INT2     | NOT NULL                     |
| disk_io       | INT4     | NOT NULL                     |
| disk_available| INT4     | NOT NULL                     |

The host_info table:

| Column | Data Type | Constraints |
|--------|----------|-------------|
| id | SERIAL | NOT NULL, primary key |
| hostname | VARCHAR | NOT NULL, unique |
| cpu_number | INT2 | NOT NULL |
| cpu_architecture | VARCHAR | NOT NULL |
| cpu_model | VARCHAR | NOT NULL |
| cpu_mhz | FLOAT8 | NOT NULL |
| l2_cache | INT4 | NOT NULL |
| timestamp | TIMESTAMP | NULL |
| total_mem | INT4 | NULL |

CONSTRAINT host_info_pk PRIMARY KEY (id)		
CONSTRAINT host_info_un UNIQUE (hostname)	
