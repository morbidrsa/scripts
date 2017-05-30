#!/bin/sh

if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename $0) 0000-cover-letter.patch template.txt [changelog.txt]"
    exit 1
fi

COVER_LETTER="$1"
TEMPLATE="$2"
CHANGELOG=""

if [[ $# -eq 3 ]]; then
    CHANGELOG="$3"
fi

if [[ -z $CHANGELOG ]]; then
    sed -i -e "s/^\*\*\* BLURB HERE \*\*\*/cat ${TEMPLATE}/e" ${COVER_LETTER}
else
    sed -i -e "s/^\*\*\* BLURB HERE \*\*\*/cat ${TEMPLATE} ${CHANGELOG}/e" \
      ${COVER_LETTER}
fi
