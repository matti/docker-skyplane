FROM debian:12-slim
ENV PYENV_ROOT="/pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN set -eux ; \
  apt-get update ; \
  apt-get upgrade -y

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends \
  ca-certificates curl git build-essential

RUN set -eux ; \
  curl https://pyenv.run | bash

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends \
  zlib1g-dev libssl-dev liblzma-dev libsqlite3-dev libncurses-dev libbz2-dev \
  libreadline-dev libffi-dev

ENV PATH="$PYENV_ROOT/versions/3.11.9/bin:$PATH"
RUN pyenv install 3.11.9
RUN pyenv global 3.11.9

RUN set -eux ; \
  pyenv exec pip install --upgrade pip

RUN pip install 'skyplane[all]'

# https://stackoverflow.com/questions/78650222/valueerror-numpy-dtype-size-changed-may-indicate-binary-incompatibility-expec

RUN pip install "numpy<2"

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends \
  unzip

ARG TARGETARCH
RUN set -eux ; \
  mkdir /ghjk && cd /ghjk ; \
  [ "$TARGETARCH" = "arm64" ] && arch="aarch64" || arch="x86_64" ; \
  curl -Lfo "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" ; \
  unzip awscliv2.zip ; \
  ./aws/install ; \
  rm -rf /ghjk

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y apt-transport-https ca-certificates gnupg curl

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y google-cloud-cli

ENV PROMPT_COMMAND="history -a"
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
