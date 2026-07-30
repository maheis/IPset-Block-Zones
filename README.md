# 🇩🇪 IPset-Block-Zones

Dieses Skript ermöglicht das einfache Einrichten und Verwalten von IP-Blocklisten mit `ipset`, basierend auf den Blocklisten von [Firehole](https://iplists.firehol.org) und lässt sich leicht mit anderen Blocklisten erweitern. Meldet euch bitte, wenn ihr weitere Blocklisten kennt, die hier sinnvoll ergänzt werden können.
Geblockt wird eingehender Traffic auf dem Interface **eth0** von IP-Adressen, die in den ausgewählten Blocklisten enthalten sind. Dies kann helfen, unerwünschten Traffic zu reduzieren und die Sicherheit des Systems zu erhöhen.

## Listen

[Firehole](https://iplists.firehol.org)

- local-ipset-whitelist
  - Eine eigene lokale Whitelist. Diese kann dann mit eigenen IPs befüllt werden die dem Format
- local-ipset-blocklist
  - Eine eigene lokale Block-Liste. Diese kann dann mit eigenen IPs befüllt werden die dem Format 0.0.0.0/0 entsprechen. Liste muss unter /opt/local-ipset-blocklist.zone erstellt werden!
- firehol_abusers_1d
  - An ipset made from blocklists that track abusers in the last 24 hours. (includes: botscout_1d cleantalk_new_1d cleantalk_updated_1d php_commenters_1d php_dictionary_1d php_harvesters_1d php_spammers_1d stopforumspam_1d)
- firehol_abusers_30d
  - An ipset made from blocklists that track abusers in the last 30 days. (includes: cleantalk_new_30d cleantalk_updated_30d php_commenters_30d php_dictionary_30d php_harvesters_30d php_spammers_30d stopforumspam sblam)
- firehol_anonymous
  - An ipset that includes all the anonymizing IPs of the world. (includes: anonymous dm_tor firehol_proxies tor_exits)
- firehol_level1
  - This site analyses all available security IP Feeds, mainly related to on-line attacks, on-line service abuse, malwares, botnets, command and control servers and other cybercrime activities.
- firehol_level2
  - An ipset made from blocklists that track attacks, during about the last 48 hours. (includes: blocklist_de dshield_1d greensnow)
- firehol_level3
  - An ipset made from blocklists that track attacks, spyware, viruses. It includes IPs than have been reported or detected in the last 30 days. (includes: bruteforceblocker ciarmy dshield_30d myip vxvault)
- firehol_level4
  - An ipset made from blocklists that track attacks, but may include a large number of false positives. (includes: blocklist_net_ua botscout_30d cybercrime iblocklist_hijacked iblocklist_spyware iblocklist_webexploit)
- firehol_proxies
  - An ipset made from all sources that track open proxies. It includes IPs reported or detected in the last 30 days. (includes: iblocklist_proxies ip2proxy_px1lite socks_proxy_30d sslproxies_30d)
- firehol_webclient
  - An IP blacklist made from blocklists that track IPs that a web client should never talk to. This list is to be used on top of firehol_level1. (includes: cybercrime)
- firehol_webserver
  - A web server IP blacklist made from blocklists that track IPs that should never be used by your web users. (This list includes IPs that are servers hosting malware, bots, etc or users having a long criminal history. This list is to be used on top of firehol_level1, firehol_level2, firehol_level3 and possibly firehol_proxies or firehol_anonymous) . (includes: myip stopforumspam_toxic)

## Erstinstallation

```bash
mkdir -p /etc/ipset
wget https://raw.githubusercontent.com/maheis/IPset-Block-Zones/refs/heads/main/block-zones.sh > /dev/null 2>&1
sudo mv -f block-zones.sh /etc/ipset/block-zones.sh
sudo chmod +x /etc/ipset/block-zones.sh
```

## Nutzung

```bash
sudo /etc/ipset/block-zones.sh

sudo /etc/ipset/block-zones.sh install          # Benötigte Pakete installieren
sudo /etc/ipset/block-zones.sh lists            # Listen anzeigen
sudo /etc/ipset/block-zones.sh create           # Auswahl Listen erstellen
sudo /etc/ipset/block-zones.sh update           # Vorhandene Listen aktualisieren
sudo /etc/ipset/block-zones.sh block 10.0.0.0/8 # Eintrag zur lokalen Blockliste hinzufügen
sudo /etc/ipset/block-zones.sh block 10.4.7.11  # Wird automatisch als 10.4.7.11/32 gespeichert
sudo /etc/ipset/block-zones.sh allow 10.0.0.0/8 # Eintrag zur lokalen Whitelist hinzufügen
sudo /etc/ipset/block-zones.sh allow 10.4.7.11  # Wird automatisch als 10.4.7.11/32 gespeichert
sudo /etc/ipset/block-zones.sh remove           # Alle Listen entfernen
```

## Automatisierung

```bash
sudo crontab -e

#Listennummern beim Booten anlegen und täglich aktualisieren; Beispiel bzw. meine Konfiguration:
@reboot /etc/ipset/block-zones.sh create 0 1 2 3 5 6 7
@daily /etc/ipset/block-zones.sh update

```
