#/bin/bash

#V2.0 Haxor Script, the simple UI for iproute2, dhclient, and dnsmasq configurations
#Written by Ph0rrest

######################################################################

#FIELD TO DETERMINE IF YOU CAN HANDLE THIS SCRIPT!!
######################################################################
mach="$(uname -s)"
case "${mach}" in
	Linux*)		machine=Linux;;
	Darwin*)	machine=Mac;;
	CYGWIN*)	machine=Cygwin;;
	MINGW*)		machine=MinGw;;
esac
if [ "$machine" != "Linux" ]; then
	echo "This super 1337 script requires Linux."
	echo "To learn why this is, please use the link below"
	echo -e
	echo "https://www.youtube.com/watch?v=DLzxrzFCyOs"
	exit 1
fi
if [ "$EUID" -ne 0 ]; then
	echo "This super 1337 script requires root."
	echo "Please run this script with 'sudo bash ./haxor.sh' to properly execute"
	exit 1
fi

function menu {
	printf "\n\
[$(tput bold)1$(tput sgr0)] List Devices\n\
[$(tput bold)2$(tput sgr0)] Virtual Devices\n\
[$(tput bold)3$(tput sgr0)] Address Management\n\
[$(tput bold)4$(tput sgr0)] MAC Address Management\n\
[$(tput bold)5$(tput sgr0)] Start DHCP Server\n\
[$(tput bold)6$(tput sgr0)] ifconfig.me\n\
[$(tput bold)7$(tput sgr0)] dig\n\
[$(tput bold)8$(tput sgr0)] OUI Lookup\n\
[$(tput bold)0$(tput sgr0)] Quit\n\n"
	read -r -sn1 key
	case "$key" in
			[1]) listdevices;;
			[2]) virtualinterface;;
			[3]) addressmanagement;;
			[4]) macaddress;;
			[5]) dhcpserver;;
			[6]) ifconfig;;
			[7]) digfunction;;
			[8]) ouilookup;;
			[0]) printf "\n"; exit;;
	esac
}


#(1) FUNCTION TO LIST ALL LINK LAYER DEVICES AND IP ADDRESSES
#################################################################################
function listdevices {														
	echo -e																	
	echo "$(tput setaf 4)Layer 2 Devices and Configuration$(tput setaf 7)"	
	ip -br link																
	echo -e																	
	echo "$(tput setaf 4)Layer 3 Devices and Configuration$(tput setaf 7)"	
	ip -br addr																																	
}																			
#################################################################################


#(2) FUNCTION SET TO HANDLE VIRTUAL INTERFACES
#################################################################################
function validateinterfaces {
	echo "$(tput setaf 1)Please Select a device from the list below$(tput setaf 7)"
	echo -e
	ifaces=($(ip link show | grep -v link | awk {'print $2'} | sed 's/://g' | grep -v lo))
	for i in "${!ifaces[@]}"; do
		echo ${ifaces[$i]}
	done
	echo -e																											
	read dev																	
	echo -e																		
	echo -e																		
	echo "$(tput setaf 1)Please select what VLAN ID to use (1-4096)$(tput setaf 7)"									
	read vid																	
	if (( $vid < 1 )); then														
	echo "Please select a number between 1 and 4096 as per the 802.1q standard"	
	virtualinterface															
	elif (( $vid > 4096 )); then												
	echo "Please select a number between 1 and 4096 as per the 802.1q standard"	
	virtualinterface															
	fi																			
}																				
																				
																				
function virtualinterface1 {													
	validateinterfaces															
	echo -e																		
	sudo ip link add link $dev name $dev.$vid type vlan id $vid					
	sudo ip link set $dev.$vid up												
	ip -br link																	
	menu																		
}																				
																				
function virtualinterface2 {													
	validateinterfaces															
	echo -e																		
	sudo ip link delete dev $dev.$vid											
	ip -br link																	
	menu																		
}																				
																				
function virtualinterface {														
	echo -e																		
	ip -br link																	
printf "\n
[$(tput bold)1$(tput sgr0)] Build New Interface\n\
[$(tput bold)2$(tput sgr0)] Delete Existing Interface\n\
[$(tput bold)0$(tput sgr0)] Quit\n\n"
	read -r -sn1 key															
	case "$key" in																
			[1]) virtualinterface1;;											
			[2]) virtualinterface2;;											
			[0]) printf "\n"; exit;;											
	esac																		
}																				
#################################################################################


