FROM ubuntu:24.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

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

# Set root password
RUN echo 'root:root' | chpasswd

# Add builder user
RUN groupadd builder \
    && useradd -s /bin/bash -g builder -m builder \
    && echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'builder:builder' | chpasswd

# Set work directory
WORKDIR /home/builder

# Copy source code
COPY . /home/builder

# Setup scripts
RUN chmod +x ./bootstrap

# Run find command to make sure everything is in Unix format
RUN find /home/builder -type f -exec dos2unix {} \;

# Make sure everything is the correct permissions
RUN chown -R builder:builder /home/builder

# Switch to builder user
USER builder
