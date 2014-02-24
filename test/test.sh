#!/bin/bash
# test cdc.sh

../cdc.sh new.txt old.txt "1,2,3"
diff -u ref.txt.cdc new.txt.cdc
