# This is executing a security-sensitive application, therefore this is complete dockerfile merged from all user stuff and reviewed.
# Thanks to all people listed below.

# From suchja/x11client
# Written by MAINTAINER Jan Suchotzki <jan@suchotzki.de> 

FROM debian:jessie

# first create user and group for all the X Window stuff
# required to do this first so we have consistent uid/gid between server and client container
RUN addgroup --system xusers \
  && adduser \
      --home /home/xclient \
      --disabled-password \
      --shell /bin/bash \
      --gecos "user for running an xclient application" \
      --ingroup xusers \
      --quiet \
      xclient

# Install packages required for connecting against X Server
# Also merged to install requirements for wine etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        ca-certificates \
        xauth \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

# Before switching user, root needs to ensure that entrypoint can be executed.
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# During startup we need to prepare connection to X11-Server container
USER xclient
ENTRYPOINT ["/entrypoint.sh"]


# From suchja/wine
# Written by MAINTAINER Jan Suchotzki <jan@suchotzki.de> 

# Inspired by monokrome/wine ENV WINE_MONO_VERSION 0.0.8 USER root
# Install some tools required for creating the image 
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
# Install wine and related packages 
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wine \
        wine32 \
    && rm -rf /var/lib/apt/lists/*

# Use the latest version of winetricks 
RUN curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks \
    && chmod +x /usr/local/bin/winetricks

# Get latest version of mono for wine 
RUN mkdir -p /usr/share/wine/mono \
  && curl -SL 'http://sourceforge.net/projects/wine/files/Wine%20Mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi/download' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
  && chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

# Wine really doesn't like to be run as root, so let's use a non-root user 
USER xclient 
ENV HOME /home/xclient 
ENV WINEPREFIX /home/xclient/.wine 
ENV WINEARCH win32

# Use xclient's home dir as working dir 
WORKDIR /home/xclient 
RUN echo "alias winegui='wine explorer /desktop=DockerDesktop,1024x768'" > ~/.bash_aliases 


# To build:
# docker build -t geekylucas/1password-wine .
#
# To run:
# docker run \
#   -it \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=unix$DISPLAY \
#   -v "$HOME/Dropbox/1Password.agilekeychain:/wine/drive_c/users/root/My Documents/1Password.agilekeychain" \
#   --net="host" \
#   --name 1password-wine \
#   geekylucas/1password-wine \
#   bash
#
# To operate:
# Use up arrow for handy commands
#
# To start after first run:
# docker start -i geekylucas/1password-wine

# From geekylucas/1password-wine
# Written by MAINTAINER Lucas Chan <docker@lucaschan.com>

ENV WINEPREFIX=/wine

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  && \
  rm -rf /var/lib/apt/lists/*

ADD https://d13itkw33a7sus.cloudfront.net/dist/1P/win4/1Password-4.6.0.598.exe /usr/src/

# Auto install 1Password using xvfb as null display.
# WINEDLLOVERRIDES=mscoree=d to disable wine's mono install prompt.
# wineserver -k to flush registry files to disk after install.

RUN xvfb-run -a bash -c "\
  WINEDLLOVERRIDES=mscoree=d wine /usr/src/1Password-4.6.0.598.exe /VERYSILENT /DIR=c:\1Password && \
  grep -A4 Installation /wine/drive_c/1Password/1Password.InnoSetup.log.txt && \
  /usr/lib/i386-linux-gnu/wine/bin/wineserver -k"

RUN echo >/root/.bash_history "wine /wine/drive_c/1Password/Agile1pAgent.exe" && \
  echo >>/root/.bash_history "wine /wine/drive_c/1Password/1Password.exe"

EXPOSE 6258

CMD ["wine", "/wine/drive_c/1Password/1Password.exe"]
