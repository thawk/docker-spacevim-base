FROM centos:centos7

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/thawk/docker-spacevim-base.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

ENV HOME=/myhome
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN  mkdir -p $HOME
COPY viminfo $HOME/.viminfo

RUN yum install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    centos-release-scl-rh \
 && true

RUN true \
 && yum install -y \
    python2-pip \
    python3 \
    python3-pip \
    lua \
    make \
    libtool \
    autoconf \
    automake \
    cmake \
    gcc-c++ \
    the_silver_searcher \
    git \
    subversion \
    man \
    wget \
 && true

RUN pip2 install --upgrade pip \
 && pip3 install --upgrade pip \
 && pip2 install \
    pynvim \
    jedi \
    flake8 \
    flake8-docstrings \
    flake8-isort \
    flake8-quotes \
 && pip3 install \
    msgpack \
    pynvim \
 && true

RUN true \
 && cd $HOME \
 && (curl -sL https://rpm.nodesource.com/setup_10.x | bash -) \
 && (curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo > /etc/yum.repos.d/yarn.repo) \
 && yum install -y nodejs yarn \
 && npm install -g \
    neovim \
 && true

RUN true \
 && cd $HOME \
 && umask 0000 \
 && (curl -L https://github.com/neovim/neovim/releases/latest/download/nvim.appimage > nvim.appimage) \
 && chmod a+x nvim.appimage \
 && ./nvim.appimage --appimage-extract \
 && rm nvim.appimage \
 && find ./squashfs-root -type d | xargs chmod a+rx \
 && true

ENV PATH="${PATH}:${HOME}/node_modules/.bin"

RUN true \
 && umask 0000 \
 && git clone --depth 1 https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim \
 && git clone --depth 1 https://github.com/thawk/dotspacevim.git $HOME/.SpaceVim.d \
 && rm -r $HOME/.SpaceVim/.git $HOME/.SpaceVim.d/.git \
 && mkdir -p $HOME/.config \
 && ln -s $HOME/.SpaceVim $HOME/.config/nvim \
 && sed -i -e '/begin optional layers/,/end optional layers/ d' $HOME/.SpaceVim.d/init.toml \
 && git clone --depth 1 https://github.com/Shougo/dein.vim.git $HOME/.cache/vimfiles/repos/github.com/Shougo/dein.vim \
 && true

COPY run_nvim.sh ${HOME}
RUN true \
 && ln -s "${HOME}/squashfs-root/usr/bin/nvim" /usr/bin \
 && chmod a+x ${HOME}/run_nvim.sh \
 && true

ONBUILD COPY additional_pkg.txt $HOME/
ONBUILD RUN true \
 && cat $HOME/additional_pkg.txt | xargs yum install -y \
 && true

ONBUILD COPY additional_vim.toml $HOME/
ONBUILD RUN true \
 && umask 0000 \
 && cat $HOME/additional_vim.toml >> $HOME/.SpaceVim.d/init.toml \
 && $HOME/run_nvim.sh --headless +'call dein#install()' +qall \
 && $HOME/run_nvim.sh --headless +UpdateRemotePlugins +qall \
 && (find $HOME/.cache/vimfiles -type d -name ".git" | xargs rm -r) \
 && $HOME/run_nvim.sh --headless +qall \
 && mkdir -p $HOME/.local \
 && chmod 777 $HOME \
 && chmod 777 -R $HOME/{.config,.cache,.local} \
 && chmod a+rw -R $HOME/.npm \
 && chmod 666 $HOME/.viminfo \
 && true

WORKDIR /src
VOLUME /src

ENTRYPOINT ["/myhome/run_nvim.sh"]
