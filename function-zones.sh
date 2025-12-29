#!/bin/bash

# Install
function install {
    install ipset
}

# Listen Abfragen
function lists {
    /sbin/ipset list -terse
}

# Listen anlegen
function create {
    echo "Welche IPset-Listen sollen erstellt werden? (Mehrfachauswahl mit Leerzeichen, z.B. 1 3 5)"
    echo "1) blocked-countries-ipv4"
    echo "China, Russia, Afghanistan, Albania, Algeria, Andorra, Angola, Armenia, Australia, Azerbaijan, Bangladesh, Belarus, Brazil, Bulgaria, Cambodia, Cayman Islands, Central African Republic, Chad, Chile, Colombia, Congo, Costa Rica, Cote D'Ivoire, Cuba, Djibouti, Ecuador, Egypt, El Salvador, Ethiopia, Fiji, Gabon, Gambia, Ghana, Guatemala, Honduras, Hong Kong, Indonesia, Iran, Iraq"
    echo "2) blocked-countries-ipv6"

    echo "3) firehol_abusers_1d"
    echo "An ipset made from blocklists that track abusers in the last 24 hours. (includes: botscout_1d cleantalk_new_1d cleantalk_updated_1d php_commenters_1d php_dictionary_1d php_harvesters_1d php_spammers_1d stopforumspam_1d)"
    echo "4) firehol_abusers_30d"
    echo "An ipset made from blocklists that track abusers in the last 30 days. (includes: cleantalk_new_30d cleantalk_updated_30d php_commenters_30d php_dictionary_30d php_harvesters_30d php_spammers_30d stopforumspam sblam)"
    echo "5) firehol_anonymous"
    echo "An ipset that includes all the anonymizing IPs of the world. (includes: anonymous dm_tor firehol_proxies tor_exits)"
    echo "6) firehol_level1"
    echo "This site analyses all available security IP Feeds, mainly related to on-line attacks, on-line service abuse, malwares, botnets, command and control servers and other cybercrime activities."
    echo "7) firehol_level2"
    echo "An ipset made from blocklists that track attacks, during about the last 48 hours. (includes: blocklist_de dshield_1d greensnow)"
    echo "8) firehol_level3"
    echo "An ipset made from blocklists that track attacks, spyware, viruses. It includes IPs than have been reported or detected in the last 30 days. (includes: bruteforceblocker ciarmy dshield_30d myip vxvault)"
    echo "9) firehol_level4"
    echo "An ipset made from blocklists that track attacks, but may include a large number of false positives. (includes: blocklist_net_ua botscout_30d cybercrime iblocklist_hijacked iblocklist_spyware iblocklist_webexploit)"
    echo "10) firehol_proxies"
    echo "An ipset made from all sources that track open proxies. It includes IPs reported or detected in the last 30 days. (includes: iblocklist_proxies ip2proxy_px1lite socks_proxy_30d sslproxies_30d)"
    echo "11) firehol_webclient"
    echo "An IP blacklist made from blocklists that track IPs that a web client should never talk to. This list is to be used on top of firehol_level1. (includes: cybercrime)"
    echo "12) firehol_webserver"
    echo "A web server IP blacklist made from blocklists that track IPs that should never be used by your web users. (This list includes IPs that are servers hosting malware, bots, etc or users having a long criminal history. This list is to be used on top of firehol_level1, firehol_level2, firehol_level3 and possibly firehol_proxies or firehol_anonymous) . (includes: myip stopforumspam_toxic)"
    echo -n "Auswahl: "
    read -r auswahl

    for i in $auswahl; do
        case $i in
            1)  /sbin/ipset --create blocked-countries-ipv4 nethash maxelem 10000000 ;;
            2)  /sbin/ipset --create blocked-countries-ipv6 nethash maxelem 10000000 family inet6 ;;
            3)  /sbin/ipset --create firehol_abusers_1d nethash maxelem 10000 ;;
            4)  /sbin/ipset --create firehol_abusers_30d nethash maxelem 400000 ;;
            5)  /sbin/ipset --create firehol_anonymous nethash maxelem 4000000 ;;
            6)  /sbin/ipset --create firehol_level1 nethash maxelem 10000 ;;
            7)  /sbin/ipset --create firehol_level2 nethash maxelem 30000 ;;
            8)  /sbin/ipset --create firehol_level3 nethash maxelem 30000 ;;
            9)  /sbin/ipset --create firehol_level4 nethash maxelem 160000 ;;
            10) /sbin/ipset --create firehol_proxies nethash maxelem 4000000 ;;
            11) /sbin/ipset --create firehol_webclient nethash maxelem 6000 ;;
            12) /sbin/ipset --create firehol_webserver nethash maxelem 6000 ;;
            *)  echo "Ungültige Auswahl: $i" ;;
        esac
    done
}

