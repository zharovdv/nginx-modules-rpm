FROM rockylinux:10@sha256:48fbd5632d0593a347f3a36b30ae857b3a4a66862a013be9d2ce47d1eb94d61c

RUN dnf install -y dnf-plugins-core epel-release \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
        bash ca-certificates findutils gcc gcc-c++ geolite2-country git gnupg2 gzip libmaxminddb libmaxminddb-devel \
        libxml2 libxslt make openssl-devel patch pcre-devel pcre2-devel \
        createrepo_c python3 rpm-build rpmdevtools rpm-sign tar unzip which xz zlib-devel \
    && dnf clean all

WORKDIR /workspace
COPY build /usr/local/bin/build-nginx-module
COPY build-geolite2-rpms /usr/local/bin/build-maxmind-geolite2-rpms
COPY create-repository /usr/local/bin/create-nginx-modules-repository
COPY generate-repository-index /usr/local/bin/generate-nginx-modules-repository-index
COPY reuse-geolite2-rpms /usr/local/bin/reuse-maxmind-geolite2-rpms
COPY sign-rpms /usr/local/bin/sign-nginx-module-rpms
COPY modules /workspace/modules
COPY packaging/maxmind-geolite2 /workspace/packaging/maxmind-geolite2

RUN chmod 0755 \
        /usr/local/bin/build-nginx-module \
        /usr/local/bin/build-maxmind-geolite2-rpms \
        /usr/local/bin/create-nginx-modules-repository \
        /usr/local/bin/generate-nginx-modules-repository-index \
        /usr/local/bin/reuse-maxmind-geolite2-rpms \
        /usr/local/bin/sign-nginx-module-rpms \
        /workspace/modules/*/smoke-test.sh

ENTRYPOINT ["/usr/local/bin/build-nginx-module"]
