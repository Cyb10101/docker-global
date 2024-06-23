#!/usr/bin/env bash

replaceMarker() {
    REPLACE="${1}"
    INSERT="${2}"
    TEMPLATE="$(cat ${3})"
    echo "${TEMPLATE//${REPLACE}/${INSERT}}" > ${3}
}

if [ ! -d public ]; then mkdir public; fi

# Generate container default error
cp template.html public/index.html
replaceMarker '{{ code }}' '500' public/index.html

# Generate status pages
errorCodes=( 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 500 501 502 503 504 505 506 507 508 510 511 )
for errorCode in "${errorCodes[@]}"; do
    cp template.html public/${errorCode}.html
    replaceMarker '{{ code }}' "${errorCode}" public/${errorCode}.html
done
