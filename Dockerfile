FROM docker.io/golang:1.23.1-alpine3.20 as builder

RUN apk add --no-cache \
        # Required for apptainer to find min go version
        bash \
        cryptsetup \
        gawk \
        gcc \
        curl \
        libc-dev \
        linux-headers \
        libressl-dev \
        libuuid \
        libseccomp-dev \
        make \
        util-linux-dev

ARG APPTAINER_RELEASE="1.3.4"
ARG MCONFIG_OPTIONS="--with-suid"
WORKDIR $GOPATH/src/github.com/apptainer
RUN (curl -fsSL https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_RELEASE}/apptainer-${APPTAINER_RELEASE}.tar.gz | tar -xzf - -C . --strip-components 1) \
    && ./mconfig $MCONFIG_OPTIONS -p /usr/local/apptainer \
    && cd builddir \
    && make -j $(nproc) \
    && make install

FROM docker.io/alpine:3.20.3
COPY --from=builder /usr/local/apptainer /usr/local/apptainer
ENV PATH="/usr/local/apptainer/bin:$PATH" \
    APPTAINER_TMPDIR="/tmp-apptainer"
RUN apk add --no-cache ca-certificates libseccomp squashfs-tools tzdata \
    && mkdir -p $APPTAINER_TMPDIR \
    && cp /usr/share/zoneinfo/UTC /etc/localtime \
    && apk del tzdata \
    && rm -rf /tmp/* /var/cache/apk/*
WORKDIR /work
ENTRYPOINT ["/usr/local/apptainer/bin/apptainer"]
