[![](https://images.microbadger.com/badges/image/thawk/spacevim-base.svg)](https://microbadger.com/images/thawk/spacevim-base) [![](https://images.microbadger.com/badges/commit/thawk/spacevim-base.svg)](https://microbadger.com/images/thawk/spacevim-base) [![](https://images.microbadger.com/badges/version/thawk/spacevim-base.svg)](https://microbadger.com/images/thawk/spacevim-base)

A neovim with [SpaceVim](https://spacevim.org) and [my customized configuration](https://github.com/thawk/dotspacevim), withith all optional plugins disabled.

https://hub.docker.com/r/thawk/spacevim-base

Based on: https://hub.docker.com/r/thawk/neovim

Will disable all optional layers.

Child containers can put additional configuration into *additional.toml*, that will be appended to *init.toml* before install.

## Usage

```sh
$ docker run -it -v $(pwd):/src thawk/spacevim-base test.cpp
```

```sh
alias dnvim='docker run -it -v $(pwd):/src thawk/spacevim-base "$@"'
```

