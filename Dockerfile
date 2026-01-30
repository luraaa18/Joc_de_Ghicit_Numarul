FROM alpine:3.20

RUN apk add --no-cache bash coreutils sed gawk jq

WORKDIR /app

COPY joc_ghicit.sh /app/joc_ghicit.sh
RUN chmod +x /app/joc_ghicit.sh

VOLUME ["/data"]

WORKDIR /data

ENTRYPOINT ["/app/joc_ghicit.sh"]