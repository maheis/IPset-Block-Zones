#!/bin/bash

if [ -r /etc/ipset/iptables_interface.conf ]; then
    IPTABLES_INTERFACE=$(cat /etc/ipset/iptables_interface.conf)
else
    IPTABLES_INTERFACE="eth0"
fi
if [ -z "$IPTABLES_INTERFACE" ]; then
    IPTABLES_INTERFACE="eth0"
fi

LOCAL_IPSET_BLOCKLIST_FILE="${LOCAL_IPSET_BLOCKLIST_FILE:-/opt/local-ipset-blocklist.zone}"
if [ ! -f "$LOCAL_IPSET_BLOCKLIST_FILE" ]; then
    touch "$LOCAL_IPSET_BLOCKLIST_FILE"
fi
LOCAL_IPSET_WHITELIST_FILE="${LOCAL_IPSET_WHITELIST_FILE:-/opt/local-ipset-whitelist.zone}"
if [ ! -f "$LOCAL_IPSET_WHITELIST_FILE" ]; then
    touch "$LOCAL_IPSET_WHITELIST_FILE"
fi

# Install
function install {
    echo "Installation der benötigten Pakete: ipset, iptables"
    apt install -y ipset iptables
}

# Konfiguration
function config {
    echo ""

    echo "Was soll Konfiguriert werden?"
    echo "1) Netzwerkkarte, auf die die /sbin/iptables-Regeln angewendet werden sollen (Standard: eth0, Aktuell: ${IPTABLES_INTERFACE})"
    # echo "2) IPs die nicht geblockt werden sollen!"
    echo ""
    echo -n "Auswahl: "
    read -r auswahl

    echo ""

    case $auswahl in
        1)
            configure_iptables_interface
            ;;
        *)  echo "Ungültige Auswahl: $auswahl" ;;
    esac
}

# Netzwerkkarte fuer die /sbin/iptables-Regeln setzen
function configure_iptables_interface {
    echo ""
    echo "Aktuelle Netzwerkkarte: $IPTABLES_INTERFACE"

    if [ -z "$interface" ]; then
        echo -n "Neue Netzwerkkarte (Leer lassen zum Beibehalten): "
        read -r interface
    fi

    if [ -z "$interface" ]; then
        echo "Netzwerkkarte bleibt unverändert: $IPTABLES_INTERFACE"
        return 0
    fi

    if [[ ! "$interface" =~ ^[[:alnum:]][[:alnum:]_.:-]{0,14}$ ]]; then
        echo "Ungültige Netzwerkkarte: $interface"
        return 1
    fi

    IPTABLES_INTERFACE="$interface"
    echo "Netzwerkkarte gesetzt auf: $IPTABLES_INTERFACE"
    echo "$IPTABLES_INTERFACE" >/etc/ipset/iptables_interface.conf
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
    echo "num   pkts bytes target     prot opt in     out     source               destination"
    /sbin/iptables -L -n -v --line-numbers | grep -E 'firehol|blocked-countries|local-ipset-blocklist|local-ipset-whitelist'
}

