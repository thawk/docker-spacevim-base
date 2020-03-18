FROM thawk/neovim:latest

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/thawk/docker-spacevim-base.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

COPY viminfo $HOME/.viminfo

RUN true \
 && git clone --depth 1 https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim \
 && git clone --depth 1 https://github.com/thawk/dotspacevim.git $HOME/.SpaceVim.d \
 && rm -r $HOME/.SpaceVim/.git $HOME/.SpaceVim.d/.git \
 && mkdir -p $HOME/.config \
 && ln -s $HOME/.SpaceVim $HOME/.config/nvim \
 && sed -i -e '/begin optional layers/,/end optional layers/ d' $HOME/.SpaceVim.d/init.toml \
 && git clone --depth 1 https://github.com/Shougo/dein.vim.git $HOME/.cache/vimfiles/repos/github.com/Shougo/dein.vim \
 && nvim --headless +'call dein#install()' +qall \
 && (find $HOME/.cache/vimfiles -type d -name ".git" | xargs rm -r) \
 && true

ONBUILD COPY additional.toml $HOME/.SpaceVim.d/

ONBUILD RUN true \
 && cat $HOME/.SpaceVim.d/additional.toml >> $HOME/.SpaceVim.d/init.toml \
 && nvim --headless +'call dein#install()' +UpdateRemotePlugins +qall \
 && (find $HOME/.cache/vimfiles -type d -name ".git" | xargs rm -r) \
 && nvim --headless +qall \
 && mkdir -p $HOME/.local \
 && chmod 777 $HOME \
 && chmod 777 -R $HOME/.config \
 && chmod 777 -R $HOME/.cache \
 && chmod 777 -R $HOME/.local \
 && chmod 666 $HOME/.viminfo \
 && true

WORKDIR /src
VOLUME /src

