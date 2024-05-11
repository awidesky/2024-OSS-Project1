#! /bin/bash

if [ $# -ne 3 ]; then
    echo "usage: $0 file1 file2 file3"
    # return will not work when executed as "./proj1_12211723_HongSungMin.sh"
    exit 1
fi

for f in $*; do
    if [ "$f" == "teams.csv" ]; then
        f_teams="$f"
        continue
    fi
    if [ "$f" == "players.csv" ]; then
        f_players="$f"
        continue
    fi
    if [ "$f" == "matches.csv" ]; then
        f_matches="$f"
        continue
    fi
    echo "Ilegal filename $f"
    exit 1
done

echo "************OSS1 - Project1************"
echo "*        StudentID : 12211723         *"
echo "*        Name : SungMin Hong          *"
echo "***************************************"
echo ""

choice=0
while [ "$choice" != "7" ]
do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"

    read -p "Enter your CHOICE (1~7) : " choice
    case "$choice" in
    "1")
        read -p "Do you want to get the Heung-Min Son's data? (y/n) : " yes
        if [ "$yes" = "y" ]; then
            awk -F, '$1=="Heung-Min Son" {printf("Team:%s, Apperance:%d, Goal:%d, Assist:%d\n", $4, $6, $7, $8)}' < "$f_players"
        fi
        ;;
    "2")
        read -p "What do you want to get the team data of league_position[1~20] : " pos
        awk -v p=$pos -F, '$6==p {print $6, $1, $2/($2+$3+$4)}' < "$f_teams"
        ;;
    "3")
        read -p "Do you want to know Top-3 attendance data? (y/n) : " yes
        if [ "$yes" = "y" ]; then
            echo "***Top-3 Attendance Match***"
            sort -r -n -k 2 -t ',' < "$f_matches" | head -n 3 | awk -F, '{printf("\n%s vs %s (%s)\n%d %s\n", $3, $4, $1, $2, $7)}'
        fi
        ;;
    "4")
        read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " yes
        if [ "$yes" = "y" ]; then
            OLDIFS=$IFS
            IFS=,
            for team in $(sort -n -k 6 -t ',' < "$f_teams" | awk -F, '$1!="common_name" {printf("%s/%s,", $6, $1)}'); do
                echo ""
                echo "$team" | tr '/' ' '
                awk -v t=$(echo "$team" | cut -d '/' -f2) -F, '$4==t {printf("%s/%s\n", $1, $7)}' < "$f_players" | LC_CTYPE=C sort -r -n -k 2 -t '/' | head -n 1 | tr '/' ' '
            done
            IFS=$OLDIFS
        fi
        ;;
    "5")
        read -p "Do you want to modify the format of date? (y/n) : " yes
        if [ "$yes" = "y" ]; then
            awk -F, '$1!="date_GMT" {print $1}' < "$f_matches" | head -n 10 | sed -e 's/Jan/01/' -e 's/Feb/02/' -e 's/Mar/03/' -e 's/Apr/04/' -e 's/May/05/' -e 's/Jun/06/' -e 's/Jul/07/' -e 's/Aug/08/' -e 's/Sep/09/' -e 's/Oct/10/' -e 's/Nov/11/' -e 's/Dec/12/' | sed -E -e 's/([0-9]{2}) ([0-9]{2}) ([0-9]{4}) \- ([0-9]+\:[0-9]{2}(am|pm))/\3\/\1\/\2 \4/'
        fi
        ;;
    "6")
        awk -F, '$1!="common_name" {printf("%s) %s\n", NR-1, $1)}' < "$f_teams"
        read -p "Enter your team number : " team
        echo ""
        selected=$(awk -v t="$(( $team+1 ))" -F, 'NR==t {print $1}' < "$f_teams")
        for i in $(awk -v s="$selected" -F, '$3==s {print $5-$6}'  < "$f_matches"); do
            if [ ${max-$i} -le $i ]; then
                max=$i
            fi
        done
        awk -v m="$max" -v s="$selected" -F, '$3==s && $5-$6==m {printf("%s\n%s %d vs %d %s\n\n", $1, $3, $5, $6, $4)}'  < "$f_matches"
        unset max
        ;;
    "7")
        echo "Bye!"
        exit 0
        ;;
    esac
    echo ""
done

