FROM mongo:latest

RUN apt-get update && apt-get -q install -y

COPY --chown=mongodb:mongodb replicaset.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/replicaset.sh

COPY --chown=mongodb:mongodb replicaset_entry.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/replicaset_entry.sh

ENTRYPOINT ["replicaset_entry.sh"]