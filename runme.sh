#!/bin/sh
rm -f $2
touch $2
./compiler $1 > $2