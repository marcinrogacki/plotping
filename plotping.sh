#!/bin/sh

file_tmp_proc_numb=/tmp/plotping.pid
file_tmp_ping_data=/tmp/plotping.ping.dat
file_tmp_plot_data=/tmp/plotping.plot.dat

function show_remaining_pings() {
	echo "Remaining pings":
	ps aux | grep -i ping | grep -v 'grep -i ping'
}

function rm_tmp_files() {
    rm "$file_tmp_proc_numb"
    rm "$file_tmp_ping_data"
    rm "$file_tmp_plot_data"
}

command=$1
shift
case $command in
    'track-start')
		ping www.google.com > "$file_tmp_ping_data" 2>/dev/null &
        echo $! > "$file_tmp_proc_numb"
        echo "Ping process id:" `cat "$file_tmp_proc_numb"`
        ;;
    'track-stop')
        kill -9 `cat "$file_tmp_proc_numb"` 2>/dev/null
        rm_tmp_files
        show_remaining_pings
        ;;
    'track-stop-all')
        killall -9 ping 2>/dev/null
        rm_tmp_files
        show_remaining_pings
        ;;
    'show')
        # TODO: check if ping.dat exists, otherwies info to run `run.sh track`
		cat "$file_tmp_ping_data" 2>/dev/null | awk -F [=\ ] {'print $(NF-1)'} | grep -E "[0-9]" > "$file_tmp_plot_data"
        gnuplot -e "set term dumb; set ylabel 'ms'; set xlabel 'Number of pings'; plot '$file_tmp_plot_data' notitle"
		;;
    *|-h|--help)
        echo 'Help soon...'
        ;;
esac

