FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV TIMEZONE=UTC

ENV LC_ALL=POSIX

ENV LANGUAGE=POSIX

RUN touch .dockerenv

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE >/etc/timezone

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates \
    autoconf automake autopoint \
    bc bison expect flex gawk gettext gettext-base \
    binutils-dev libelf-dev \
    build-essential \
    curl \
    dos2unix \
    git \
    gperf \
    libacl1-dev \
    libarchive-dev \
    libarchive-tools \
    libbison-dev \
    libconfig++-dev \
    libconfig-dev \
    libssl-dev \
    libtool \
    libzstd-dev \
    lzip \
    make \
    nano \
    pkg-config \
    python3 \
    qemu-user-static \
    rsync \
    sudo \
    texinfo \
    texlive-base \
    tree \
    unzip \
    wget \
    zlib1g-dev

RUN update-ca-certificates

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Point dash to bash
RUN ln -sf /bin/bash /bin/sh

# Set root password
RUN echo 'root:root' | chpasswd

# Add builder user
RUN groupadd builder \
    && useradd -s /bin/bash -g builder -m builder \
    && echo 'builder ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers \
    && echo 'builder:builder' | chpasswd

# Set work directory
WORKDIR /home/builder

# Copy source code
COPY . /home/builder

# Setup scripts
RUN chmod +x ./bootstrap ./stages/**/* ./utils/*

# Run find command to make sure everything is in Unix format
RUN find /home/builder -type f -exec dos2unix {} \;

# More setup for builder user
RUN echo "set +h" >> /home/builder/.bashrc
RUN echo "umask 022" >> /home/builder/.bashrc
RUN echo "hash -r >/dev/null 2>&1 || true" >>/home/builder/.bashrc

# Make sure everything is the correct permissions
RUN chown -R builder:builder /home/builder

# Switch to builder user
USER builder
