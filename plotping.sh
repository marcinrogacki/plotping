#!/bin/sh

file_tmp_proc_numb=/tmp/plotping.pid
file_tmp_ping_data=/tmp/plotping.ping.dat
file_tmp_plot_data=/tmp/plotping.plot.dat

function show_remaining_pings() {
    echo "List of remaining 'ping' processes which you could consider to stop (command: plotping stop-all)":
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
}

command=$1
shift
case $command in
    'start')
        if [ -f "$file_tmp_proc_numb" ] && kill -0 `cat "$file_tmp_proc_numb"` > /dev/null 2>&1; then
            echo 'Tracking process is already started.'
        else
            rm_tmp_files
            ping www.google.com > "$file_tmp_ping_data" 2>/dev/null &
            echo $! > "$file_tmp_proc_numb"
            echo "Ping process id:" `cat "$file_tmp_proc_numb"`
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
    'show')
        if [ -f "$file_tmp_ping_data" ]; then
            cat "$file_tmp_ping_data" 2>/dev/null | awk -F [=\ ] {'print $(NF-1)'} | grep -E "[0-9]" > "$file_tmp_plot_data"
            gnuplot -e "set term dumb; set ylabel 'ms'; set xlabel 'Number of pings'; plot '$file_tmp_plot_data' notitle"
            echo 'Statistics'
            echo '0-25      :   13%'
            echo '25-150    :   25%'
            echo '150-300   :   10%'
            echo '300-500   :   2%'
            echo '500-1000+ :   1%'
            exit
        else
            echo 'Tracking process is not started (command: plotping start)'
        fi
		;;
    *|-h|--help)
        echo 'Help soon...'
        ;;
esac

echo # move to a new line
echo 'Exit'