# Listen befüllen (kann dauern !)
function update {
    if /sbin/ipset list blocked-countries-ipv4 &>/dev/null; then
        /sbin/ipset flush blocked-countries-ipv4

        # China IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Russia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ru-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Afghanistan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/af-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Albania IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/al-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Algeria IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/dz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Andorra IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ad-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Angola IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ao-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Armenia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/am-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Australia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/au-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Azerbaijan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/az-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Bangladesh IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/bd-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Belarus IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/by-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Brazil IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/br-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Bulgaria IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/bg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cambodia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cayman Islands IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ky-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Central African Republic IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cf-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Chad IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/td-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Chile IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cl-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Colombia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/co-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Congo IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Costa Rica IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cote d'Ivoire IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ci-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Cuba IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/cu-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Djibouti IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/dj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ecuador IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ec-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Egypt IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/eg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # El Salvador IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sv-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ethiopia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/et-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Fiji IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/fj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Gabon IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ga-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Gambia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Ghana IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Guatemala IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/gt-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Honduras IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/hn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Hong Kong IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/hk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Indonesia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/id-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Iran, Islamic Republic IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ir-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Iraq IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/iq-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Israel IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/il-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Jordan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/jo-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kazakhstan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kenya IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ke-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Korea, Democratic People's Republic of IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kp-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Korea, Republic of IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kuwait IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Kyrgyzstan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/kg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Singapore IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Lao People's Democratic Republic IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/la-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Lebanon IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/lb-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Libyan Arab Jamahiriya IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ly-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Madagascar IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Malaysia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/my-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Mexico IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mx-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Moldova, Republic of IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/md-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Mongolia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Myanmar IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/mm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # New Zealand IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/nz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Oman IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/om-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Pakistan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Palestinian Territory, Occupied
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ps-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Panama IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Papua New Guinea IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Paraguay IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/py-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Peru IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pe-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Philippines IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ph-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Puerto Rico IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/pr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Qatar IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/qa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Saudi Arabia IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Seychelles IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sc-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # South Africa IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/za-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Syrian Arab Republic IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/sy-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Taiwan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/tw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Tajikistan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/tj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Thailand IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/th-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # United Arab Emirates IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ae-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Yemen IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/ye-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Viet Nam IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/vn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done

        # Uzbekistan IPv4
        for ZONE in $(wget --quiet -O - https://www.ipdeny.com/ipblocks/data/aggregated/uz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv4 "$ZONE"
        done
    fi

    ###############

    if /sbin/ipset list blocked-countries-ipv6 &>/dev/null; then
        /sbin/ipset flush blocked-countries-ipv6

        # China IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Russia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ru-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Afghanistan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/af-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Albania IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/al-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Algeria IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/dz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Andorra IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ad-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Angola IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ao-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Armenia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/am-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Australia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/au-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Azerbaijan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/az-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Bangladesh IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/bd-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Belarus IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/by-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Brazil IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/br-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Bulgaria IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/bg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cambodia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cayman Islands IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ky-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Central African Republic IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cf-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Chad IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/td-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Chile IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cl-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Colombia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/co-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Congo IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Costa Rica IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cote d'Ivoire IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ci-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Cuba IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/cu-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Djibouti IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/dj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ecuador IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ec-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Egypt IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/eg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # El Salvador IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sv-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ethiopia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/et-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Fiji IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/fj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Gabon IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ga-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Gambia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Ghana IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gh-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Guatemala IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/gt-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Honduras IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/hn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Hong Kong IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/hk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Indonesia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/id-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Iran, Islamic Republic IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ir-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Iraq IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/iq-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Israel IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/il-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Jordan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/jo-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kazakhstan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kenya IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ke-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Korea, Democratic People's Republic of IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kp-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Korea, Republic of IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kuwait IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Kyrgyzstan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/kg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Singapore IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Lao People's Democratic Republic IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/la-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Lebanon IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/lb-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Libyan Arab Jamahiriya IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ly-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Madagascar IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Malaysia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/my-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Mexico IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mx-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Moldova, Republic of IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/md-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Mongolia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Myanmar IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/mm-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # New Zealand IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/nz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Oman IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/om-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Pakistan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pk-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Palestinian Territory, Occupied
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ps-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Panama IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Papua New Guinea IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pg-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Paraguay IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/py-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Peru IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pe-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Philippines IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ph-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Puerto Rico IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/pr-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Qatar IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/qa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Saudi Arabia IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sa-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Seychelles IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sc-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # South Africa IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/za-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Syrian Arab Republic IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/sy-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Taiwan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/tw-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Tajikistan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/tj-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Thailand IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/th-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # United Arab Emirates IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ae-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Yemen IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/ye-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Viet Nam IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/vn-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done

        # Uzbekistan IPv6
        for ZONE in $(wget --quiet -O - https://ipdeny.com/ipv6/ipaddresses/aggregated/uz-aggregated.zone)
        do /sbin/ipset --add blocked-countries-ipv6 "$ZONE"
        done
    fi

    ###############

    if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
        /sbin/ipset flush firehol_abusers_1d

        # FireHOL ‘level 1’ blacklist
        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_1d.netset | sed '/#/d')
        do /sbin/ipset --add firehol_abusers_1d "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
        /sbin/ipset flush firehol_abusers_30d

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_30d.netset | sed '/#/d')
        do /sbin/ipset --add firehol_abusers_30d "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_anonymous &>/dev/null; then
        /sbin/ipset flush firehol_anonymous

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_anonymous.netset | sed '/#/d')
        do /sbin/ipset --add firehol_anonymous "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level1 &>/dev/null; then
        /sbin/ipset flush firehol_level1

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level1.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level1 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level2 &>/dev/null; then
        /sbin/ipset flush firehol_level2

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level2.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level2 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level3 &>/dev/null; then
        /sbin/ipset flush firehol_level3

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level3.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level3 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_level4 &>/dev/null; then
        /sbin/ipset flush firehol_level4

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level4.netset | sed '/#/d')
        do /sbin/ipset --add firehol_level4 "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_proxies &>/dev/null; then
        /sbin/ipset flush firehol_proxies

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_proxies.netset | sed '/#/d')
        do /sbin/ipset --add firehol_proxies "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_webclient &>/dev/null; then
        /sbin/ipset flush firehol_webclient

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webclient.netset | sed '/#/d')
        do /sbin/ipset --add firehol_webclient "$ZONE"
        done
    fi

    if /sbin/ipset list firehol_webserver &>/dev/null; then
        /sbin/ipset flush firehol_webserver

        for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webserver.netset | sed '/#/d')
        do /sbin/ipset --add firehol_webserver "$ZONE"
        done
    fi
}

