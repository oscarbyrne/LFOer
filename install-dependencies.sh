#!/bin/bash -eE

ARDUINO_CLI_DATA=/usr/share/arduino-cli
SIMAVR_DATA=/usr/share/simavr

apt update
apt install -y build-essential \
              libelf-dev \
              avr-libc \
              gcc-avr \
              freeglut3-dev \
              libncurses5-dev \
              pkg-config

rm -rf "${ARDUINO_CLI_DATA}"
mkdir "${ARDUINO_CLI_DATA}"
(
  cd "${ARDUINO_CLI_DATA}"
  curl -L https://github.com/arduino/arduino-cli/releases/download/0.5.0/arduino-cli_0.5.0_Linux_64bit.tar.gz -o arduino-cli.tar.gz
  tar -xvzf arduino-cli.tar.gz
)
ln -sf "${ARDUINO_CLI_DATA}"/arduino-cli /usr/local/bin/arduino-cli

rm -rf "${SIMAVR_DATA}"
git clone https://github.com/buserror/simavr.git "${SIMAVR_DATA}"
(
  cd "${SIMAVR_DATA}"
  make
)
ln -sf "${SIMAVR_DATA}"/simavr/run_avr /usr/local/bin/run_avr

arduino-cli core update-index
arduino-cli core install arduino:avr
