FROM ubuntu:24.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

ENV TOOLCHAIN_ARCH=x86-64-v3

ENV TOOLCHAIN_TRIPLET=x86_64-buildroot-linux-gnu

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates \
    automake autopoint bc bison expect flex gawk gettext gettext-base \
    build-essential \
    lzip \
    make \
    git \
    curl \
    wget \
    unzip \
    dos2unix \
    nano \
    autoconf \
    libtool \
    texinfo \
    tree \
    python3 \
    rsync \
    libarchive-tools \
    libarchive-dev \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libzstd-dev

RUN update-ca-certificates

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add builder user
RUN groupadd builder \
    && useradd -s /bin/bash -g builder -m -k /dev/null builder \
    && echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'builder:builder' | chpasswd

# Set work directory
WORKDIR /home/builder

# Copy source code
COPY . /home/builder

# Setup scripts
RUN chmod +x ./bootstrap

# Make sure everything is in Unix format
RUN dos2unix ./stages/**/* ./stages/env.d/* ./bootstrap ./targets/* ./patches/**/* sources/*.txt files/*

# Make sure everything is the correct permissions
RUN chown -R builder:builder /home/builder

# Switch to builder user
USER builder
