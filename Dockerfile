FROM rockylinux:9@sha256:d7be1c094cc5845ee815d4632fe377514ee6ebcf8efaed6892889657e5ddaaa6

RUN dnf install -y dnf-plugins-core epel-release \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
        bash ca-certificates findutils gcc gcc-c++ geolite2-country git gnupg2 gzip libmaxminddb-devel \
        libxml2 libxslt make openssl-devel patch pcre-devel pcre2-devel \
        createrepo_c python3 rpm-build rpmdevtools rpm-sign tar unzip which xz zlib-devel \
    && dnf clean all

WORKDIR /workspace
COPY build /usr/local/bin/build-nginx-module
COPY create-repository /usr/local/bin/create-nginx-modules-repository
COPY generate-repository-index /usr/local/bin/generate-nginx-modules-repository-index
COPY sign-rpms /usr/local/bin/sign-nginx-module-rpms
COPY modules /workspace/modules

RUN chmod 0755 \
        /usr/local/bin/build-nginx-module \
        /usr/local/bin/create-nginx-modules-repository \
        /usr/local/bin/generate-nginx-modules-repository-index \
        /usr/local/bin/sign-nginx-module-rpms \
        /workspace/modules/*/smoke-test.sh

ENTRYPOINT ["/usr/local/bin/build-nginx-module"]
