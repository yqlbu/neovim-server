#!/usr/bin/env bash

set -e

hex()
{
  openssl rand -hex 8
}

echo -e "==> [INFO] Bootstraping container .."

COMMAND="yarn start"
HOME=/home/$USER

if [ "$PKGS" != "none" ]; then
  set +e
  /usr/bin/apt-get update
  /usr/bin/apt-get install -y $PKGS
  /usr/bin/apt-get clean
  /bin/rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  set -e
fi

if [ "${ADDUSER}" == "true" ]; then
  sudo=""
  if [ "${SUDO}" == "true" ]; then
    sudo="-G sudo"
  fi
  if [ -z "$(getent group ${USER})" ]; then
    /usr/sbin/groupadd -g ${GID} ${USER}
  fi

  if [ -z "$(getent passwd ${USER})" ]; then
    /usr/sbin/useradd -u ${UID} -g ${GID} -G sudo -s ${SHELL} -d ${HOME} -m ${sudo} ${USER} 
    if [ "${SECRET}" == "password" ]; then
      SECRET=$(hex)
      echo "Autogenerated password for user ${USER}: ${SECRET}"
    fi
    echo "${USER}:${SECRET}" | /usr/sbin/chpasswd
    unset SECRET
  fi
fi

if [ "$CONTAINER" != "wetty" ]; then
  echo -e "==> [INFO] Setting up environment .."
  if grep -Fxq '# BOOTSTRAP ENV' $HOME/.bashrc ; then
    echo "==> [INFO] bashrc already setup, so skipped .."
  else
    echo "# BOOTSTRAP ENV" >> $HOME/.bashrc
    echo "alias ..='cd ..'" >> $HOME/.bashrc && echo "alias ...='cd ../../'" >> /home/$USER/.bashrc
    echo "alias vim='nvim'" >> $HOME/.bashrc
    echo "alias ra='ranger'" >> $HOME/.bashrc
    echo "alias lg='lazygit'" >> $HOME/.bashrc
    echo "export LANG=en_US.UTF-8" >> $HOME/.bashrc
    echo "export EDITOR=nvim" >> $HOME/.bashrc
    echo "export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc
  fi

  if [[ ! -L "$HOME/.config/nvim" && ! -d "$HOME/.config/nvim" ]]; then
    ln -sf /config $HOME/.config
    cp -r /usr/src/app/nvim $HOME/.config/
    cp -r /usr/src/app/nvim/ranger $HOME/.config
    git clone https://github.com/alexanderjeurissen/ranger_devicons $HOME/.config/ranger/plugins/ranger_devicons
    mkdir -p $HOME/.config/jesseduffield
    cp -r /usr/src/app/nvim/lazygit $HOME/.config/jesseduffield/lazygit
  fi

  [[ ! -L "$HOME/workspace" && ! -d "$HOME/workspace" ]] && ln -sf /workspace $HOME/workspace

  echo -e "==> [INFO] Setting up / Updating neovim .."
  nvim --headless +PlugInstall +qall > /dev/null 2>&1

  # echo -e "==> [INFO] Setting up / Updating coc extensions .."
fi

chown -R ${USER}:${GID} ${HOME}
chown -R ${USER}:${GID} /config
chown -R ${USER}:${GID} ${HOME}/.config
chown -R ${USER}:${GID} /workspace
chown -R ${USER}:${GID} ${HOME}/workspace

echo -e "==> [INFO] Starting container .."
if [ "$@" = "wetty" ]; then
  echo "==> [INFO] Executing: ${COMMAND}"
  exec ${COMMAND}
else
  echo "==> [INFO] Not executing: ${COMMAND}"
  echo "==> [INFO] Executing: ${@}"
  exec $@
fi