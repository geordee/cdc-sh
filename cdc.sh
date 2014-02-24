#!/bin/bash
# a simple shell script for change data capture
# copyright (c) 2014 Geordee Naliyath

# initialize
wdir=.       # work directory

isep="|"     # field separator for input files
osep="|"     # field separator for the output file
wsep="~"     # a different field separator for working files
# note: choose separators not conflicting with data

if [[ ${#} -lt 3 ]]; then
  echo "Usage: cdc.sh <new-file> <old-file> <key-list>"
  echo "       <new-file>: File with new and updated records"
  echo "       <old-file>: File used as comparison, with the same structure as <new-file>"
  echo "       <key-list>: Comma-separated value for the positions of primary keys"
  exit 1
fi

# process arguments
new=${1}
old=${2}
keys=${3}

fnew=`basename ${new}`.new
fold=`basename ${old}`.old
fcdc=`basename ${new}`.cdc

# step 1: build key

  # file 1:
  cut -d${isep} -f${keys} ${new} > ${wdir}/${fnew}.keys
  paste -d${wsep} ${wdir}/${fnew}.keys ${new} > ${wdir}/${fnew}.keyed

  # file 2:
  cut -d${isep} -f${keys} ${old} > ${wdir}/${fold}.keys
  paste -d${wsep} ${wdir}/${fold}.keys ${old} > ${wdir}/${fold}.keyed

# step 2: sort files

  # file 1:
  sort -t${wsep} -k1 ${wdir}/${fnew}.keyed > ${wdir}/${fnew}.sorted
  # file 2:
  sort -t${wsep} -k1 ${wdir}/${fold}.keyed > ${wdir}/${fold}.sorted

# step 3: join on key, suppress matching keys (inserts)
  join -t${wsep} -v1 -11 -21 ${wdir}/${fnew}.sorted ${wdir}/${fold}.sorted > ${wdir}/${fnew}.inserts

# step 4: reverse join on key, suppress matching keys (deletes)
  join -t${wsep} -v1 -11 -21 ${wdir}/${fold}.sorted ${wdir}/${fnew}.sorted > ${wdir}/${fnew}.deletes

# step 5: join on key with inserts, suppress matching keys (minus inserts)
  join -t${wsep} -v1 -11 -21 ${wdir}/${fnew}.sorted ${wdir}/${fnew}.inserts > ${wdir}/${fnew}.noinserts

# step 6: compare with new, suppress matching lines (updates)
  comm -23 ${wdir}/${fnew}.noinserts ${wdir}/${fold}.sorted > ${wdir}/${fnew}.updates

# step 7: remove key from each output
  cut -d${wsep} -f2- ${wdir}/${fnew}.inserts | \
    awk -v isep=${isep} -v osep=${osep} 'BEGIN {FS=isep; OFS=osep}{$1=$1; print $0, "I"}' >  ${fcdc}
  cut -d${wsep} -f2- ${wdir}/${fnew}.deletes | \
    awk -v isep=${isep} -v osep=${osep} 'BEGIN {FS=isep; OFS=osep}{$1=$1; print $0, "D"}' >> ${fcdc}
  cut -d${wsep} -f2- ${wdir}/${fnew}.updates | \
    awk -v isep=${isep} -v osep=${osep} 'BEGIN {FS=isep; OFS=osep}{$1=$1; print $0, "U"}' >> ${fcdc}

# step 9: cleanup
  rm -f ${wdir}/${fnew}.keys
  rm -f ${wdir}/${fold}.keys
  rm -f ${wdir}/${fnew}.keyed
  rm -f ${wdir}/${fold}.keyed
  rm -f ${wdir}/${fnew}.sorted
  rm -f ${wdir}/${fold}.sorted
  rm -f ${wdir}/${fnew}.inserts
  rm -f ${wdir}/${fnew}.updates
  rm -f ${wdir}/${fnew}.deletes
  rm -f ${wdir}/${fnew}.noinserts

# todo:
  # validate arguments
  # add error handling to every step
