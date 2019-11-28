FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -qy \
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
    php \
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
RUN cpan App:cpanminus \
  && cpanm install JSON \
     XML::Rules \
     XML::DOM \
     Data::Dumper \
     Time::Piece \
     Time::Seconds \
     DateTime \
     DateTime::Format::DateParse \
     utf8

# Create any directory in your desired location, e.g.:


WORKDIR "/src"

CMD ["/src/epg.sh"]
