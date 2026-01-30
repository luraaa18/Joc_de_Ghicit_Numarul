#!/bin/bash

CLASAMENT="highscores.json"
STATISTICI="stats.txt"

touch "$STATISTICI"

if [[ ! -f "$CLASAMENT" || ! -s "$CLASAMENT" ]]; then
    echo "[]" > "$CLASAMENT"
fi

NIVEL="medium"
MAX_INCERCARI=10
MULTIPLAYER=false
NUMAR_JUCATORI=1
NUME_JUCATOR="$USER"
AFISEAZA_CLASAMENT=false
AFISEAZA_STATISTICI=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --level) NIVEL="$2"; shift 2 ;;
        --max_tries) MAX_INCERCARI="$2"; shift 2 ;;
        --multiplayer) MULTIPLAYER=true; shift ;;
        --players) NUMAR_JUCATORI="$2"; shift 2 ;;
        --highscores) AFISEAZA_CLASAMENT=true; shift ;;
        --stats) AFISEAZA_STATISTICI=true; shift ;;
        --player) NUME_JUCATOR="$2"; shift 2 ;;
        *) exit 1 ;;
    esac
done

if $AFISEAZA_CLASAMENT; then
    jq -r '
      sort_by(.score) | reverse | .[0:10][] |
      [.player, (.score|tostring), (.attempts|tostring), .level] | @tsv
    ' "$CLASAMENT" \
    | awk '
        BEGIN {
          printf "%-20s  %-6s  %-10s  %-10s\n", "Jucator", "Scor", "Incercari", "Nivel"
          printf "%-20s  %-6s  %-10s  %-10s\n", "-------", "----", "----------", "-----"
        }
        { printf "%-20s  %-6s  %-10s  %-10s\n", $1, $2, $3, $4 }
      '
    exit 0
fi

if $AFISEAZA_STATISTICI; then
    grep "^$NUME_JUCATOR " "$STATISTICI" || echo "Nu exista statistici"
    exit 0
fi

case "$NIVEL" in
    easy) MINIM=1; MAXIM=50 ;;
    medium) MINIM=1; MAXIM=100 ;;
    hard) MINIM=1; MAXIM=1000 ;;
    *) exit 1 ;;
esac

NUMAR_SECRET=$((RANDOM % (MAXIM - MINIM + 1) + MINIM))
LIMITA_JOS=$MINIM
LIMITA_SUS=$MAXIM
INCERCARI=0

if $MULTIPLAYER; then
    for ((i=1;i<=NUMAR_JUCATORI;i++)); do
        read -p "Numele jucatorului $i: " nume
        NUME_JUCATORI+=("$nume")
    done
fi

echo "Ghicesc un numar intre $MINIM si $MAXIM"
echo "Incercari maxime: $MAX_INCERCARI"
echo

while ((INCERCARI < MAX_INCERCARI)); do
    ((INCERCARI++))

    if $MULTIPLAYER; then
        JUCATOR_CURENT="${NUME_JUCATORI[$(( (INCERCARI-1) % NUMAR_JUCATORI ))]}"
    else
        JUCATOR_CURENT="$NUME_JUCATOR"
    fi

    echo "Incercarea $INCERCARI/$MAX_INCERCARI ($JUCATOR_CURENT)"
    read -p "Numar: " GHICIRE

    [[ ! "$GHICIRE" =~ ^[0-9]+$ ]] && ((INCERCARI--)) && continue

    if ((GHICIRE < NUMAR_SECRET)); then
        LIMITA_JOS=$((GHICIRE + 1))
        echo "Prea mic ($LIMITA_JOS-$LIMITA_SUS)"
        echo
    elif ((GHICIRE > NUMAR_SECRET)); then
        LIMITA_SUS=$((GHICIRE - 1))
        echo "Prea mare ($LIMITA_JOS-$LIMITA_SUS)"
        echo
    else
        break
    fi
done

if ((GHICIRE != NUMAR_SECRET)); then
    echo "Ai pierdut. Numarul era $NUMAR_SECRET"
    exit 0
fi

SCOR=$(( (MAX_INCERCARI - INCERCARI + 1) * 100 ))

echo "Corect in $INCERCARI incercari"
echo "Scor: $SCOR"

jq \
  --arg player "$JUCATOR_CURENT" \
  --arg level "$NIVEL" \
  --argjson score "$SCOR" \
  --argjson attempts "$INCERCARI" \
  '. += [{player:$player, score:$score, attempts:$attempts, level:$level}]' \
  "$CLASAMENT" > "$CLASAMENT.tmp" && mv "$CLASAMENT.tmp" "$CLASAMENT"

jq '.' "$CLASAMENT" > "$CLASAMENT.tmp" && mv "$CLASAMENT.tmp" "$CLASAMENT"

echo "$JUCATOR_CURENT $INCERCARI castig" >> "$STATISTICI"
