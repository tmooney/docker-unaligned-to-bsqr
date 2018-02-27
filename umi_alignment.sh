#!/bin/bash

set -o pipefail
set -o errexit

if [ $# -ne 3 ]
then
    echo "Usage: $0 unaligned.bam reference.fa cores"
    exit 1
fi

BAM="$1"
REFERENCE="$2"
CORES="$3"

/usr/bin/java -Xmx1g -jar /opt/picard/picard.jar SamToFastq \
    "I=$BAM" CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=X \
    CLIPPING_MIN_LENGTH=36 INCLUDE_NO_PF_READS=true F=/dev/stdout \
    INTERLEAVE=true \
 | bwa mem -p -t "$cores" "$reference" /dev/stdin \
 | /usr/bin/java -Xmx4g -jar /opt/picard/picard.jar MergeBamAlignment \
    "UNMAPPED=$bam" ALIGNED=/dev/stdin OUTPUT=/dev/stdout "REFERENCE_SEQUENCE=$reference" \
    CLIP_ADAPTERS=false VALIDATION_STRINGENCY=silent CREATE_INDEX=true \
    EXPECTED_ORIENTATIONS=FR MAX_GAPS=-1 SORT_ORDER=coordinate \
    ALIGN_PROPER_PAIR_FLAGS=false
