FROM bitnami/minideb:unstable as BASAL

FROM BASAL as COMPILED
RUN install_packages --no-install-recommends software-properties-common gcc-7 g++-7 git make

ADD https://github.com/uNetworking/uTT/archive/master.tar.gz /uTT.tar.gz
RUN tar xvzf /uTT.tar.gz
WORKDIR /uTT-master/
ADD https://github.com/alexhultman/uSockets/archive/master.tar.gz /uTT-master/uSockets.tar.gz
RUN tar xvzf uSockets.tar.gz && mv uSockets-master/* uSockets && rm -rf /uSockets/uSockets-master
RUN g++-7 -std=c++17 -O3 -s -I. src/*.cpp uSockets/Berkeley.cpp uSockets/Epoll.cpp -o uTT

FROM BASAL as INIT
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

FROM INIT as RELEASE
WORKDIR /uTT/
COPY --from=COMPILED /uTT-master /uTT

CMD ["./uTT"]

EXPOSE 1883
