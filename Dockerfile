FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates \
    autoconf \
    automake autopoint bc bison expect flex gawk gettext gettext-base \
    build-essential \
    curl \
    dos2unix \
    git \
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
    rsync \
    texinfo \
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

# Clear hashing for builder user
RUN echo "hash -r >/dev/null 2>&1 || true" >>/home/builder/.bashrc

# Set work directory
WORKDIR /home/builder

# Copy source code
COPY . /home/builder

# Setup scripts
RUN chmod +x ./bootstrap ./stages/**/*

# Run find command to make sure everything is in Unix format
RUN find /home/builder -type f -exec dos2unix {} \;

# Make sure everything is the correct permissions
RUN chown -R builder:builder /home/builder

# Switch to builder user
USER builder
