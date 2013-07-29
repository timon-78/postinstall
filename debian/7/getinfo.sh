#!/bin/bash
echo $(cat /tmp/config.txt | grep $1 | cut -d= -f2)