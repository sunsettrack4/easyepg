FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV CRON='0 0 * * 7'

RUN apt-get update \
  && apt-get install -qy --no-install-recommends \
    iproute2 \
    cron \
    phantomjs \
    dialog \
    curl \
    wget \
    libxml2-utils \
    perl \
    perl-doc \
    jq \
    php-cli \
    php-curl \
    git \
    xml-twig-tools \
    unzip \
    liblocal-lib-perl \
    cpanminus \
    build-essential \
    inetutils-ping \
  && rm -rf /var/lib/apt/lists/* \
    /var/cache/apt/archives/


# Install CPAN and the required modules to parse JSON files
RUN cpanm JSON \
    XML::Rules \
    XML::DOM \
    Data::Dumper \
    Time::Piece \
    Time::Seconds \
    DateTime \
    DateTime::Format::DateParse \
    utf8

COPY docker-entrypoint.sh /
VOLUME /src

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["./epg.sh"]