# Listen anlegen
function create {
    echo ""

     # Prüfe, ob Parameter übergeben wurden
    if [ $# -gt 0 ]; then
        auswahl="$(normalize_selection "$@")"
    else
        echo "Welche /sbin/ipset-Listen sollen erstellt werden? (Mehrfachauswahl mit Leerzeichen, z.B. 1 3 5)"
        echo ""
        echo "1) local-ipset-blocklist"
        echo "   Eine eigene lokale Block-Liste. Diese kann dann mit eigenen IPs befüllt werden die dem Format 0.0.0.0/0 entsprechen. Liste muss unter ${LOCAL_IPSET_BLOCKLIST_FILE} erstellt werden!"
        echo ""
        echo "2) firehol_abusers_1d"
        echo "   An ipset made from blocklists that track abusers in the last 24 hours. (includes: botscout_1d cleantalk_new_1d cleantalk_updated_1d php_commenters_1d php_dictionary_1d php_harvesters_1d php_spammers_1d stopforumspam_1d)"
        echo ""
        echo "3) firehol_abusers_30d"
        echo "   An ipset made from blocklists that track abusers in the last 30 days. (includes: cleantalk_new_30d cleantalk_updated_30d php_commenters_30d php_dictionary_30d php_harvesters_30d php_spammers_30d stopforumspam sblam)"
        echo ""
        echo "4) firehol_anonymous"
        echo "   An ipset that includes all the anonymizing IPs of the world. (includes: anonymous dm_tor firehol_proxies tor_exits)"
        echo ""
        echo "5) firehol_level1"
        echo "   This site analyses all available security IP Feeds, mainly related to on-line attacks, on-line service abuse, malwares, botnets, command and control servers and other cybercrime activities."
        echo ""
        echo "6) firehol_level2"
        echo "   An ipset made from blocklists that track attacks, during about the last 48 hours. (includes: blocklist_de dshield_1d greensnow)"
        echo ""
        echo "7) firehol_level3"
        echo "   An ipset made from blocklists that track attacks, spyware, viruses. It includes IPs than have been reported or detected in the last 30 days. (includes: bruteforceblocker ciarmy dshield_30d myip vxvault)"
        echo "   (This List blocks Github, it's recommended to set these IPs on the Whitelist! 140.82.121.3, 140.82.121.4)"
        echo ""
        echo "8) firehol_level4"
        echo "   An ipset made from blocklists that track attacks, but may include a large number of false positives. (includes: blocklist_net_ua botscout_30d cybercrime iblocklist_hijacked iblocklist_spyware iblocklist_webexploit)"
        echo ""
        echo "9) firehol_proxies"
        echo "   An ipset made from all sources that track open proxies. It includes IPs reported or detected in the last 30 days. (includes: iblocklist_proxies ip2proxy_px1lite socks_proxy_30d sslproxies_30d)"
        echo ""
        echo "10) firehol_webclient"
        echo "   An IP blacklist made from blocklists that track IPs that a web client should never talk to. This list is to be used on top of firehol_level1. (includes: cybercrime)"
        echo ""
        echo "11) firehol_webserver"
        echo "   A web server IP blacklist made from blocklists that track IPs that should never be used by your web users. (This list includes IPs that are servers hosting malware, bots, etc or users having a long criminal history. This list is to be used on top of firehol_level1, firehol_level2, firehol_level3 and possibly firehol_proxies or firehol_anonymous) . (includes: myip stopforumspam_toxic)"
        echo ""
        echo -n "Auswahl: "
        read -r auswahl

        echo ""
    fi

    for i in $auswahl; do
        case $i in
            1)
                echo "Erstelle local-ipset-blocklist"

                touch "$LOCAL_IPSET_BLOCKLIST_FILE"
                /sbin/ipset --create local-ipset-blocklist nethash maxelem 500
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set local-ipset-blocklist src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set local-ipset-blocklist src -j DROP
                ;;
            2)
                echo "Erstelle firehol_abusers_1d"

                /sbin/ipset --create firehol_abusers_1d nethash maxelem 20000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_1d src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_1d src -j DROP
                ;;
            3)
                echo "Erstelle firehol_abusers_30d"

                /sbin/ipset --create firehol_abusers_30d nethash maxelem 400000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_30d src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_30d src -j DROP
                ;;
            4)
                echo "Erstelle firehol_anonymous"

                /sbin/ipset --create firehol_anonymous nethash maxelem 4000000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_anonymous src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_anonymous src -j DROP
                ;;
            5)
                echo "Erstelle firehol_level1"

                /sbin/ipset --create firehol_level1 nethash maxelem 10000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level1 src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level1 src -j DROP
                ;;
            6)
                echo "Erstelle firehol_level2"

                /sbin/ipset --create firehol_level2 nethash maxelem 50000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level2 src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level2 src -j DROP
                ;;
            7)
                echo "Erstelle firehol_level3"

                /sbin/ipset --create firehol_level3 nethash maxelem 30000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level3 src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level3 src -j DROP
                ;;
            8)
                echo "Erstelle firehol_level4"

                /sbin/ipset --create firehol_level4 nethash maxelem 160000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level4 src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level4 src -j DROP
                ;;
            9)
                echo "Erstelle firehol_proxies"

                /sbin/ipset --create firehol_proxies nethash maxelem 4000000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_proxies src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_proxies src -j DROP
                ;;
            10)
                echo "Erstelle firehol_webclient"

                /sbin/ipset --create firehol_webclient nethash maxelem 6000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webclient src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webclient src -j DROP
                ;;
            11)
                echo "Erstelle firehol_webserver"

                /sbin/ipset --create firehol_webserver nethash maxelem 6000
                /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webserver src -j DROP
                /sbin/iptables -I INPUT 1 -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webserver src -j DROP
                ;;
            *)  echo "Ungültige Auswahl: $i" ;;
        esac
    done

    update $auswahl
}

