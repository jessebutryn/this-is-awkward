#!/usr/bin/env bash

random_man () {
    local _num=$1
    case $_num in
        1)  printf 'dell\n';;
        2)  printf 'supermicro\n';;
        3)  printf 'asrockrack\n';;
    esac
}

printf 'UUID,IP ADDRESS,MANUFACTURER,BIOS VERSION\n'

for ((i=0;i<=100;i++)); do
    uuid=$(uuidgen)
    ip="$((RANDOM%255)).$((RANDOM%255)).$((RANDOM%255)).$((RANDOM%255))"
    man=$(random_man "$((RANDOM%3+1))")
    bios="$((RANDOM%2+1)).$((RANDOM%2+1))0"
    printf '%s,%s,%s,%s\n' "$uuid" "$ip" "$man" "$bios"
done
