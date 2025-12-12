FROM postgres:17-alpine AS builder
# Install dependencies
RUN /bin/sh -c set -ex \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates tar make gcc clang19 llvm19
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

FROM postgres:17-alpine AS final

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