# Listen befüllen (kann dauern !)
function update {
    echo ""

    # Prüfe, ob Parameter übergeben wurden
    if [ $# -gt 0 ]; then
        auswahl="$(normalize_selection "$@")"
    else
        auswahl="1 2 3 4 5 6 7 8 9 10 11"
    fi

    for i in $auswahl; do
        case $i in
            1)
                if /sbin/ipset list local-ipset-blocklist &>/dev/null; then
                    echo "Aktualisiere local-ipset-blocklist"

                    /sbin/ipset flush local-ipset-blocklist

                    if [ -f "$LOCAL_IPSET_BLOCKLIST_FILE" ]; then
                        for ZONE in $(cat "$LOCAL_IPSET_BLOCKLIST_FILE" | sed '/#/d')
                        do /sbin/ipset --add local-ipset-blocklist "$ZONE"
                        done
                    fi

                    block    
                fi
                ;;
            2)
                if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
                    echo "Aktualisiere firehol_abusers_1d"

                    /sbin/ipset flush firehol_abusers_1d

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_1d.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_abusers_1d "$ZONE"
                    done
                fi
                ;;
            3)
                if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
                    echo "Aktualisiere firehol_abusers_30d"

                    /sbin/ipset flush firehol_abusers_30d

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_abusers_30d.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_abusers_30d "$ZONE"
                    done
                fi
                ;;
            4)
                if /sbin/ipset list firehol_anonymous &>/dev/null; then
                    echo "Aktualisiere firehol_anonymous"

                    /sbin/ipset flush firehol_anonymous

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_anonymous.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_anonymous "$ZONE"
                    done
                fi
                ;;
            5)
                if /sbin/ipset list firehol_level1 &>/dev/null; then
                    echo "Aktualisiere firehol_level1"

                    /sbin/ipset flush firehol_level1

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level1.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_level1 "$ZONE"
                    done
                fi
                ;;
            6)
                if /sbin/ipset list firehol_level2 &>/dev/null; then
                    echo "Aktualisiere firehol_level2"

                    /sbin/ipset flush firehol_level2

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level2.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_level2 "$ZONE"
                    done
                fi
                ;;
            7)
                if /sbin/ipset list firehol_level3 &>/dev/null; then
                    echo "Aktualisiere firehol_level3"

                    /sbin/ipset flush firehol_level3

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level3.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_level3 "$ZONE"
                    done
                fi
                ;;
            8)
                if /sbin/ipset list firehol_level4 &>/dev/null; then
                    echo "Aktualisiere firehol_level4"

                    /sbin/ipset flush firehol_level4

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_level4.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_level4 "$ZONE"
                    done
                fi
                ;;
            9)
                if /sbin/ipset list firehol_proxies &>/dev/null; then
                    echo "Aktualisiere firehol_proxies"

                    /sbin/ipset flush firehol_proxies

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_proxies.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_proxies "$ZONE"
                    done
                fi
                ;;
            10)
                if /sbin/ipset list firehol_webclient &>/dev/null; then
                    echo "Aktualisiere firehol_webclient"

                    /sbin/ipset flush firehol_webclient

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webclient.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_webclient "$ZONE"
                    done
                fi
                ;;
            11)
                if /sbin/ipset list firehol_webserver &>/dev/null; then
                    echo "Aktualisiere firehol_webserver"

                    /sbin/ipset flush firehol_webserver

                    for ZONE in $(wget --quiet -O - https://iplists.firehol.org/files/firehol_webserver.netset | sed '/#/d')
                    do /sbin/ipset --add firehol_webserver "$ZONE"
                    done
                fi
                ;;
        esac
    done

    lists
}

