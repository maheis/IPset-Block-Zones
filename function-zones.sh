#!/bin/bash

# Install
function install {
    echo "Installation der benötigten Pakete: /sbin/ipset, /sbin/iptables"
    apt install /sbin/ipset /sbin/iptables
}

# Listen Abfragen
function lists {
    echo ""

    echo "Vorhandene /sbin/ipset-Listen:"
    echo ""
    /sbin/ipset list -terse
    echo ""
    echo "###"
    echo ""
    echo "Zugehörige /sbin/iptables-Regeln:"
    echo ""
    /sbin/iptables -L -n -v --line-numbers | grep -E 'firehol|blocked-countries'
}

# Listen anlegen
function create {
    echo ""

     # Prüfe, ob Parameter übergeben wurden
    if [ $# -gt 0 ]; then
        auswahl=$*
    else
        echo "Welche /sbin/ipset-Listen sollen erstellt werden? (Mehrfachauswahl mit Leerzeichen, z.B. 1 3 5)"
        echo "1) blocked-countries-ipv4"
        echo "2) blocked-countries-ipv6"
        echo "   China, Russia, Afghanistan, Albania, Algeria, Andorra, Angola, Armenia, Australia, Azerbaijan, Bangladesh, Belarus, Brazil, Bulgaria, Cambodia, Cayman Islands, Central African Republic, Chad, Chile, Colombia, Congo, Costa Rica, Cote d'Ivoire, Cuba, Djibouti, Ecuador, Egypt, El Salvador, Ethiopia, Fiji, Gabon, Gambia, Ghana, Guatemala, Honduras, Hong Kong, Indonesia, Iran, Islamic Republic, Iraq, Israel, Jordan, Kazakhstan, Kenya, Korea, Democratic People's Republic of, Korea, Republic of, Kuwait, Kyrgyzstan, Singapore, Lao People's Democratic Republic, Lebanon, Libyan Arab Jamahiriya, Madagascar, Malaysia, Mexico, Moldova, Republic of, Mongolia, Myanmar, New Zealand, Oman, Pakistan, Palestinian Territory, Occupied, Panama, Papua New Guinea, Paraguay, Peru, Philippines, Puerto Rico, Qatar, Saudi Arabia, Seychelles, South Africa, Syrian Arab Republic, Taiwan, Tajikistan, Thailand, United Arab Emirates, Yemen, Viet Nam, Uzbekistan"
        echo ""
        echo "3) firehol_abusers_1d"
        echo "   An /sbin/ipset made from blocklists that track abusers in the last 24 hours. (includes: botscout_1d cleantalk_new_1d cleantalk_updated_1d php_commenters_1d php_dictionary_1d php_harvesters_1d php_spammers_1d stopforumspam_1d)"
        echo ""
        echo "4) firehol_abusers_30d"
        echo "   An /sbin/ipset made from blocklists that track abusers in the last 30 days. (includes: cleantalk_new_30d cleantalk_updated_30d php_commenters_30d php_dictionary_30d php_harvesters_30d php_spammers_30d stopforumspam sblam)"
        echo ""
        echo "5) firehol_anonymous"
        echo "   An /sbin/ipset that includes all the anonymizing IPs of the world. (includes: anonymous dm_tor firehol_proxies tor_exits)"
        echo ""
        echo "6) firehol_level1"
        echo "   This site analyses all available security IP Feeds, mainly related to on-line attacks, on-line service abuse, malwares, botnets, command and control servers and other cybercrime activities."
        echo ""
        echo "7) firehol_level2"
        echo "   An /sbin/ipset made from blocklists that track attacks, during about the last 48 hours. (includes: blocklist_de dshield_1d greensnow)"
        echo ""
        echo "8) firehol_level3"
        echo "   An /sbin/ipset made from blocklists that track attacks, spyware, viruses. It includes IPs than have been reported or detected in the last 30 days. (includes: bruteforceblocker ciarmy dshield_30d myip vxvault)"
        echo ""
        echo "9) firehol_level4"
        echo "   An /sbin/ipset made from blocklists that track attacks, but may include a large number of false positives. (includes: blocklist_net_ua botscout_30d cybercrime iblocklist_hijacked iblocklist_spyware iblocklist_webexploit)"
        echo ""
        echo "10) firehol_proxies"
        echo "   An /sbin/ipset made from all sources that track open proxies. It includes IPs reported or detected in the last 30 days. (includes: iblocklist_proxies ip2proxy_px1lite socks_proxy_30d sslproxies_30d)"
        echo ""
        echo "11) firehol_webclient"
        echo "   An IP blacklist made from blocklists that track IPs that a web client should never talk to. This list is to be used on top of firehol_level1. (includes: cybercrime)"
        echo ""
        echo "12) firehol_webserver"
        echo "   A web server IP blacklist made from blocklists that track IPs that should never be used by your web users. (This list includes IPs that are servers hosting malware, bots, etc or users having a long criminal history. This list is to be used on top of firehol_level1, firehol_level2, firehol_level3 and possibly firehol_proxies or firehol_anonymous) . (includes: myip stopforumspam_toxic)"
        echo ""
        echo -n "Auswahl: "
        read -r auswahl

        echo ""
    fi

    for i in $auswahl; do
        case $i in
            1)
                echo "Erstelle blocked-countries-ipv4"

                /sbin/ipset --create blocked-countries-ipv4 nethash maxelem 10000000
                /sbin/iptables -D INPUT -m set --match-set blocked-countries-ipv4 src -j DROP
                /sbin/iptables -A INPUT -m set --match-set blocked-countries-ipv4 src -j DROP
                ;;
            2)
                echo "Erstelle blocked-countries-ipv6"

                /sbin/ipset --create blocked-countries-ipv6 nethash maxelem 10000000 family inet6
                ip6tables -D INPUT -m set --match-set blocked-countries-ipv6 src -j DROP
                ip6tables -A INPUT -m set --match-set blocked-countries-ipv6 src -j DROP
                ;;
            3)
                echo "Erstelle firehol_abusers_1d"

                /sbin/ipset --create firehol_abusers_1d nethash maxelem 10000
                /sbin/iptables -D INPUT -m set --match-set firehol_abusers_1d src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_abusers_1d src -j DROP
                ;;
            4)
                echo "Erstelle firehol_abusers_30d"

                /sbin/ipset --create firehol_abusers_30d nethash maxelem 400000
                /sbin/iptables -D INPUT -m set --match-set firehol_abusers_30d src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_abusers_30d src -j DROP
                ;;
            5)
                echo "Erstelle firehol_anonymous"

                /sbin/ipset --create firehol_anonymous nethash maxelem 4000000
                /sbin/iptables -D INPUT -m set --match-set firehol_anonymous src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_anonymous src -j DROP
                ;;
            6)
                echo "Erstelle firehol_level1"

                /sbin/ipset --create firehol_level1 nethash maxelem 10000
                /sbin/iptables -D INPUT -m set --match-set firehol_level1 src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_level1 src -j DROP
                ;;
            7)
                echo "Erstelle firehol_level2"
                
                /sbin/ipset --create firehol_level2 nethash maxelem 30000
                /sbin/iptables -D INPUT -m set --match-set firehol_level2 src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_level2 src -j DROP
                ;;
            8)
                echo "Erstelle firehol_level3"

                /sbin/ipset --create firehol_level3 nethash maxelem 30000
                /sbin/iptables -D INPUT -m set --match-set firehol_level3 src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_level3 src -j DROP
                ;;
            9)
                echo "Erstelle firehol_level4"

                /sbin/ipset --create firehol_level4 nethash maxelem 160000
                /sbin/iptables -D INPUT -m set --match-set firehol_level4 src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_level4 src -j DROP
                ;;
            10)
                echo "Erstelle firehol_proxies"

                /sbin/ipset --create firehol_proxies nethash maxelem 4000000
                /sbin/iptables -D INPUT -m set --match-set firehol_proxies src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_proxies src -j DROP
                ;;
            11)
                echo "Erstelle firehol_webclient"

                /sbin/ipset --create firehol_webclient nethash maxelem 6000
                /sbin/iptables -D INPUT -m set --match-set firehol_webclient src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_webclient src -j DROP
                ;;
            12)
                echo "Erstelle firehol_webserver"

                /sbin/ipset --create firehol_webserver nethash maxelem 6000
                /sbin/iptables -D INPUT -m set --match-set firehol_webserver src -j DROP
                /sbin/iptables -A INPUT -m set --match-set firehol_webserver src -j DROP
                ;;
            *)  echo "Ungültige Auswahl: $i" ;;
        esac
    done

    update
}

