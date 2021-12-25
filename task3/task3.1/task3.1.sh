#!/usr/bin/bash

export NAME=lazarevva
export GROUP=628

PROXY=localhost:3128

# *********************** ВЫПОЛНЕНИЕ ПЕРВОЙ ЧАСТИ *********************** #
chmod +x make_part_one.sh
./make_part_one.sh
sudo cp part1.conf /etc/squid/squid.conf

# перезапуск squid:
sudo service squid restart
sudo service squid status

read -p "Run 'sudo wireshark' and listen 'any' interface, filter by 'tcp', then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1
curl ident.me -x $PROXY -A "$NAME"
curl httpbin.org/get?bio=$NAME -x $PROXY
read -p "Save wireshark capture to $NAME-$GROUP-acl.pcapng, then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1


# *********************** ВЫПОЛНЕНИЕ ВТОРОЙ ЧАСТИ *********************** #
chmod +x make_part_two.sh
./make_part_two.sh
sudo cp part2.conf /etc/squid/squid.conf

# перезапуск squid:
sudo service squid restart
sudo service squid status

read -p "Run 'sudo wireshark' and listen 'any' interface, filter by 'tcp', then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1
curl httpbin.org/ip -x $PROXY
read -p "Save wireshark capture to $NAME-$GROUP-ua.pcapng, then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1

sudo zip $NAME-$GROUP-p3_1.zip $NAME-$GROUP-acl.pcapng $NAME-$GROUP-ua.pcapng
