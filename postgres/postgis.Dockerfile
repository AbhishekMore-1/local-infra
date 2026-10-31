# pg_partman.Dockerfile on a PostGIS base. postgis/postgis is amd64-only;
# imresamu/postgis is the multi-arch build from a docker-postgis maintainer,
# built on postgres:17-alpine.
FROM imresamu/postgis:17-3.5-alpine AS builder
# Trust a TLS-intercepting corporate root CA (e.g. Zscaler) when one is passed
# as the optional `corp_ca` build secret (env CORP_CA_PEM, see README.md).
RUN --mount=type=secret,id=corp_ca,required=false \
    if [ -s /run/secrets/corp_ca ]; then \
        cp /run/secrets/corp_ca /usr/local/share/ca-certificates/corp-ca.crt \
        && cat /run/secrets/corp_ca >> /etc/ssl/certs/ca-certificates.crt; \
    fi
# Install dependencies
RUN /bin/sh -c set -ex \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates tar make gcc $DOCKER_PG_LLVM_DEPS
# Install pg_partman
ENV PG_PARTMAN_VERSION=v5.2.4
RUN /bin/sh -c set -ex \
    && mkdir -p /usr/src/pg_partman \
    && cd /usr/src/pg_partman \
    && wget -O pg_partman.tar.gz "https://github.com/pgpartman/pg_partman/archive/$PG_PARTMAN_VERSION.tar.gz" \
    && tar --extract --file pg_partman.tar.gz --directory /usr/src/pg_partman --strip-components 1 \
    && make && make install
# Install pg_cron
ENV PG_CRON_VERSION=v1.6.5
RUN /bin/sh -c set -ex \
    && mkdir -p /usr/src/pg_cron \
    && cd /usr/src/pg_cron \
    && wget -O pg_cron.tar.gz "https://github.com/citusdata/pg_cron/archive/$PG_CRON_VERSION.tar.gz" \
    && tar --extract --file pg_cron.tar.gz --directory /usr/src/pg_cron --strip-components 1 \
    && make && make install
# Configure PostgreSQL
RUN echo "shared_preload_libraries = 'pg_cron'" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "cron.database_name = 'postgres'" >> /usr/local/share/postgresql/postgresql.conf.sample

FROM imresamu/postgis:17-3.5-alpine AS final

# Copy pg_partman from builder
COPY --from=builder /usr/local/lib/postgresql/pg_partman_bgw.so /usr/local/lib/postgresql/pg_partman_bgw.so
COPY --from=builder /usr/local/share/postgresql/extension/pg_partman--*.sql /usr/local/share/postgresql/extension/
COPY --from=builder /usr/local/share/postgresql/extension/pg_partman.control /usr/local/share/postgresql/extension/pg_partman.control
# Copy pg_cron from builder
COPY --from=builder /usr/local/lib/postgresql/pg_cron.so /usr/local/lib/postgresql/pg_cron.so
COPY --from=builder /usr/local/share/postgresql/extension/pg_cron--*.sql /usr/local/share/postgresql/extension/
COPY --from=builder /usr/local/share/postgresql/extension/pg_cron.control /usr/local/share/postgresql/extension/pg_cron.control
# Copy modified postgresql.conf.sample
COPY --from=builder /usr/local/share/postgresql/postgresql.conf.sample /usr/local/share/postgresql/postgresql.conf.sample