FROM hypriot/rpi-java:1.8.0
MAINTAINER Joris Potier<j.potier@code-troopers.com>

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget

#########################
## Tomcat installation ##
#########################

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN for key in \
		05AB33110949707C93A279E3D3EFE6B686867BA6 \
		07E48665A34DCAFAE522E5E6266191C37C037D42 \
		47309207D818FFD8DCD3F83F1931D684307A10A5 \
		541FBE7D8F78B25E055DDEE13C370389288584E7 \
		61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
		79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
		9BA44C2621385CB966EBA586F72C284D731FABEE \
		A27677289986DB50844682F8ACB77FC2E86E29AC \
		A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
		DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
		F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
		F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.33
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*


###########################
## Subsonic installation ##
###########################

ENV SUBSONIC_VERSION 6.0

LABEL version="$SUBSONIC_VERSION"
LABEL description="Subsonic media streamer"

RUN apt-get -y install libav-tools lame unzip &&\
        mkdir -p /opt/data/transcode /opt/music/ /opt/playlist/ /opt/podcast/ &&\
        ln -s /usr/bin/lame /opt/data/transcode/lame &&\
        ln -s /usr/bin/avconv /opt/data/transcode/ffmpeg &&\
        cd  ${CATALINA_HOME}/webapps/ &&\
        rm -rf ROOT &&\
        wget "http://downloads.sourceforge.net/project/subsonic/subsonic/$SUBSONIC_VERSION/subsonic-$SUBSONIC_VERSION-war.zip?r=http%3A%2F%2Fwww.subsonic.org%2Fpages%2Fdownload2.jsp%3Ftarget%3Dsubsonic-$SUBSONIC_VERSION-standalone.tar.gz&ts=1431096340&use_mirror=garr" \
        -O subsonic.war.zip --quiet  &&\
        unzip subsonic.war.zip && rm subsonic.war.zip && mv subsonic.war ROOT.war &&\
	rm -rf /var/lib/apt/lists/*

ADD server.xml /usr/local/tomcat/conf/
ENV JAVA_OPTS="-Dsubsonic.contextPath=/ -Dsubsonic.home=/opt/data -Dsubsonic.defaultMusicFolder=/opt/music/ -Dsubsonic.defaultPodcastFolder=/opt/podcast/ -Dsubsonic.defaultPlaylistFolder=/opt/playlist/"

VOLUME /opt/data
VOLUME /opt/music/
VOLUME /opt/playlist/
VOLUME /opt/podcast/

EXPOSE 8080
CMD ["catalina.sh", "run"]
