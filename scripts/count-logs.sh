#!/bin/bash

DATE=$(date)
LOGFILE=~/scripts/log-report.log

SYSLOG=/var/log/syslog
AUTHLOG=/var/log/auth.log
KERNLOG=/var/log/kern.log

print_section() {
    echo ""
    echo "==============================="
    echo " $1"
    echo "==============================="
}

generate_report() {

    echo "==============================="
    echo " Log Analysis Report"
    echo " $DATE"
    echo "==============================="

    print_section "Total Line Count"
    for LOG in "$SYSLOG" "$AUTHLOG" "$KERNLOG"; do
        if [ -f "$LOG" ]; then
            COUNT=$(wc -l < "$LOG")
            echo "$LOG : $COUNT lines"
        else
            echo "$LOG : file not found"
        fi
    done

    print_section "Last 10 ERROR lines in syslog"
    if [ -f "$SYSLOG" ]; then
        grep -i "error" "$SYSLOG" | tail -n 10
        if [ $? -ne 0 ]; then
            echo "No errors found."
        fi
    fi

    print_section "Last 10 ERROR lines in kern.log"
    if [ -f "$KERNLOG" ]; then
        grep -i "error" "$KERNLOG" | tail -n 10
        if [ $? -ne 0 ]; then
            echo "No errors found."
        fi
    fi

    print_section "Failed SSH Login Attempts"
    if [ -f "$AUTHLOG" ]; then
        FAIL_COUNT=$(grep -c "Failed password" "$AUTHLOG")
        echo "Total failed attempts : $FAIL_COUNT"
        echo ""
        echo "Top 5 attacking IPs:"
        grep "Failed password" "$AUTHLOG" \
            | awk '{print $(NF-3)}' \
            | sort \
            | uniq -c \
            | sort -rn \
            | head -n 5
    else
        echo "auth.log not found."
    fi

    echo ""
    echo "==============================="
    echo " End of Report"
    echo "==============================="
}

generate_report

generate_report >> "$LOGFILE"
echo ""
echo "Report saved to: $LOGFILE"
