FROM indexer-service:v0.19.3-querylogspatch

RUN apt-get install -y jq netcat
COPY indexer-service-autoagora-wrapper.sh /opt/autoagora/bin/

# Run the indexer-service through the AutoAgora wrapper
WORKDIR /opt/autoagora/bin
ENTRYPOINT ["bash", "indexer-service-autoagora-wrapper.sh"]
