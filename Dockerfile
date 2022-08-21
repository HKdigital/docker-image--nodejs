# ........................................................................ About
#
# @see README at https://github.com/HKdigital/docker-images--nodejs
#

# ......................................................................... FROM

FROM hkdigital/debian-slim

MAINTAINER Jens Kleinhout "hello@hkdigital.nl"

# .......................................................................... ENV

# Update the timestamp below to force an apt-get update during build
ENV APT_SOURCES_REFRESHED_AT 2022-08-21_16h36

# ....................................................................... NodeJS

#
# Good reason to upgrade to NodeJs v18 (not LTS): browser-compatible API's
# @see https://nodejs.org/en/blog/announcements/v18-release-announce/
#
ENV NODE_VERSION 18.7.0

#
# @note gpg keys of nodejs releasers listed at
#       https://github.com/nodejs/node#release-team
#       https://github.com/nodejs/node#release-keys
#

RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --keyserver keys.openpgp.org --recv-keys "$key"; \
  done

#
# Download NodeJS
#
RUN curl -SLO \
  "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" \
     SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" \
     -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

# RUN apt-get -y remove --purge gpg && apt-get clean

#
# Alternative: install the stock version of NodeJS
#
# RUN apt-get -qq -y install nodejs

# ............................................... Install nodemon (for dev mode)

RUN npm install -g nodemon

# ................................................................. Install yarn

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
    sudo apt-key add -

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
    sudo tee /etc/apt/sources.list.d/yarn.list

RUN sudo apt update && sudo apt install --no-install-recommends yarn

# ............................................................ COPY /image-files

# Copy files and folders from project folder "/image-files" into the image
# - The folder structure will be maintained by COPY
#
# @note
#    No star in COPY command to keep directory structure
#    @see http://stackoverflow.com/
#        questions/30215830/dockerfile-copy-keep-subdirectory-structure

# Update the timestamp below to force copy of image-files during build
ENV IMAGE_FILES_REFRESHED_AT 2022-07-16_13h30

COPY ./image-files/ /

# ................................................................. EXPOSE PORTS

# @note no default ports are exported
