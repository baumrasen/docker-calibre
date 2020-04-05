FROM library/debian

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="baumrasen"

ENV APPNAME="Calibre" UMASK_SET="022"

# get some infos from
# https://github.com/kovidgoyal/calibre/blob/master/bypy/README.rst

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	dbus \
	fcitx-rime \
	fonts-wqy-microhei \
	jq \
	libxkbcommon-x11-0 \
	python \
	python-xdg \
	ttf-wqy-zenhei \
	wget \
	xz-utils \
	apt-utils \
	openssl \
	ca-certificates \
	git \
	curl && \
 echo "**** install calibre ****" && \
 if [ -z ${CALIBRE_RELEASE+x} ]; then \
	CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 CALIBRE_VERSION="$(echo ${CALIBRE_RELEASE} | cut -c2-)" && \
# CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}.tar.xz" && \
 mkdir -p \
	/opt && \
# ln -s /opt/calibre-${CALIBRE_VERSION} /opt/calibre && \
 cd /opt && \
 git clone https://github.com/kovidgoyal/bypy.git && \
 git clone https://github.com/kovidgoyal/calibre.git && \
 git checkout ${CALIBRE_VERSION} && \
# curl -o \
#	/tmp/calibre-tarball.tar.xz -L \
#	"$CALIBRE_URL" && \
# tar xvJf /tmp/calibre-tarball.tar.xz -C \
#	/opt && \	
 cd /opt/calibre && \
 python setup.py bootstrap && \
 python setup.py build_dep linux && \
 python setup.py install && \
 /opt/calibre/calibre_postinstall && \
 dbus-uuidgen > /etc/machine-id && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /
