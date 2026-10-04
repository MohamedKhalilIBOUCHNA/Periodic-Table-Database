#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT=$(
  psql --username=freecodecamp --dbname=periodic_table \
    -X -t --no-align -F '|' -v ON_ERROR_STOP=1 \
    --set=input="$1" <<'SQL'
SELECT e.atomic_number, e.name, e.symbol, t.type,
       p.atomic_mass, p.melting_point_celsius,
       p.boiling_point_celsius
FROM elements AS e
JOIN properties AS p USING (atomic_number)
JOIN types AS t USING (type_id)
WHERE e.symbol = :'input'
   OR e.name = :'input'
   OR e.atomic_number::TEXT = :'input';
SQL
) || exit 1

if [[ -z "$ELEMENT" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT"

echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
