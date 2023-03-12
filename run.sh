#!/bin/bash -eE

# The built-in LED is on PIN13
# To determine the register and bit mask use this reference: https://arbaranwal.github.io/tutorial/2017/06/23/atmega328-register-reference.html#ddrx-portx-and-pinx
# In this case we want the PORTB register, and use a bitmask to select GPIO-13 only
# The bitmask we use is 100000 which is 0x20 in hex
# Binary to Hex conversion is useful: https://www.rapidtables.com/convert/number/hex-to-binary.html

usage="Usage: $(basename "$0") [options] arduino_sketch

where:
  -h              Show this help text
  -o name         Set the name of the output VCD file"

while getopts 'o:h' flag; do
  case ${flag} in
    o) 
        output_name=${OPTARG}
        ;;
    h) 
        echo "${usage}"
        exit
        ;;
    *) 
        echo "${usage}" >&2
        exit 1
        ;;
  esac
done

shift $((${OPTIND} - 1))
input_sketch=$1

if [[ ! -f "${input_sketch}" || "${input_sketch}" != *.ino ]]; then
    echo "${usage}" >&2
    exit 1
fi

if [[ -z "${output_name}" ]]; then
    output_name="$(basename "${input_sketch}" .ino)"
fi

input_sketch="$(realpath "${input_sketch}")"
output_file=""$(pwd)"/"${output_name}".vcd"

temp_dir="$(mktemp -d)"
trap "rm -rf $temp_dir" EXIT

(
  cd $temp_dir

  echo "Compiling sketch..."
  arduino-cli compile -b arduino:avr:uno \
                      -o firmware \
                      "${input_sketch}"

  echo "Running AVR..."
  run_avr -m atmega328 \
          -f 16000000 \
          -at led=trace@0x25/0x20 \
          -o "${output_file}" \
          ./firmware.elf
)