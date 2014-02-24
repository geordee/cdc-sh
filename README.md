# CDC.sh

A very simple shell script for change data capture.
Use this as an inspiration to build something better.


## Usage

    Usage: cdc.sh <new-file> <old-file> <key-list>
           <new-file>: File with new and updated records
           <old-file>: File used as comparison, with the same structure as <new-file>
           <key-list>: Comma-separated value for the positions of primary keys


## Configuration

Set the following variables in the script

* wdir (work directory)
* isep (field separator for input files)
* osep (field separator for the output file)
* wsep (field separator for working files, different from isep)

Please choose separators not conflicting with data. Escaping is not supported.
