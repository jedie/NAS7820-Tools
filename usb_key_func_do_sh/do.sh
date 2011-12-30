# Here is a examle do script
# We try to get a IP via DHCP and start telnet
# If something wring, we continue the boot process by 'exit 1'
# You should see something via 'dmesg'


echo "******************************"
echo "Hello from do.sh !!!"
echo "******************************"


# Get IP via DHCP (for P89626 based systems)
/sbin/udhcpc -i egiga0
if [ $? == 0 ]; then
    echo "OK, get IP via DHCP."
else
    echo "Error: Can't get IP via DHCP!"
    echo "continue boot process..."
    exit 1
fi


# Startup telnet:
telnetd -l /bin/sh &
if [ $? == 0 ]; then
    echo "OK, start telnet."
else
    echo "Error: Can't start telnet!"
    echo "continue boot process..."
    exit 1
fi