# For Amazon Linuz

sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables

echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/custom-ip-forwarding.conf >/dev/null
sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
echo "IPv4 forwarding has been enabled."

netstat -i
echo "Please note the name of the network interface that you want to use for NAT."
echo "Enter the name of the network interface that you want to use for NAT (e.g., eth0):"
read -r NETWORK_INTERFACE 
sudo /sbin/iptables -t nat -A POSTROUTING -o "$NETWORK_INTERFACE" -j MASQUERADE
sudo /sbin/iptables -F FORWARD 
sudo service iptables save
