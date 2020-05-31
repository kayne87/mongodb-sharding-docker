FROM mongo:latest

RUN apt-get update && apt-get -q install -y

COPY --chown=mongodb:mongodb router.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/router.sh

COPY --chown=mongodb:mongodb router_entry.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/router_entry.sh

ENTRYPOINT ["router_entry.sh"]