#(3) IP ADDRESS SUBMENU
#################################################################################
function validateip {
	echo "$(tput setaf 4)This script doesn't have functionality YET to validate your IP that you are entering$(tput setaf 7)"
	echo "$(tput setaf 4)Please make sure you are entering an address in the following format$(tput setaf 7)"
	echo "$(tput setaf 4)4 octets, seperated by periods, each of which is less than 256, like so$(tput setaf 7)"
	echo "$(tput setaf 4)0.0.0.0-255.255.255.255$(tput setaf 7)"
	echo "$(tput setaf 1)Address:$(tput setaf 7)"
	read addr
	echo "$(tput setaf 1)Netmask in CIDR (1-32):$(tput setaf 7)"
	read nmask
	echo "$(tput setaf 1)Device:$(tput setaf 7)"
	read dev
#IF statement to validate netmask
	if (( $nmask < 1 )); then														
	echo "Please use a netmask between 1 and 32"	
	addressmanagement															
	elif (( $nmask > 32 )); then												
	echo "Please use a netmask between 1 and 32"	
	addressmanagement															
	fi
#IF statement to validate address will go here someday

}


function staticip {
	listdevices
	validateip
	sudo ip addr add $addr/$nmask dev $dev
	ip -br addr
}

function removeip {
	echo -e
	ip -br addr
	validateip
	sudo ip addr del $addr/$nmask dev $dev
	ip -br addr

}

function dhcpip {
	listdevices
	echo -e
	echo "Which device would you like to pull a dynamic address?"
	read dev
	sudo dhclient $dev
}

function addressmanagement {
printf "\n\
[$(tput bold)1$(tput sgr0)] Static IP\n\
[$(tput bold)2$(tput sgr0)] DHCP IP\n\
[$(tput bold)3$(tput sgr0)] Remove IP\n\
[$(tput bold)0$(tput sgr0)] Quit\n\n"
	read -r -sn1 key
	case "$key" in
			[1]) staticip;;
			[2]) dhcpip;;
			[3]) removeip;;
			[0]) printf "\n"; exit;;
	esac
}
#################################################################################

#(4) MAC ADDRESS RANDOMIZER AND CHANGING UTILITY
#################################################################################
function macaddress {
	echo "I was going to try to build a tool to use the 'ip link set dev ${dev} address 11:22:33:aa:bb:cc'"
	echo "command set that is integrated in iproute2, but validating hex characters was a bitch to do."
	echo "Instead, check out the folks at macchanger, and see below the table for how their super cool"
	echo "utility works. I've included the help page for reference if you already have it installed,"
	echo -e
	echo "Sorry for the inconvenience"
	echo " - Ph0rrest"
	echo -e
	echo -e
	echo "GNU MAC Changer"
	echo "Usage: macchanger [options] device"
	echo -e
	echo "  -h,  --help                   Print this help"
	echo "  -V,  --version                Print version and exit"
	echo "  -s,  --show                   Print the MAC address and exit"
	echo "  -e,  --ending                 Don't change the vendor bytes"
	echo "  -a,  --another                Set random vendor MAC of the same kind"
	echo "  -A                            Set random vendor MAC of any kind"
	echo "  -p,  --permanent              Reset to original, permanent hardware MAC"
	echo "  -r,  --random                 Set fully random MAC"
	echo "  -l,  --list[=keyword]         Print known vendors"
	echo "  -b,  --bia                    Pretend to be a burned-in-address"
	echo "  -m,  --mac=XX:XX:XX:XX:XX:XX"
	echo "       --mac XX:XX:XX:XX:XX:XX  Set the MAC XX:XX:XX:XX:XX:XX"
	echo -e
	echo "Report bugs to https://github.com/alobbs/macchanger/issues"
}
#################################################################################

#(5) DHCP SERVER FUNCTION
#################################################################################
#Function to handle user input for the nameserver
function nameserver {
	echo "Please enter what you would like to use for your DNS server in the DHCP packet"
	echo "If you enter nothing, it will default to 1.1.1.1"
	read DNS
	if [[ -z "$DNS" ]]; then
	DNS=1.1.1.1
	dns=$DNS
	else
	dns=$DNS
	fi
}

function dhcpserver {
ip addr add 10.20.30.1/255.255.255.0 dev eth0
ip link set eth0 up

ip addr add 10.20.30.1/255.255.255.0 dev eth0
ip link set eth0 up
default=$(ip ro | grep default | awk {'print $3'})
echo $default
echo '1' > /proc/sys/net/ipv4/ip_forward # Enable IP Forwarding
iptables -X #clear chains and rules
iptables -F
iptables -A FORWARD -i wlan0 -o eth0 -s 10.20.30.0/24 -m state --state NEW -j ACCEPT #setup IP forwarding
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE
ip route del default #remove default route
ip route add default via $default dev wlan0 #add default gateway



IFNAME=eth0
/sbin/ip addr replace 10.20.30.1/24 dev $IFNAME
/sbin/ip link set dev $IFNAME up
/usr/sbin/dnsmasq \
--no-daemon \
--strict-order \
--listen-address 10.20.30.1 \
--dhcp-option=6,1.1.1.1 \
--bind-interfaces \
-p0 \
--dhcp-authoritative \
--dhcp-range=10.20.30.100,10.20.30.200 \
#--domain-name-servers=10.20.30.1 \
--bootp-dynamic \
#--log-dhcp \
}
#################################################################################