# Listen befüllen (kann dauern !)
function update {
    echo ""

    if /sbin/ipset list blocked-countries-ipv4 &>/dev/null; then
        echo "Aktualisiere blocked-countries-ipv4"
        
        /sbin/ipset flush blocked-countries-ipv4

        # China
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Russia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ru-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Afghanistan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/af-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Albania
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/al-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Algeria
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/dz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Andorra
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ad-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Angola
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ao-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Armenia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/am-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Australia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/au-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Azerbaijan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/az-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Bangladesh
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/bd-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Belarus
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/by-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Brazil
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/br-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Bulgaria
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/bg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cambodia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cayman Islands
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ky-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Central African Republic
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cf-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Chad
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/td-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Chile
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cl-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Colombia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/co-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Congo
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Costa Rica
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cote d'Ivoire
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ci-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cuba
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cu-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Djibouti
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/dj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ecuador
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ec-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Egypt
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/eg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # El Salvador
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sv-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ethiopia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/et-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Fiji
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/fj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Gabon
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ga-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Gambia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ghana
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Guatemala
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gt-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Honduras
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/hn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Hong Kong
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/hk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Indonesia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/id-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Iran, Islamic Republic
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ir-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Iraq
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/iq-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Israel
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/il-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Jordan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/jo-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kazakhstan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kenya
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ke-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Korea, Democratic People's Republic of
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kp-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Korea, Republic of
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kuwait
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kyrgyzstan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Singapore
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Lao People's Democratic Republic
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/la-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Lebanon
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/lb-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Libyan Arab Jamahiriya
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ly-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Madagascar
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Malaysia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/my-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Mexico
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mx-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Moldova, Republic of
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/md-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Mongolia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Myanmar
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # New Zealand
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/nz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Oman
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/om-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Pakistan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Palestinian Territory, Occupied
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ps-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Panama
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Papua New Guinea
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Paraguay
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/py-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Peru
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pe-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Philippines
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ph-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Puerto Rico
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Qatar
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/qa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Saudi Arabia
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Seychelles
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sc-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # South Africa
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/za-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Syrian Arab Republic
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sy-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Taiwan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/tw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Tajikistan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/tj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Thailand
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/th-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # United Arab Emirates
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ae-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Yemen
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ye-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Viet Nam
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/vn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Uzbekistan
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/uz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done
    fi

    ###############

    if /sbin/ipset list blocked-countries-ipv6 &>/dev/null; then
        echo "Aktualisiere blocked-countries-ipv6"

        /sbin/ipset flush blocked-countries-ipv6

        # China
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Russia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ru-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Afghanistan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/af-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Albania
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/al-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Algeria
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/dz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Andorra
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ad-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Angola
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ao-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Armenia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/am-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Australia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/au-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Azerbaijan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/az-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Bangladesh
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/bd-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Belarus
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/by-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Brazil
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/br-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Bulgaria
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/bg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cambodia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cayman Islands
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ky-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Central African Republic
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cf-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Chad
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/td-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Chile
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cl-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Colombia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/co-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Congo
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Costa Rica
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cote d'Ivoire
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ci-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cuba
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cu-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Djibouti
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/dj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ecuador
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ec-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Egypt
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/eg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # El Salvador
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sv-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ethiopia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/et-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Fiji
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/fj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Gabon
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ga-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Gambia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ghana
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Guatemala
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gt-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Honduras
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/hn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Hong Kong
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/hk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Indonesia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/id-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Iran, Islamic Republic
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ir-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Iraq
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/iq-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Israel
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/il-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Jordan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/jo-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kazakhstan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kenya
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ke-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Korea, Democratic People's Republic of
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kp-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Korea, Republic of
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kuwait
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kyrgyzstan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Singapore
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Lao People's Democratic Republic
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/la-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Lebanon
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/lb-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Libyan Arab Jamahiriya
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ly-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Madagascar
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Malaysia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/my-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Mexico
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mx-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Moldova, Republic of
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/md-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Mongolia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Myanmar
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # New Zealand
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/nz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Oman
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/om-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Pakistan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Palestinian Territory, Occupied
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ps-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Panama
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Papua New Guinea
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Paraguay
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/py-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Peru
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pe-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Philippines
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ph-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Puerto Rico
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Qatar
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/qa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Saudi Arabia
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Seychelles
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sc-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # South Africa
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/za-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Syrian Arab Republic
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sy-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Taiwan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/tw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Tajikistan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/tj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Thailand
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/th-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # United Arab Emirates
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ae-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Yemen
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ye-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Viet Nam
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/vn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Uzbekistan
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/uz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done
    fi

    ###############

    if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
        echo "Aktualisiere firehol_abusers_1d"

        /sbin/ipset flush firehol_abusers_1d
        
        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_1d.netset | sed '/#/d')
        do /sbin/ipset --add firehol_abusers_1d "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
        echo "Aktualisiere firehol_abusers_30d"

        /sbin/ipset flush firehol_abusers_30d

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_30d.netset | sed '/#/d')
        do /sbin/ipset --add firehol_abusers_30d "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_anonymous &>/dev/null; then
        echo "Aktualisiere firehol_anonymous"

        /sbin/ipset flush firehol_anonymous

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_anonymous.netset | sed '/#/d')
        do /sbin/ipset --add firehol_anonymous "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level1 &>/dev/null; then
        echo "Aktualisiere firehol_level1"
        
        /sbin/ipset flush firehol_level1

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level1.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level1 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level2 &>/dev/null; then
        echo "Aktualisiere firehol_level2"

        /sbin/ipset flush firehol_level2

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level2.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level2 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level3 &>/dev/null; then
        echo "Aktualisiere firehol_level3"

        /sbin/ipset flush firehol_level3

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level3.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level3 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level4 &>/dev/null; then
        echo "Aktualisiere firehol_level4"

        /sbin/ipset flush firehol_level4

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level4.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level4 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_proxies &>/dev/null; then
        echo "Aktualisiere firehol_proxies"

        /sbin/ipset flush firehol_proxies

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_proxies.netset | sed '/#/d')
        do /sbin/ipset --add firehol_proxies "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_webclient &>/dev/null; then
        echo "Aktualisiere firehol_webclient"

        /sbin/ipset flush firehol_webclient

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webclient.netset | sed '/#/d')
        do /sbin/ipset --add firehol_webclient "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_webserver &>/dev/null; then
        echo "Aktualisiere firehol_webserver"

        /sbin/ipset flush firehol_webserver

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webserver.netset | sed '/#/d')
        do /sbin/ipset --add firehol_webserver "$ZONE"
        done
    fi

    lists
}