# Listen entfernen
function remove {
    echo ""

    # Prüfe, ob Parameter übergeben wurden
    if [ $# -gt 0 ]; then
        auswahl="$(normalize_selection "$@")"
    else
        auswahl="0 1 2 3 4 5 6 7 8 9 10 11"
    fi

    for i in $auswahl; do
        case $i in
            0)
                if /sbin/ipset list local-ipset-whitelist &>/dev/null; then
                    echo "Entferne local-ipset-whitelist"

                    /sbin/ipset --destroy local-ipset-whitelist
                fi
                ;;
            1)
                if /sbin/ipset list local-ipset-blocklist &>/dev/null; then
                    echo "Entferne local-ipset-blocklist"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set local-ipset-blocklist src -j DROP
                    /sbin/ipset --destroy local-ipset-blocklist
                fi
                ;;
            2)
                if /sbin/ipset list firehol_abusers_1d &>/dev/null; then
                    echo "Entferne firehol_abusers_1d"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_1d src -j DROP
                    /sbin/ipset --destroy firehol_abusers_1d
                fi
                ;;
            3)
                if /sbin/ipset list firehol_abusers_30d &>/dev/null; then
                    echo "Entferne firehol_abusers_30d"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_abusers_30d src -j DROP
                    /sbin/ipset --destroy firehol_abusers_30d
                fi
                ;;
            4)
                if /sbin/ipset list firehol_anonymous &>/dev/null; then
                    echo "Entferne firehol_anonymous"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_anonymous src -j DROP
                    /sbin/ipset --destroy firehol_anonymous
                fi
                ;;
            5)
                if /sbin/ipset list firehol_level1 &>/dev/null; then
                    echo "Entferne firehol_level1"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level1 src -j DROP
                    /sbin/ipset --destroy firehol_level1
                fi
                ;;
            6)
                if /sbin/ipset list firehol_level2 &>/dev/null; then
                    echo "Entferne firehol_level2"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level2 src -j DROP
                    /sbin/ipset --destroy firehol_level2
                fi
                ;;
            7)
                if /sbin/ipset list firehol_level3 &>/dev/null; then
                    echo "Entferne firehol_level3"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level3 src -j DROP
                    /sbin/ipset --destroy firehol_level3
                fi
                ;;
            8)
                if /sbin/ipset list firehol_level4 &>/dev/null; then
                    echo "Entferne firehol_level4"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_level4 src -j DROP
                    /sbin/ipset --destroy firehol_level4
                fi
                ;;
            9)
                if /sbin/ipset list firehol_proxies &>/dev/null; then
                    echo "Entferne firehol_proxies"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_proxies src -j DROP
                    /sbin/ipset --destroy firehol_proxies
                fi
                ;;
            10)
                if /sbin/ipset list firehol_webclient &>/dev/null; then
                    echo "Entferne firehol_webclient"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webclient src -j DROP
                    /sbin/ipset --destroy firehol_webclient
                fi
                ;;
            11)
                if /sbin/ipset list firehol_webserver &>/dev/null; then
                    echo "Entferne firehol_webserver"

                    /sbin/iptables -D INPUT -i "$IPTABLES_INTERFACE" -m set --match-set firehol_webserver src -j DROP
                    /sbin/ipset --destroy firehol_webserver
                fi
                ;;
        esac
    done

    lists
}

# Einen Eintrag zur lokalen Blockliste hinzufügen
function block_add {
    local entry="$1"
    local normalized_entry

    if [ -z "$entry" ]; then
        echo "Bitte eine IPv4-Adresse oder IPv4/CIDR-Angabe uebergeben."
        return 1
    fi

    normalized_entry="$(normalize_local_ipset_entry "$entry")" || {
        echo "Ungueltiges Format: $entry"
        echo "Erwartet wird eine IPv4-Adresse oder IPv4/CIDR-Angabe, z.B. 0.0.0.0/8 oder 0.0.0.0"
        return 1
    }

    if [ ! -f "$LOCAL_IPSET_BLOCKLIST_FILE" ]; then
        touch "$LOCAL_IPSET_BLOCKLIST_FILE"
    fi

    if grep -Fxq "$normalized_entry" "$LOCAL_IPSET_BLOCKLIST_FILE"; then
        echo "Eintrag bereits vorhanden: $normalized_entry"
    else
        printf '%s\n' "$normalized_entry" >> "$LOCAL_IPSET_BLOCKLIST_FILE"
        echo "Eintrag hinzugefuegt: $normalized_entry"
        update 1
    fi

    echo ""
    echo "### Aktuelle Blockliste ###"
    cat "$LOCAL_IPSET_BLOCKLIST_FILE"
}