#(6) IFConfig.me tools
#################################################################################
function ifconfig {
printf "\n\
[$(tput bold)1$(tput sgr0)] ifconfig.me\n\
[$(tput bold)2$(tput sgr0)] ifconfig.me/ip\n\
[$(tput bold)3$(tput sgr0)] ifconfig.me/ua\n\
[$(tput bold)4$(tput sgr0)] ifconfig.me/lang\n\
[$(tput bold)5$(tput sgr0)] ifconfig.me/encoding\n\
[$(tput bold)6$(tput sgr0)] ifconfig.me/mime\n\
[$(tput bold)7$(tput sgr0)] ifconfig.me/charset\n\
[$(tput bold)8$(tput sgr0)] ifconfig.me/forwarded\n\
[$(tput bold)9$(tput sgr0)] ifconfig.me/all\n\
[$(tput bold)0$(tput sgr0)] ifconfig.me/all.json\n\
[$(tput bold)Q$(tput sgr0)]uit\n\n"
	read -r -sn1 key
	case "$key" in
			[1]) curl ifconfig.me && echo -e;;
			[2]) curl ifconfig.me/ip && echo -e;;
			[3]) curl ifconfig.me/ua && echo -e;;
			[4]) curl ifconfig.me/lang && echo -e;;
			[5]) curl ifconfig.me/encoding && echo -e;;
			[6]) curl ifconfig.me/mime && echo -e;;
			[7]) curl ifconfig.me/charset && echo -e;;
			[8]) curl ifconfig.me/forwarded && echo -e;;
			[9]) curl ifconfig.me/all && echo -e;;
			[0]) curl ifconfig.me/all.json && echo -e;;
			[qQ]) printf "\n"; exit;;
	esac

}
#################################################################################

#(7) dig
#################################################################################
function digdefault {
	echo "Enter the host you'd like to look up"
	read fqdn
	dig $fqdn
	digfunction
}
function digspecific {
	echo "Enter the host you'd like to look up"
	read fqdn
	echo "Enter the nameserver you'd like to use (Default is cloudflare)"
	read ns
	if [[ -z "$ns" ]]; then
	ns=1.1.1.1
	dig $fqdn @$ns
	else
	dig $fqdn @$ns
	fi
	digfunction
}
function digfunction {
	printf "\n\
[$(tput bold)1$(tput sgr0)] Search FQDN\n\
[$(tput bold)2$(tput sgr0)] Search FQDN on specific NS\n\
[$(tput bold)0$(tput sgr0)] Quit\n\n"
	read -r -sn1 key
	case "$key" in
			[1]) digdefault;;
			[2]) digspecific;;
			[0]) printf "\n"; exit;;
	esac
	
}
#################################################################################

#(8) OUI Lookup Function
#################################################################################
function ouitool {
echo "Please enter the MAC or OUI you wish to look up"
read ouimac
ouimac=${ouimac^^}
ouimac=${ouimac//.}
ouimac=${ouimac//:}
ouimac=${ouimac//-}
echo=$ouimac
stringcount=${#ouimac}

if [ $stringcount = 6 ]
then
        cat ./.oui.txt | grep ${ouimac}
elif [ $stringcount = 12 ]
then
        ouimac=${ouimac:0:6}
        cat ./.oui.txt | grep ${ouimac}
else
        echo "This is not a valid MAC OUI"
fi
ouilookup
}
function ouiupdate {
curl https://standards-oui.ieee.org/oui/oui.txt | grep "(base 16)" >> oui.txt && sed -i -e 's/(base 16)//g' oui.txt
mv oui.txt ./.oui.txt
ouilookup
}
function ouilookup {
	printf "\n\
[$(tput bold)1$(tput sgr0)] Lookup OUI\n\
[$(tput bold)2$(tput sgr0)] Check database age\n\
[$(tput bold)3$(tput sgr0)] Update database\n\
[$(tput bold)0$(tput sgr0)] Quit\n\n"
	read -r -sn1 key
	case "$key" in
			[1]) ouitool;;
			[2]) ls -la .oui.txt && ouilookup;;
			[3]) ouiupdate;;
			[0]) printf "\n"; exit;;
	esac
}
#################################################################################
menu
