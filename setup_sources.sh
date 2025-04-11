#!/bin/bash

# 函数用于为Debian配置APT源
configure_debian_sources() {
    echo "配置Debian的APT源..."
    cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ $1 main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ $1 main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security $1-security main contrib non-free non-free-firmware
deb-src https://security.debian.org/debian-security $1-security main contrib non-free non-free-firmware

deb https://deb.debian.org/debian/ $1-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ $1-updates main contrib non-free non-free-firmware

deb https://deb.debian.org/debian/ $1-backports main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ $1-backports main contrib non-free non-free-firmware
EOF
}

# 函数用于为Ubuntu配置APT源
configure_ubuntu_sources() {
    echo "配置Ubuntu的APT源..."
    cat > /etc/apt/sources.list << EOF
deb https://archive.ubuntu.com/ubuntu/ $1 main restricted universe multiverse
deb-src https://archive.ubuntu.com/ubuntu/ $1 main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ $1-updates main restricted universe multiverse
deb-src https://archive.ubuntu.com/ubuntu/ $1-updates main restricted universe multiverse

deb https://archive.ubuntu.com/ubuntu/ $1-backports main restricted universe multiverse
deb-src https://archive.ubuntu.com/ubuntu/ $1-backports main restricted universe multiverse

deb https://security.ubuntu.com/ubuntu/ $1-security main restricted universe multiverse
deb-src https://security.ubuntu.com/ubuntu/ $1-security main restricted universe multiverse
EOF
}

# 检测系统类型和版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_CODENAME

    if [ -z "$VER" ]; then
        # 如果VERSION_CODENAME为空，根据版本号设置
        if [ "$OS" = "debian" ]; then
            case $VERSION_ID in
                10) VER="buster" ;;
                11) VER="bullseye" ;;
                12) VER="bookworm" ;;
                *) echo "不支持的Debian版本。" && exit 1 ;;
            esac
        elif [ "$OS" = "ubuntu" ]; then
            case $VERSION_ID in
                20.04) VER="focal" ;;
                22.04) VER="jammy" ;;
                24.04) VER="noble" ;;
                *) echo "不支持的Ubuntu版本。" && exit 1 ;;
            esac
        fi
    fi

    if [ "$OS" = "debian" ]; then
        configure_debian_sources $VER
    elif [ "$OS" = "ubuntu" ]; then
        configure_ubuntu_sources $VER
    else
        echo "不支持的操作系统。"
        exit 1
    fi
else
    echo "无法检测操作系统。"
    exit 1
fi

# 更新APT索引并安装curl
apt update -y
apt install -y curl