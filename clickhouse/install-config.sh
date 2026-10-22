#!/usr/bin/env bash
#
# Generates ClickHouse server config.d overrides in /etc/clickhouse-server/config.d
# Mirrors the files tracked in clickhouse/clickhouse-conf.d.
#
set -euo pipefail

DEST="${DEST:-/etc/clickhouse-server/config.d}"

# Create the target directory (needs root for the default path).
mkdir -p "$DEST"

write() {
    local name="$1"
    cat > "$DEST/$name"
    echo "wrote $DEST/$name"
}

write listen.xml <<'EOF'
<clickhouse>
    <listen_host>0.0.0.0</listen_host>
</clickhouse>
EOF

write loger_level.xml <<'EOF'
<clickhouse>
    <logger>
        <level>information</level>
    </logger>
</clickhouse>
EOF

write asynchronous_metric_log.xml <<'EOF'
<clickhouse>
    <asynchronous_metric_log>
        <database>system</database>
        <table>asynchronous_metric_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </asynchronous_metric_log>
</clickhouse>
EOF

write metric_log.xml <<'EOF'
<clickhouse>
    <metric_log>
        <database>system</database>
        <table>metric_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </metric_log>
</clickhouse>
EOF

write part_log.xml <<'EOF'
<clickhouse>
    <part_log>
        <database>system</database>
        <table>part_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </part_log>
</clickhouse>
EOF

write query_log.xml <<'EOF'
<clickhouse>
    <query_log>
        <database>system</database>
        <table>query_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </query_log>
</clickhouse>
EOF

write query_views_log.xml <<'EOF'
<clickhouse>
    <query_views_log>
        <database>system</database>
        <table>query_views_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </query_views_log>
</clickhouse>
EOF

write trace_log.xml <<'EOF'
<clickhouse>
    <trace_log>
        <database>system</database>
        <table>trace_log</table>
        <ttl>event_date + INTERVAL 2 DAY DELETE</ttl>
    </trace_log>
</clickhouse>
EOF

echo "Done. Config written to $DEST"
