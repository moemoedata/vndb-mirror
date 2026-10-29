# .profile for devuser, used within Docker
export VNDB_VAR=/vndb/docker/var
export VNDB_GEN=/vndb/docker/gen

# Since this file is overwritten every time the docker image is ran, create an extension point here
[ -e "$VNDB_VAR/.profile" ] && source "$VNDB_VAR/.profile"

# Default start location
cd /vndb
