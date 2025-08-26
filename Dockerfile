# syntax=docker/dockerfile:1
FROM mysql:8.4

ENV TZ=America/Sao_Paulo

RUN set -eux; \
    if command -v apt-get >/dev/null; then \
      apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates && rm -rf /var/lib/apt/lists/*; \
    elif command -v microdnf >/dev/null; then \
      microdnf install -y curl unzip ca-certificates && microdnf clean all; \
    elif command -v dnf >/dev/null; then \
      dnf install -y curl unzip ca-certificates && dnf clean all; \
    else \
      echo "Nenhum gerenciador de pacotes suportado encontrado" && exit 1; \
    fi

# Baixa Sakila, World e Employees
RUN set -eux; \
    mkdir -p /tmp/mysql-samples; \
    curl -L -o /tmp/mysql-samples/sakila-db.zip https://downloads.mysql.com/docs/sakila-db.zip; \
    unzip -j /tmp/mysql-samples/sakila-db.zip -d /docker-entrypoint-initdb.d; \
    mv /docker-entrypoint-initdb.d/sakila-schema.sql /docker-entrypoint-initdb.d/01_sakila_schema.sql; \
    mv /docker-entrypoint-initdb.d/sakila-data.sql   /docker-entrypoint-initdb.d/02_sakila_data.sql; \
    curl -L -o /tmp/mysql-samples/world-db.zip https://downloads.mysql.com/docs/world-db.zip; \
    unzip -j /tmp/mysql-samples/world-db.zip -d /docker-entrypoint-initdb.d; \
    mv /docker-entrypoint-initdb.d/world.sql /docker-entrypoint-initdb.d/03_world.sql; \
    curl -L -o /tmp/mysql-samples/employees.zip https://github.com/datacharmer/test_db/archive/refs/heads/master.zip; \
    unzip /tmp/mysql-samples/employees.zip -d /tmp/mysql-samples; \
    find /tmp/mysql-samples -name employees.sql -exec cp {} /docker-entrypoint-initdb.d/04_employees.sql \; ; \
    rm -rf /tmp/mysql-samples

EXPOSE 3306
