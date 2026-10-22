#!/usr/bin/env bash
#
# Generates ClickHouse server users.d overrides in /etc/clickhouse-server/users.d
# Mirrors the files tracked in clickhouse/clickhouse-users.d.
#
set -euo pipefail

DEST="${DEST:-/etc/clickhouse-server/users.d}"

# Create the target directory (needs root for the default path).
mkdir -p "$DEST"

write() {
    local name="$1"
    cat > "$DEST/$name"
    echo "wrote $DEST/$name"
}

write async_inserts.xml <<'EOF'
<clickhouse>
    <profiles>
        <default>
            <async_insert>1</async_insert>
            <async_insert_busy_timeout_ms>1000</async_insert_busy_timeout_ms>
        </default>
    </profiles>
</clickhouse>
EOF

write default-password.xml <<'EOF'
<clickhouse>
    <users>
        <default>
            <password remove='1' />
            <password_sha256_hex>c8030e335de34a1d4528bad671ab90c8f6f9c8bcd37a9848ce272a0d4a25d3aa</password_sha256_hex> <!-- fampay -->
        </default>
    </users>
</clickhouse>
EOF

write max_execution.xml <<'EOF'
<clickhouse>
  <profiles>
    <default>
      <max_execution_time>5</max_execution_time>
    </default>
  </profiles>
</clickhouse>
EOF

echo "Done. Users config written to $DEST"