# Einen Eintrag zur lokalen Whitelist hinzufügen
function allow_add {
    local entry="$1"
    local normalized_entry

    if [ -z "$entry" ]; then
        echo "Bitte eine IPv4-Adresse oder IPv4/CIDR-Angabe uebergeben."
        return 1
    fi

    normalized_entry="$(normalize_local_ipset_entry "$entry")" || {
        echo "Ungueltiges Format: $entry"
        echo "Erwartet wird eine IPv4-Adresse oder IPv4/CIDR-Angabe, z.B. 0.0.0.0/8 oder 0.0.0.0"
        return 1
    }

    if [ ! -f "$LOCAL_IPSET_WHITELIST_FILE" ]; then
        touch "$LOCAL_IPSET_WHITELIST_FILE"
    fi

    if grep -Fxq "$normalized_entry" "$LOCAL_IPSET_WHITELIST_FILE"; then
        echo "Eintrag bereits vorhanden: $normalized_entry"
    else
        printf '%s\n' "$normalized_entry" >> "$LOCAL_IPSET_WHITELIST_FILE"
        echo "Eintrag hinzugefuegt: $normalized_entry"
    fi

    cat "$LOCAL_IPSET_WHITELIST_FILE" | sort -u > "${LOCAL_IPSET_WHITELIST_FILE}.tmp"
    mv "${LOCAL_IPSET_WHITELIST_FILE}.tmp" "$LOCAL_IPSET_WHITELIST_FILE"

    echo ""
    echo "### Aktuelle Whitelist ###"
    cat "$LOCAL_IPSET_WHITELIST_FILE"
}

# Auswahl sortieren: groesser zuerst, damit die Reihenfolge der Uebergabe egal ist
function normalize_selection {
    printf '%s\n' $* | sort -nr | tr '\n' ' ' | sed 's/[[:space:]]\+$//'
}

# Normalisiert einen Eintrag für die lokale IPSET-Blockliste oder Whitelist.
function normalize_local_ipset_entry() {
    local entry="$1"
    local ip
    local mask

    entry="$(trim "$entry")"

    if [ -z "$entry" ]; then
        return 1
    fi

    if [[ ! "$entry" =~ ^(([0-9]{1,3}\.){3}[0-9]{1,3})(/([0-9]|[12][0-9]|3[0-2]))?$ ]]; then
        return 1
    fi

    ip="${BASH_REMATCH[1]}"
    mask="${BASH_REMATCH[4]}"

    IFS='.' read -r octet1 octet2 octet3 octet4 <<< "$ip"
    for octet in "$octet1" "$octet2" "$octet3" "$octet4"; do
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            return 1
        fi
    done

    if [ -n "$mask" ] && [ "$mask" = "32" ]; then
        printf '%s\n' "$ip"
    elif [ -n "$mask" ]; then
        printf '%s\n' "$entry"
    else
        printf '%s\n' "$ip"
    fi
}

#Whitelist-Filter-Funktionen
function trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

function is_whitelisted_entry() {
    local candidate="$1"
    shift

    local rule
    local normalized_candidate="$candidate"
    local normalized_rule

    if [[ "$normalized_candidate" != */* ]]; then
        normalized_candidate="${normalized_candidate}/32"
    fi

    for rule in "$@"; do
        normalized_rule="$rule"
        if [[ "$normalized_rule" != */* ]]; then
            normalized_rule="${normalized_rule}/32"
        fi

        if [ "$normalized_candidate" = "$normalized_rule" ]; then
            return 0
        fi
    done

    return 1
}

function filter_entries_against_whitelist() {
    local input_file="$1"
    local whitelist_file="$2"
    local output_file="$3"
    local set_name="$4"
    local line
    local -a whitelist_entries=()

    : > "$output_file"

    if [ -f "$whitelist_file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            line="${line%%#*}"
            line="$(trim "$line")"
            [ -n "$line" ] || continue
            whitelist_entries+=("$line")
        done < "$whitelist_file"
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line="$(trim "$line")"
        [ -n "$line" ] || continue

        if is_whitelisted_entry "$line" "${whitelist_entries[@]}"; then
            continue
        fi

        if [ -n "$set_name" ]; then
            printf 'add %s %s\n' "$set_name" "$line" >> "$output_file"
        else
            printf '%s\n' "$line" >> "$output_file"
        fi
    done < "$input_file"
}

function wget {
    if [ "$1" = "--quiet" ] && [ "$2" = "-O" ] && [ "$3" = "-" ] && [ $# -ge 4 ]; then
        local feed_url="${@: -1}"
        local feed_file

        feed_file="$(mktemp)"

        if ! command wget --quiet -O "$feed_file" "$feed_url"; then
            rm -f "$feed_file"
            return 1
        fi

        filtered_file="$(mktemp)"
        filter_entries_against_whitelist "$feed_file" "$LOCAL_IPSET_WHITELIST_FILE" "$filtered_file"
        cat "$filtered_file"

        rm -f "$filtered_file" "$feed_file"
        return 0
    fi

    command wget "$@"
}