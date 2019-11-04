FROM ubuntu:18.04

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -yq \
    sudo \
    cowsay \
    git \
    git-gui \
    tmux \
    wget \
    zsh \
    vim \
    fonts-powerline \
    gitk \
    meld \
    tree \
    psmisc \
    mc \
    screen \
    locales \
    gnupg

RUN mkdir -p /home/developer/sdl

# Setup locale
RUN locale-gen en_US.UTF-8

# ZSH config
#RUN git clone https://github.com/robbyrussell/oh-my-zsh /opt/oh-my-zsh && \
#    cp /opt/oh-my-zsh/templates/zshrc.zsh-template .zshrc && \
#    cp -r /opt/oh-my-zsh .oh-my-zsh && \
#    cp /opt/oh-my-zsh/templates/zshrc.zsh-template /home/developer/.zshrc && \
#    cp -r /opt/oh-my-zsh /home/developer/.oh-my-zsh && \
#    sed  "s/robbyrussell/bira/" -i /home/developer/.zshrc && \
#    echo "PROMPT=\$(echo \$PROMPT | sed 's/%m/%f\$IMAGE_NAME/g')" >> /home/developer/.zshrc && \
#    echo "RPROMPT=''" >> /home/developer/.zshrc

# Tmux config
WORKDIR /opt
RUN git clone https://github.com/gpakosz/.tmux.git && \
    echo "set-option -g default-shell /bin/zsh" >> .tmux/.tmux.conf
COPY onStartup/tmux_setup.sh /opt/startup/

# Sublime instalation
ARG SUBLIME_BUILD="${SUBLIME_BUILD:-3207}"
RUN wget --no-check-certificate  https://download.sublimetext.com/sublime-text_build-"${SUBLIME_BUILD}"_amd64.deb --no-check-certificate && \
    dpkg -i sublime-text_build-"${SUBLIME_BUILD}"_amd64.deb

RUN wget --no-check-certificate -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
RUN echo "deb http://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
RUN apt update && apt install -y sublime-merge

# SSH setup
RUN apt update && apt install -yq \
    openssh-server \
    libmysqlclient-dev
#COPY onStartup/ssh_setup.sh /opt/startup/

#Build
RUN apt update && apt install -yq \
    automake \
    cmake \
    cmake-curses-gui \
    ccache \
    clang-format-6.0 \
    g++ \
    gdb \
    lcov \
    html2text \
    cppcheck

RUN apt-get update && apt-get install sudo wget apt-transport-https gnupg2 -y
RUN echo "deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-3.6 main" >> /etc/apt/sources.list \
       && wget http://apt.llvm.org/llvm-snapshot.gpg.key \
       && apt-key add llvm-snapshot.gpg.key \
       && apt-get update \
       && apt-get install clang-3.6 -y

# SDL build evironment
RUN apt update && apt install -yq \
    libexpat1-dev \
    libssl1.0-dev \
    libbluetooth3 \
    libbluetooth-dev \
    libudev-dev \
    libusb-1.0 \
    bluez-tools \
    sqlite3 \
    libsqlite3-dev \
    build-essential \
    python-dev \
    autotools-dev \
    libicu-dev \
    libbz2-dev

# ATF build environment
RUN apt update && apt install -yq \
    liblua5.2 \
    libxml2 \
    libxml2-dev \
    lua-lpeg \
    qt5-default \
    libqt5webkit5-dev \
    libqt5websockets5-dev \
    net-tools
#COPY onStartup/enable_core_dumps.sh /opt/startup/

ENV QMAKE /usr/bin/qmake

WORKDIR /home/developer
#COPY scripts/qt-installer-noninteractive.qs /tmp/qt-installer-noninteractive.qs
RUN wget http://download.qt.io/official_releases/qt/5.12/5.12.3/qt-opensource-linux-x64-5.12.3.run && \
    chmod +x qt-opensource-linux-x64-5.12.3.run && \
    ./qt-opensource-linux-x64-5.12.3.run  --script /tmp/qt-installer-noninteractive.qs -platform minimal && \
    rm qt-opensource-linux-x64-5.12.3.run

#COPY onStartup/qt_creator_configs.sh /opt/startup/
RUN ln -s /home/developer/Qt/Tools/QtCreator/bin/qtcreator /usr/bin/qtcreator

# distcc
RUN apt update && apt install -yq distcc \
    distccmon-gnome \
    python.tornado
RUN mkdir -p /home/developer/.distcc
#COPY onStartup/distccd_setup.sh /opt/startup/

RUN mkdir -p  /home/developer/.git-templates/hooks/

EXPOSE 3632
#COPY onStartup/entrypoint.sh /usr/bin/
WORKDIR /home/developer
ENTRYPOINT ["/bin/bash", "-e", "/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
