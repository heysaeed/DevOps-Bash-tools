#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-03-12 16:40:27 +0000 (Thu, 12 Mar 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Lists all PostgreSQL schemas using adjacent psql.sh script
#
# FILTER environment variable will restrict to matching schemas (matches against fully qualified schema name <db>.<schema>)
#
# AUTOFILTER if set to any value skips information_schema and pg_catalog schemas
#
# Tested on AWS RDS PostgreSQL 9.5.15

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

"$srcdir/psql.sh" -q -t -c "SELECT DISTINCT table_catalog, table_schema FROM information_schema.tables ORDER BY table_catalog, table_schema;" "$@" |
sed 's/|//g; s/^[[:space:]]*//; s/[[:space:]]*$//; /^[[:space:]]*$/d' |
if [ -n "${AUTOFILTER:-}" ]; then
    grep -Ev '[[:space:]](information_schema|pg_catalog)$'
else
    cat
fi |
while read -r db schema; do
    if [ -n "${FILTER:-}" ] &&
       ! [[ "$db.$schema" =~ $FILTER ]]; then
        continue
    fi
    printf "%s\t%s\n" "$db" "$schema"
done
