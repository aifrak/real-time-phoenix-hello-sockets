# —————————————————————————————————————————————— #
#                      base                      #
# —————————————————————————————————————————————— #

FROM ubuntu:focal-20211006 as base

USER root

ENV INSIDE_DOCKER=1
ENV LANG=en_US.UTF-8

# 1. Install dependencies
#   - git
#   - erlang: libodbc1, libssl1, libsctp1
#   - locales
# 2. Setup locales
# 3. Clean
RUN set -e \
  && apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
  git=1:2.25.1-* \
  libodbc1=2.3.6-* \
  libssl1.1=1.1.1f-* \
  libsctp1=1.0.18+* \
  locales=2.31-* \
  && sed -i "/${LANG}/s/^# //g" /etc/locale.gen \
  && locale-gen ${LANG} \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

# Added here instead before `locale-gen` to avoid warnings
ENV LC_ALL=${LANG}

ENV USERNAME=app-user
ARG GROUPNAME=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV HOME=/home/${USERNAME}
ENV APP_DIR=/app

# 1. Add username and groupname
# 2. Create project directory and add ownership
RUN set -e \
  && groupadd --gid ${USER_GID} ${GROUPNAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash \
  --create-home ${USERNAME} \
  && mkdir ${APP_DIR} \
  && chown ${USERNAME}: ${APP_DIR}

USER ${USERNAME}

WORKDIR ${APP_DIR}

CMD [ "bash" ]

# —————————————————————————————————————————————— #
#                       ci                       #
# —————————————————————————————————————————————— #

FROM hexpm/elixir:1.12.3-erlang-24.1.7-ubuntu-focal-20210325 as elixir
# Install hex and rebar
RUN set -e \
  && mix local.hex --force \
  && mix local.rebar --force

FROM node:16.13.1-buster as node
RUN npm install -g npm@8.3.0 --quiet

FROM base as ci

USER root

# Add NodeJS (without yarn)
COPY --from=node --chown=root /usr/local/bin /usr/local/bin/
COPY --from=node --chown=root /usr/local/include /usr/local/include/
COPY --from=node --chown=root /usr/local/lib /usr/local/lib/
COPY --from=node --chown=root /usr/local/share /usr/local/share/
# Remove dead symbolic links from yarn
RUN find /usr/local/bin/. -xtype l -exec rm {} \; 2>/dev/null

# Add erlang and elixir
COPY --from=elixir --chown=root /usr/local/bin /usr/local/bin
COPY --from=elixir --chown=root /usr/local/lib /usr/local/lib
COPY --from=elixir --chown=root /usr/local/sbin /usr/local/sbin
COPY --from=elixir --chown=${USERNAME} /root/.mix ${HOME}/.mix

USER ${USERNAME}

ENV CI=true

# —————————————————————————————————————————————— #
#                       dev                      #
# —————————————————————————————————————————————— #

FROM ci as dev

USER root

# 1. Install packages
# 2. Give sudo rights to "USERNAME"
# 3. Clean
RUN set -e \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
  ca-certificates=* \
  gnupg2=* \
  inotify-tools=* \
  openssh-client=* \
  sudo=* \
  && echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/"${USERNAME}" \
  && chmod 0440 /etc/sudoers.d/"${USERNAME}" \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

ENV CI=false

USER ${USERNAME}

# —————————————————————————————————————————————— #
#                     vscode                     #
# —————————————————————————————————————————————— #

FROM dev as vscode

WORKDIR ${HOME}

RUN set -e \
  && mkdir -p .vscode-server/extensions \
  .vscode-server-insiders/extensions

WORKDIR ${APP_DIR}
