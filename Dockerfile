FROM onlyoffice/documentserver:7.1.1@sha256:8a1edcc13f9d9dd61f3e77bcb172b0f32d0788aa2c63bb5a1206a7633e3dd2f8 AS ds-service

ADD fonts/ /etc/fonts

RUN mkdir -p /var/www/onlyoffice/documentserver/core-fonts/msttcore && \
    mkdir -p /usr/share/fonts/truetype/sourcesanspro && \
    cp -vt \
        /var/www/onlyoffice/documentserver/core-fonts/msttcore \
        /usr/share/fonts/truetype/msttcorefonts/*.ttf && \
    cp -vt \
        /usr/share/fonts/truetype/sourcesanspro \
        /etc/fonts/Source_Sans_Pro/* && \
    chown -R ds:ds /var/www/onlyoffice/documentserver/core-fonts/msttcore && \
    chmod a+r /etc/onlyoffice/documentserver/*.json && \
    chmod a+r /etc/onlyoffice/documentserver/log4js/*.json
RUN documentserver-generate-allfonts.sh true


FROM amd64/debian:11-slim@sha256:d2285c63f42a27d633afa75929529c3761883faac292e7c1cf310d91c7399863 AS onlyoffice

LABEL maintainer="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.authors="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.title="Onlyoffice"
LABEL org.opencontainers.image.url="https://github.com/owncloud-ops/onlyoffice"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ops/onlyoffice"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ops/onlyoffice"

ARG GOMPLATE_VERSION
ARG WAIT_FOR_VERSION
ARG CONTAINER_LIBRARY_VERSION

ARG DEBIAN_FRONTEND=noninteractive

# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ENV GOMPLATE_VERSION="${GOMPLATE_VERSION:-v3.11.1}"
# renovate: datasource=github-releases depName=thegeeklab/wait-for
ENV WAIT_FOR_VERSION="${WAIT_FOR_VERSION:-v0.2.0}"
# renovate: datasource=github-releases depName=owncloud-ops/container-library
ENV CONTAINER_LIBRARY_VERSION="${CONTAINER_LIBRARY_VERSION:-v0.1.0}"

ENV NODE_ENV=production-linux
ENV NODE_CONFIG_DIR=/etc/onlyoffice/documentserver

WORKDIR /var/www/onlyoffice/documentserver

RUN addgroup --gid 101 --system ds && \
    adduser --system --disabled-password --no-create-home --uid 101 --shell /sbin/nologin --ingroup ds --gecos ds ds && \
    apt-get update && apt-get install -y wget curl gnupg2 procps apt-transport-https ca-certificates nginx nginx-extras mariadb-client \
        iputils-ping netcat-openbsd && \
    curl -SsfL -o /usr/local/bin/gomplate "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim" && \
    curl -SsfL -o /usr/local/bin/wait-for "https://github.com/thegeeklab/wait-for/releases/download/${WAIT_FOR_VERSION}/wait-for" && \
    curl -SsfL "https://github.com/owncloud-ops/container-library/releases/download/${CONTAINER_LIBRARY_VERSION}/container-library.tar.gz" | tar xz -C / && \
    chmod 755 /usr/local/bin/gomplate && \
    chmod 755 /usr/local/bin/wait-for && \
    touch /run/nginx.pid && \
    chown ds /run/nginx.pid && \
    chown -R ds /var/log/nginx && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/lib/nginx && \
    chown -R ds /var/cache/nginx && \
    chown -R ds /var/lib/nginx && \
    chmod -R 750 /var/cache/nginx && \
    chmod -R 750 /var/lib/nginx && \
    sed -i 's|\(application\/zip.*\)|\1\n    application\/wasm wasm;|' /etc/nginx/mime.types && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

COPY --from=ds-service \
    /etc/onlyoffice/documentserver/default.json \
    /etc/onlyoffice/documentserver/production-linux.json \
    /etc/onlyoffice/documentserver/
COPY --from=ds-service --chown=ds:ds \
    /etc/onlyoffice/documentserver/log4js/production.json \
    /etc/onlyoffice/documentserver/log4js/
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/sdkjs-plugins \
    /var/www/onlyoffice/documentserver/sdkjs-plugins
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/server/DocService \
    /var/www/onlyoffice/documentserver/server/DocService
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/core-fonts \
    /var/www/onlyoffice/documentserver/core-fonts
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/fonts \
    /var/www/onlyoffice/documentserver/fonts
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/dictionaries \
    /var/www/onlyoffice/documentserver/dictionaries
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/sdkjs \
    /var/www/onlyoffice/documentserver/sdkjs
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/server/FileConverter \
    /var/www/onlyoffice/documentserver/server/FileConverter
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/web-apps \
    /var/www/onlyoffice/documentserver/web-apps
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver-example/welcome \
    /var/www/onlyoffice/documentserver-example/welcome
COPY --from=ds-service \
    /var/www/onlyoffice/documentserver/server/schema/mysql/ \
    /var/www/onlyoffice/documentserver/server/schema/mysql/
COPY --from=ds-service \
    /usr/share/fonts \
    /usr/share/fonts

ADD overlay /

RUN mkdir -p \
        /var/lib/onlyoffice/documentserver/App_Data/cache/files \
        /var/lib/onlyoffice/documentserver/App_Data/docbuilder && \
    chown -R ds:ds /var/lib/onlyoffice/documentserver && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libgraphics.so /usr/lib/libgraphics.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libdoctrenderer.so /usr/lib/libdoctrenderer.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libkernel.so /usr/lib/libkernel.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libicudata.so.58 /usr/bin/libicudata.so.58 && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libicuuc.so.58 /usr/bin/libicuuc.so.58 && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libDjVuFile.so /usr/lib/libDjVuFile.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libEpubFile.so /usr/lib/libEpubFile.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libFb2File.so /usr/lib/libFb2File.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libPdfReader.so /usr/lib/libPdfReader.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libPdfWriter.so /usr/lib/libPdfWriter.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libHtmlFile2.so /usr/lib/libHtmlFile2.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libHtmlRenderer.so /usr/lib/libHtmlRenderer.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libUnicodeConverter.so /usr/lib/libUnicodeConverter.so && \
    ln -sf /var/www/onlyoffice/documentserver/server/FileConverter/bin/libXpsFile.so /usr/lib/libXpsFile.so && \
    mkdir -p \
        /var/lib/onlyoffice/documentserver/App_Data/cache/files \
        /var/lib/onlyoffice/documentserver/App_Data/docbuilder && \
    find \
        /var/www/onlyoffice/documentserver/fonts \
        -type f ! \
        -name "*.*" \
        -exec sh -c 'gzip -cf9 $0 > $0.gz' {} \; && \
    find \
        /var/www/onlyoffice/documentserver/sdkjs \
        /var/www/onlyoffice/documentserver/sdkjs-plugins \
        /var/www/onlyoffice/documentserver/web-apps \
        /var/www/onlyoffice/documentserver-example/welcome \
        -type f \
        \( -name *.js -o -name *.json -o -name *.htm -o -name *.html -o -name *.css \) \
        -exec sh -c 'gzip -cf9 $0 > $0.gz' {} \; && \
    chown -R ds:ds \
        /etc/onlyoffice/documentserver \
        /var/lib/onlyoffice/documentserver \
        /var/www/onlyoffice/documentserver

EXPOSE 8080

USER ds

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD []
