#!/bin/sh

# DEPENDENCIES: ping, gnuplot, bc, awk, grep

file_tmp_proc_numb=/tmp/plotping.pid
file_tmp_ping_data=/tmp/plotping.ping.dat
file_tmp_plot_data=/tmp/plotping.plot.dat
file_tmp_treshhold=/tmp/plotping.treshhold.dat
file_tmp_treshhold_plot_increment=/tmp/plotping.treshhold_plot_increment.dat

command=$1
shift

domain="www.google.com"
last_shown_ping_number=10
while test $# -gt 0; do
    case "$1" in
        -d)
            shift
			domain="$1"
            shift
			;;
        -n)
            shift
            if [[ $1 =~ ^-?[0-9]+$ ]]; then
                last_shown_ping_number=$1
            else
                echo "Wrong value for parameter '-n'. Value should be an integer"
                exit
            fi
            shift
            ;;
        *)
            shift
            ;;
    esac
done


function check_script_dependencies() {
    command -v ping >/dev/null 2>&1 || { echo >&2 "A command 'ping' is not installed.  Aborting."; exit 1; }
    command -v grep >/dev/null 2>&1 || { echo >&2 "A command 'grep' is not installed.  Aborting."; exit 1; }
    command -v awk >/dev/null 2>&1 || { echo >&2 "A command 'awk' is not installed.  Aborting."; exit 1; }
    command -v gnuplot >/dev/null 2>&1 || { echo >&2 "A command 'gnuplot' is not installed.  Aborting."; exit 1; }
    command -v bc >/dev/null 2>&1 || { echo >&2 "A command 'bc' is not installed.  Aborting."; exit 1; }
}

function show_remaining_pings() {
    echo "List of remaining 'ping' processes which you could consider to stop (COMMAND: plotping stop-all)":
    ps aux | grep -i ping | grep -v 'grep -i ping' | grep -v 'plotping'
}

function rm_tmp_files() {
    if [ -f "$file_tmp_proc_numb" ]; then
        rm "$file_tmp_proc_numb"
    fi
    if [ -f "$file_tmp_ping_data" ]; then
        rm "$file_tmp_ping_data"
    fi
    if [ -f "$file_tmp_plot_data" ]; then
        rm "$file_tmp_plot_data"
    fi
    if [ -f "$file_tmp_treshhold" ]; then
        rm "$file_tmp_treshhold"
    fi
    if [ -f "$file_tmp_treshhold_plot_increment" ]; then
        rm "$file_tmp_treshhold_plot_increment"
    fi
}

function generate_plot_data() {
    cat "$file_tmp_ping_data" 2>/dev/null | awk -F [=\ ] {'print $(NF-1)'} | grep -E "[0-9]" > "$file_tmp_plot_data"
}

function display_treshholds() {
    if [ -f "$file_tmp_treshhold" ]; then
        t25=`awk '{ print $1 }' "$file_tmp_treshhold"`
        t100=`awk '{ print $2 }' "$file_tmp_treshhold"`
        t300=`awk '{ print $3 }' "$file_tmp_treshhold"`
        t500=`awk '{ print $4 }' "$file_tmp_treshhold"`
        tRest=`awk '{ print $5 }' "$file_tmp_treshhold"`
        all=`awk '{ print $6 }' "$file_tmp_treshhold"`
    else
        t25=0
        t100=0
        t300=0
        t500=0
        tRest=0
        all=0
    fi

    tail -n "+$((all+1))" "$file_tmp_plot_data" > "$file_tmp_treshhold_plot_increment"
    while read t; do
        if [ $(bc <<< "$t >= 0") -eq 1 -a $(bc <<< "$t <= 25") -eq 1 ]; then
            t25=$((t25+1));
        elif [ $(bc <<< "$t > 25") -eq 1 -a $(bc <<< "$t <= 100") -eq 1 ]; then
            t100=$((t100+1));
        elif [ $(bc <<< "$t > 100") -eq 1 -a $(bc <<< "$t <= 300") -eq 1 ]; then
            t300=$((t300+1));
        elif [ $(bc <<< "$t > 300") -eq 1 -a $(bc <<< "$t <= 500") -eq 1 ]; then
            t500=$((t500+1));
        else
            tRest=$((tRest+1));
        fi
        all=$((all+1));
    done < "$file_tmp_treshhold_plot_increment"
    echo "$t25 $t100 $t300 $t500 $tRest $all" > "$file_tmp_treshhold"

    if [ $all -eq 0 ]; then
        p25=0
        p100=0
        p300=0
        p500=0
        pRest=0
    else
        p25=`bc -l <<< "scale=2; $t25*100/$all"`
        p100=`bc -l <<< "scale=2; $t100*100/$all"`
        p300=`bc -l <<< "scale=2; $t300*100/$all"`
        p500=`bc -l <<< "scale=2; $t500*100/$all"`
        pRest=`bc -l <<< "scale=2; $tRest*100/$all"`
    fi

    echo "THRESHOLDS"
    echo "[0-25: $p25%]    [25-100: $p100%]    [100-300: $p300%]    [300-500: $p500%]    [500+: $pRest%]"
}

