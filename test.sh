#!/usr/bin/env bash

function check {
    if [[ "$1" != "$2" ]]
    then
        echo "Failed: $1 != $2"
        exit 1
    fi
}

# --
echo long options
source $(./optional.sh --long-with-space ok1 --long-with-equals=ok2)
check ${long_with_space} ok1
check ${long_with_equals} ok2

# --
echo quoted option
source $(./optional.sh -a "ok1 ok2" -b ok3)
check "${a}" "ok1 ok2"
check ${b} ok3

# --
echo single quoted option
source $(./optional.sh -a 'ok1 ok2' -b ok3)
check "${a}" "ok1 ok2"
check ${b} ok3

# --
echo short flags
source $(./optional.sh -a -b)
check ${a} 1
check ${b} 1

# --
echo long flags
source $(./optional.sh --flag1 --flag2)
check ${flag1} 1
check ${flag2} 1

# --
echo only allowed options
source $(ALLOWED="good1 good2" ./optional.sh --good1 ok1 --good2 ok2 --bad no-good)
check ${good1} ok1
check ${good2} ok2
check ${bad} 

# --
echo short options
source $(./optional.sh -s ok1 -t=ok2 -uok3)
check ${s} ok1
check ${t} ok2
check ${u} ok3

# --
echo unnamed options
source $(./optional.sh p1 p2)

check ${POS0} p1
check ${POS1} p2

# --
echo custom prefix
source $(OPTIONAL_POS_PREFIX="custom" ./optional.sh first second)
check ${custom0} first
check ${custom1} second

# --
echo no arguments
tmp_file="$(./optional.sh)"
check "$(cat $tmp_file)" ""

echo "Passed"
