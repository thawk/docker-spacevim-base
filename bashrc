export PS1="\[$(tput setaf 0)\]\[$(tput setab 4)\] \w \[$(tput sgr0)\]\[$(tput setaf 4)\]\[$(tput sgr0)\] "

alias ll='ls -l'
alias ls='ls -G'
alias la='ls -a'
alias ag='ag --color-match 31\;31 --color-line-number 0\;33 --color-path 0\;32'
alias agc='ag --cc --cpp --python --java --vim --go --ruby'
alias agg='agc --ignore 3rd --ignore unittest --ignore testtool'
alias ags='agg --ignore lib'

timestamp() {
    local epoch=
    local subsecs=

    if [[ $# -eq 0 ]]; then
        # Current time
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if type python &> /dev/null; then
                python -c 'from time import time; print(int(round(time() * 1000000)))'
            else
                date +"%s000000"
            fi
        else
            date +"%s%N"
        fi
    else
        # Cnvert time from parameters
        while [ $# -gt 0 ]
        do
            ts=$1
            if [[ $ts -lt 253402300800 ]]; then
                epoch=$ts
                subsecs=
            elif [[ $ts -lt 253402300800000 ]]; then
                epoch=$((ts / 1000))
                subsecs=.$(printf "%03d" $((ts % 1000)))
            elif [[ $ts -lt 64060588800000000 ]]; then
                epoch=$((ts / 1000000))
                subsecs=.$(printf "%06d" $((ts % 1000000)))
            else
                # FILETIME, 100ns count from 1601-01-01, 109205 days before 1900-01-01,
                # 25569 more days before 1970-01-01
                epoch=$((ts / 10000000 - (109205 + 25569) * 24 * 60 * 60))
                subsecs=.$(printf "%07d" $((ts % 10000000)))
            fi

            if [[ "$OSTYPE" == "darwin"* ]]; then
                date -u -r ${epoch} +"%Y-%m-%d %T"${subsecs}" UTC"
            else
                date --utc -d @${epoch} +"%Y-%m-%d %T"${subsecs}" UTC"
            fi

            shift
        done
    fi
}

(type ts &> /dev/null) || alias ts=timestamp

function = {
    python - << EOD
from math import *
from struct import pack
result=($@)
if isinstance(result, int):
    count=int(ceil(len('{:b}'.format(result))/8.0))
    bytes=pack(">Q",result)[8-count:]
    if isinstance(bytes[0], type('c')):
        bytes=map(ord, bytes)
    print('    '.join((
    '{0}'.format(result),
    '0x{0:0>{1}X}'.format(result, count*2),
    '0o{0:0>{1}o}'.format(result, 1),
    '0b{0:0>{1}b}'.format(result, count*8),
    ''.join([chr(c) if c>=0x20 and c<=0x7e else '.' for c in bytes]),
    )))
else:
    print(result)
EOD
}

0b36() {
    while [ ! -z "$1" ]
    do
        echo $((36#$1))
        shift
    done
}

p36() {
    b36arr=($(echo {0..9} {A..Z}))
    while [ ! -z "$1" ]
    do
        for i in $(echo "obase=36; $1" | bc)
        do
            echo -n ${b36arr[${i#0}]}
        done
        echo
        shift
    done
}

_num_conv() {
    if [ $# -eq 0 ]
    then    # 至少需要一个参数以指定进制
        echo "Need at least one parameter" > /dev/stderr
        return
    else
        base=$1
        shift
        if [ $# -eq 0 ]
        then    # 从stdin读取
            while read i
            do
                = "${base}${i}"
            done
        else    # 从命令行读取
            while [ ! -z "$1" ]
            do
                = "${base}${1}"
                shift
            done
        fi
    fi | column -t
}

num() {
    _num_conv "" "$@"
}

0d() {
    _num_conv "" "$@"
}

0x() {
    _num_conv 0x "$@"
}

0b() {
    _num_conv 0b "$@"
}

0o() {
    _num_conv 0o "$@"
}