function plot_ping() {
    gnuplot -e "set term dumb; set ylabel 'ms'; set xlabel 'Number of pings'; plot '$file_tmp_plot_data' notitle"
}

function show_latest_pings() {
    echo "LATEST $last_shown_ping_number PINGS"
    tail -n $last_shown_ping_number "$file_tmp_ping_data"
}

case "$command" in
    'start')
        check_script_dependencies
        if [ -f "$file_tmp_proc_numb" ] && kill -0 `cat "$file_tmp_proc_numb"` > /dev/null 2>&1; then
            echo 'Tracking process is already started.'
        else
            rm_tmp_files
            ping "$domain" > "$file_tmp_ping_data" 2>/dev/null &
            echo $! > "$file_tmp_proc_numb"
            echo "Ping process id:" `cat "$file_tmp_proc_numb"`
        fi
        ;;
    'show')
        check_script_dependencies
        if [ -f "$file_tmp_ping_data" ]; then
            echo
            generate_plot_data
            display_treshholds
            plot_ping
            show_latest_pings
            exit
        else
            echo 'Tracking process is not started (COMMAND: plotping start)'
        fi
        ;;
    'stop')
        if [ -f "$file_tmp_proc_numb" ]; then
            kill -9 `cat "$file_tmp_proc_numb"` 2>/dev/null
            echo 'Done'
        else
            echo 'No pid file have been found.'
            echo 'Terminated.'
        fi
        show_remaining_pings
        rm_tmp_files
        ;;
    'stop-all')
        read -p "It will kill all 'ping' processes. Are you sure? [y/n]" -n 1 -r
        echo # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            killall -9 ping 2>/dev/null
            rm_tmp_files
            show_remaining_pings
        else
            echo 'Terminated'
        fi
        ;;
    'clean')
        rm_tmp_files
        ;;
     *|-h|--help)
        cat << USAGE
Usage: plotping COMMAND [OPTIONS]

    COMMAND
     start              Start process of tracking ping
     show               Plot and displays inforation about ping
     stop               Stop process of tracking ping
     stop-all           Stop all 'ping' in system (in case when 'stop' COMMAND fails)
     clean              Removes all temporarliy files (stored in /tmp). Files
                        are removed as well during COMMAND 'stop' and 'stop-all'
     help|--help|-h     This help

    OPTIONS
     -d                 Domain name which pings will be tracked (default: www.google.com).
                        Usable in COMMAND 'start'.
     -n                 Number of last shown pings
                        Usable in COMMAND 'show'.

Example
    plotping start -d www.google.pl
    watch -n 5 plotping show -n 5
    plotping stop

About
    Plotping is a simple script which tracks ping times and plot them at terminal.
    In addition it calculates tresholds.

Note
    Threshold are calculated incrementally. It can takes time to invoke a COMMAND
    'show' after longer lack of usage.
    Plotping does not count pings which reached a timeout.
    It also does not count pings in equal time intervals.

Author
    Marcin Rogacki <rogacki.m@gmail.com>
    https://github.com/marcinrogacki/plotping.git
USAGE
        exit
        ;;
esac

echo 'Done. Exit'