# Listen importieren
function import {
    if /sbin/ipset list blocked-countries-ipv4 &>/dev/null; then
        iptables -A INPUT -m set --match-set blocked-countries-ipv4 src -j DROP
    fi
    if /sbin/ipset list blocked-countries-ipv6 &>/dev/null; then
        ip6tables -A INPUT -m set --match-set blocked-countries-ipv6 src -j DROP
    fi
    if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_abusers_1d src -j DROP
    fi
    if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_abusers_30d src -j DROP
    fi
    if /sbin/ipset list firehol_anonymous &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_anonymous src -j DROP
    fi
    if /sbin/ipset list firehol_level1 &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_level1 src -j DROP
    fi
    if /sbin/ipset list firehol_level2 &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_level2 src -j DROP
    fi
    if /sbin/ipset list firehol_level3 &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_level3 src -j DROP
    fi
    if /sbin/ipset list firehol_level4 &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_level4 src -j DROP
    fi
    if /sbin/ipset list firehol_proxies &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_proxies src -j DROP
    fi
    if /sbin/ipset list firehol_webclient &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_webclient src -j DROP
    fi
    if /sbin/ipset list firehol_webserver &>/dev/null; then
        iptables -A INPUT -m set --match-set firehol_webserver src -j DROP
    fi
}

# Listen entfernen
function remove {
    if /sbin/ipset list blocked-countries-ipv4 &>/dev/null; then
        iptables -D INPUT -m set --match-set blocked-countries-ipv4 src -j DROP
        /sbin/ipset --destroy blocked-countries-ipv4
    fi
    if /sbin/ipset list blocked-countries-ipv6 &>/dev/null; then
        ip6tables -D INPUT -m set --match-set blocked-countries-ipv6 src -j DROP
        /sbin/ipset --destroy blocked-countries-ipv6
    fi
    if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
        ip6tables -D INPUT -m set --match-set firehol_abusers_1d src -j DROP
        /sbin/ipset --destroy firehol_abusers_1d
    fi
    if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
        ip6tables -D INPUT -m set --match-set firehol_abusers_30d src -j DROP
        /sbin/ipset --destroy firehol_abusers_30d
    fi
    if /sbin/ipset list firehol_anonymous &>/dev/null; then
        ip6tables -D INPUT -m set --match-set firehol_anonymous src -j DROP
        /sbin/ipset --destroy firehol_anonymous
    fi
    if /sbin/ipset list firehol_level1 &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_level1 src -j DROP
        /sbin/ipset --destroy firehol_level1
    fi
    if /sbin/ipset list firehol_level2 &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_level2 src -j DROP
        /sbin/ipset --destroy firehol_level2
    fi
    if /sbin/ipset list firehol_level3 &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_level3 src -j DROP
        /sbin/ipset --destroy firehol_level3
    fi
    if /sbin/ipset list firehol_level4 &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_level4 src -j DROP
        /sbin/ipset --destroy firehol_level4
    fi
    if /sbin/ipset list firehol_proxies &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_proxies src -j DROP
        /sbin/ipset --destroy firehol_proxies
    fi
    if /sbin/ipset list firehol_webclient &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_webclient src -j DROP
        /sbin/ipset --destroy firehol_webclient
    fi
    if /sbin/ipset list firehol_webserver &>/dev/null; then
        iptables -D INPUT -m set --match-set firehol_webserver src -j DROP
        /sbin/ipset --destroy firehol_webserver
    fi
}