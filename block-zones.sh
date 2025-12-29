#!/bin/bash
# Block-Zones mit /sbin/ipset und Firehol-Listen

mkdir -p /etc/ipset
wget https://raw.githubusercontent.com/maheis/IPset-Block-Zones/refs/heads/main/block-zones.sh > /dev/null 2>&1
sudo mv -f block-zones.sh /etc/ipset/block-zones.sh
sudo chmod +x /etc/ipset/block-zones.sh
wget https://raw.githubusercontent.com/maheis/IPset-Block-Zones/refs/heads/main/function-zones.sh > /dev/null 2>&1
sudo mv -f function-zones.sh /etc/ipset/function-zones.sh

source /etc/ipset/function-zones.sh

if [ "$1" == "" ]; then
    echo "Usage: $0 {install|lists|create|update|import|remove}"
    exit 1
fi

ACTION=$1
shift
case $ACTION in
    install)
        install
        ;;
    lists)
        lists
        ;;
    create)
        create
        ;;
    update)
        update
        ;;
    import)
        import
        ;;
    remove)
        remove
        ;;
    *)
        echo "Usage: $0 {install|lists|create|update|import|remove}"
        exit 1
        ;;
esac