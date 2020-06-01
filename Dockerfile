FROM kong:2.0.4

COPY ./ip-header-restriction /usr/local/custom/kong/plugins/ip-header-restriction

USER root

WORKDIR /usr/local/custom/kong/plugins/ip-header-restriction

RUN luarocks make

USER kong