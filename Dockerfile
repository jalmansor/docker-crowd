FROM nextgearcapital/java:latest
MAINTAINER NextGear Capital <devops@nextgearcapital.com>

ARG RUN_USER=crowd
ARG RUN_GROUP=crowd
ARG RUN_UUID=1001

ARG CROWD_INSTALL_DIR=/opt/atlassian/crowd
ARG CROWD_HOME=/var/atlassian/application-data/crowd

ARG CROWD_VERSION
ENV DOWNLOAD_URL https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-$CROWD_VERSION.tar.gz

RUN /usr/sbin/useradd --create-home --shell /bin/bash --uid ${RUN_UUID} ${RUN_USER}

RUN mkdir -p ${CROWD_INSTALL_DIR} \
    && curl -L ${DOWNLOAD_URL} | tar -xz --strip=1 -C "$CROWD_INSTALL_DIR" \
    && echo crowd.home="$CROWD_HOME" > ${CROWD_INSTALL_DIR}/crowd-webapp/WEB-INF/classes/crowd-init.properties \
    && sed -i 's!exec "$PRGDIR"/"$EXECUTABLE" start "$@"!exec "$PRGDIR"/"$EXECUTABLE" run "$@"!g' ${CROWD_INSTALL_DIR}/apache-tomcat/bin/startup.sh \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CROWD_INSTALL_DIR}/ \
    && mkdir -p ${CROWD_HOME} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CROWD_HOME}                           

USER ${RUN_USER}

VOLUME ["${CROWD_HOME}"]

EXPOSE 8095
EXPOSE 8443

CMD ["/opt/atlassian/crowd/start_crowd.sh", "-fg"]
