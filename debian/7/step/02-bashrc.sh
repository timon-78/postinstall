#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [ ${#1} -eq 0 ]; 
then
	echo "no user specified, continue"
else
	sed -i -e 's/#alias/alias/' /home/${1}/.bashrc
	sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/' /home/${1}/.bashrc
	cp /home/${1}/.bashrc /root/
fi