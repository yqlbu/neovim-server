FROM hikariai/wetty:latest

ENV TZ=America/LosAngeles \
    PORT=3000 \
    UID=998 \
    GID=998 \
    USER=guest \
    ADDUSER=true \
    SECRET=password \
    SHELL=/bin/bash \
    SUDO=false \
    SSL=false \
    CONTAINER=neovim-server

RUN sudo add-apt-repository ppa:neovim-ppa/unstable -y
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    wget python3-pip golang neovim ranger
RUN ln -s /usr/bin/pip3 /usr/bin/pip && \
    ln -s /usr/bin/python3 /usr/bin/python && cp /usr/bin/python3 /usr/local/bin/
RUN pip install -U pip && pip install -U \
    pynvim neovim-remote
RUN wget https://github.com/wfxr/code-minimap/releases/download/v0.4.3/code-minimap_0.4.3_amd64.deb && \
    sudo dpkg -i code-minimap_0.4.3_amd64.deb && rm -rf code-minimap_0.4.3_amd64.deb
RUN npm install -g neovim vim-node-rpc
RUN sudo apt-get clean && \
    rm -rf /var/lib/apt/list/* /tmp/* /var/tmp/*

WORKDIR /usr/src/app

EXPOSE 3000

ADD ./bootstrap.sh /usr/local/sbin
COPY ./nvim /usr/src/app/nvim

ENTRYPOINT [ "bootstrap.sh" ]
CMD [ "wetty" ]