# Listen entfernen
function remove {
    echo ""

    if /sbin/ipset list blocked-countries-ipv4 &>/dev/null; then
        echo "Entferne blocked-countries-ipv4"

        /sbin/iptables -D INPUT -m set --match-set blocked-countries-ipv4 src -j DROP
        /sbin/ipset --destroy blocked-countries-ipv4
    fi
    if /sbin/ipset list blocked-countries-ipv6 &>/dev/null; then
        echo "Entferne blocked-countries-ipv6"

        ip6tables -D INPUT -m set --match-set blocked-countries-ipv6 src -j DROP
        /sbin/ipset --destroy blocked-countries-ipv6
    fi
    if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
        echo "Entferne firehol_abusers_1d"

        ip6tables -D INPUT -m set --match-set firehol_abusers_1d src -j DROP
        /sbin/ipset --destroy firehol_abusers_1d
    fi
    if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
        echo "Entferne firehol_abusers_30d"

        ip6tables -D INPUT -m set --match-set firehol_abusers_30d src -j DROP
        /sbin/ipset --destroy firehol_abusers_30d
    fi
    if /sbin/ipset list firehol_anonymous &>/dev/null; then
        echo "Entferne firehol_anonymous"

        ip6tables -D INPUT -m set --match-set firehol_anonymous src -j DROP
        /sbin/ipset --destroy firehol_anonymous
    fi
    if /sbin/ipset list firehol_level1 &>/dev/null; then
        echo "Entferne firehol_level1"

        /sbin/iptables -D INPUT -m set --match-set firehol_level1 src -j DROP
        /sbin/ipset --destroy firehol_level1
    fi
    if /sbin/ipset list firehol_level2 &>/dev/null; then
        echo "Entferne firehol_level2"

        /sbin/iptables -D INPUT -m set --match-set firehol_level2 src -j DROP
        /sbin/ipset --destroy firehol_level2
    fi
    if /sbin/ipset list firehol_level3 &>/dev/null; then
        echo "Entferne firehol_level3"

        /sbin/iptables -D INPUT -m set --match-set firehol_level3 src -j DROP
        /sbin/ipset --destroy firehol_level3
    fi
    if /sbin/ipset list firehol_level4 &>/dev/null; then
        echo "Entferne firehol_level4"

        /sbin/iptables -D INPUT -m set --match-set firehol_level4 src -j DROP
        /sbin/ipset --destroy firehol_level4
    fi
    if /sbin/ipset list firehol_proxies &>/dev/null; then
        echo "Entferne firehol_proxies"

        /sbin/iptables -D INPUT -m set --match-set firehol_proxies src -j DROP
        /sbin/ipset --destroy firehol_proxies
    fi
    if /sbin/ipset list firehol_webclient &>/dev/null; then
        echo "Entferne firehol_webclient"

        /sbin/iptables -D INPUT -m set --match-set firehol_webclient src -j DROP
        /sbin/ipset --destroy firehol_webclient
    fi
    if /sbin/ipset list firehol_webserver &>/dev/null; then
        echo "Entferne firehol_webserver"

        /sbin/iptables -D INPUT -m set --match-set firehol_webserver src -j DROP
        /sbin/ipset --destroy firehol_webserver
    fi

    lists
}