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

# Set work directory
WORKDIR /root

# Copy source code
COPY . /root

# Setup scripts
RUN chmod +x /root/bootstrap

# Make sure everything is in Unix format
RUN dos2unix /root/stages/**/* /root/stages/env.d/* /root/bootstrap /root/targets/* /root/patches/**/* sources/*.txt files/*

#RUN cd sources && wget -c -i SOURCELIST.txt || true