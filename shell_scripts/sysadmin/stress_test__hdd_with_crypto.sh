#!/bin/bash

set -e

# Since badblocks was originally written to verify floppy disks,
# its design isn’t construed for modern HDD drives. With sizes
# such as 18 TB drives, even the regular tip to use -b 4096 won’t
# help anymore. This is an alternative:

DEVICE_NAME=$1

echo $DEVICE_NAME

if [ -z ${DEVICE_NAME} ]; then
    echo -e "DEVICE_NAME is unset\nUsage example: ./stress_test__hdd_with_crypto.sh /dev/sda1"
    exit 1
else
    echo "Stress testing '$DEVICE_NAME'"
fi

SHORT_NAME=$(echo "${DEVICE_NAME}" | awk -F "/" '{print $NF}')

# Span a crypto layer above the device
sudo cryptsetup open ${DEVICE_NAME} name_${SHORT_NAME} --type plain --cipher aes-xts-plain64

### Fill the now opened decrypted layer with zeroes, which get written as encrypted data:
sudo shred -v -n 0 -z /dev/mapper/name_${SHORT_NAME}

### Compare fresh zeroes with the decrypted layer:
sudo cmp -b /dev/zero /dev/mapper/name_${SHORT_NAME}

sudo cryptsetup close name_${SHORT_NAME}

exit 0