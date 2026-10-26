FROM mongo:8

COPY mongo-keyfile /etc/mongo-keyfile
RUN chmod 400 /etc/mongo-keyfile && chown mongodb:mongodb /etc/mongo-keyfile

COPY init-replica.sh /usr/local/bin/init-replica.sh
RUN sed -i 's/\r$//' /usr/local/bin/init-replica.sh && chmod +x /usr/local/bin/init-replica.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/init-replica.sh"]
